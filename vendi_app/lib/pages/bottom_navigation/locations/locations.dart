import 'dart:ui' as ui;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vendi_app/backend/classes/firebase.dart';
import 'package:vendi_app/pages/bottom_navigation/locations/menus/add_machine_menu.dart';
import 'package:vendi_app/pages/debug_menu/debug_menu.dart';
import 'package:vendi_app/pages/bottom_navigation/locations/widgets/filter_bottom_sheet.dart';
import 'package:vendi_app/pages/bottom_navigation/locations/widgets/machine_bottom_sheet.dart';
import 'package:vendi_app/backend/classes/machine.dart';
import 'package:vendi_app/backend/message_helper.dart';

class MachineLocator extends StatefulWidget {
  const MachineLocator({Key? key}) : super(key: key);

  @override
  State<MachineLocator> createState() => _MachineLocatorState();
}

class _MachineLocatorState extends State<MachineLocator> {
  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};
  Position? currentPosition;
  late MapType _currentMapType = MapType.hybrid;
  List<bool> bools = [];
  bool _isPermissionGranted = false;
  bool _isMarkerLoading = false;
  bool _isMapReady = false;
  Future<Position?>? _positionFuture;

  // Cache for marker icons to avoid repeatedly loading and processing the same assets
  final Map<String, BitmapDescriptor> _markerIconCache = {};

  // Helper method to get the current position
  Future<Position?> getCurrentPosition() async {
    if (!_isPermissionGranted) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Location permission'),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: const Text(
                  'This app requires location permission to function.'),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    await AppSettings.openAppSettings();
                  },
                  child: const Text('SETTINGS'),
                ),
              ],
            ),
          );
        } else {
          _isPermissionGranted = true;
        }
      } else {
        _isPermissionGranted = true;
      }
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      forceAndroidLocationManager: true,
    );
  }

  Future<void> _getFilteredMachines(bool snack, bool drink, bool supply) async {
    if (!mounted) return;

    // Clear existing markers before adding new ones
    _markers.clear();

    try {
      final machineList =
          await FirebaseHelper().getFilteredMachines(snack, drink, supply);

      // Process markers in batches to avoid UI freezes
      const int batchSize = 10;
      for (int i = 0; i < machineList.length; i += batchSize) {
        if (!mounted) return;
        final batch = machineList.skip(i).take(batchSize);

        // Process batch
        await Future.wait(
            batch.map((machine) => _createMarker(machine).then((marker) {
                  if (mounted) {
                    _markers[machine.id.toString()] = marker;
                  }
                })));

        // Update UI after each batch if widget is still mounted
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      // Handle errors silently
    } finally {
      if (mounted) {
        setState(() {
          _isMarkerLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _positionFuture = getCurrentPosition();
    bools = filterValues.values.toList();
    _precacheMarkerIcons();

    // Ensure any potential dialogs are dismissed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Clear any potential loading states
      if (mounted) {
        setState(() {
          _isMarkerLoading = false;
        });
      }
    });
  }

  // Pre-cache marker icons to improve performance
  Future<void> _precacheMarkerIcons() async {
    final iconPaths = [
      "assets/images/BlueMachine.png",
      "assets/images/PinkMachine.png",
      "assets/images/YellowMachine.png",
    ];

    for (final path in iconPaths) {
      final markerIcon = await getBytesFromAsset(path, 100);
      _markerIconCache[path] = BitmapDescriptor.fromBytes(markerIcon);
    }
  }

  Future<void> applyMachineFilter(bool snack, bool drink, bool supply) async {
    await _getFilteredMachines(snack, drink, supply);
  }

  @override
  void dispose() {
    mapController?.dispose();
    mapController = null;
    _isMapReady = false;
    _isMarkerLoading = false;
    _isPermissionGranted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(
                  Icons.bug_report,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                tooltip: 'Debug Menu',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DebugMenu()),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: Theme.of(context).iconTheme.color),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddMachineMenu(),
                ),
              );
              if (result == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  showConfettiDialog(context,
                      "Congratulations you've earned 50 vendi points!");
                  // Refresh markers after confetti
                  await applyMachineFilter(bools[0], bools[1], bools[2]);
                });
              }
            },
            tooltip: 'Add Machine',
          ),
          IconButton(
            icon: Icon(Icons.filter_alt,
                color: Theme.of(context).iconTheme.color),
            onPressed: () => showModalBottomSheet(
              isDismissible: true,
              enableDrag: true,
              context: context,
              builder: (context) => const FilterPage(),
            ),
            tooltip: 'Filter',
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<Position?>(
        future: _positionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error getting location. Please ensure permissions are granted and location is enabled.'));
          } else if (snapshot.hasData) {
            currentPosition = snapshot.data;
            if (currentPosition == null ||
                currentPosition!.latitude.isNaN ||
                currentPosition!.longitude.isNaN) {
              return const Center(
                  child:
                      Text('Could not determine location. Please try again.'));
            }

            return Stack(
              children: [
                // Always include GoogleMap so it can initialize, but covered by overlay when not ready
                GoogleMap(
                  mapType: _currentMapType,
                  mapToolbarEnabled: false,
                  myLocationEnabled: true,
                  buildingsEnabled: true,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        currentPosition!.latitude, currentPosition!.longitude),
                    zoom: 18,
                  ),
                  onMapCreated: (controller) async {
                    mapController = controller;
                    print('Map controller created successfully');

                    // Trigger machine loading AFTER map is created
                    if (mounted) {
                      setState(() {
                        _isMarkerLoading = true;
                      });

                      try {
                        await applyMachineFilter(bools[0], bools[1], bools[2]);
                        print('Machine filter applied successfully');
                      } catch (e) {
                        print('Error applying machine filter: $e');
                      }

                      if (mounted) {
                        setState(() {
                          _isMapReady = true;
                        });
                        print('Map marked as ready');
                      }
                    }
                  },
                  onCameraMove: (position) {
                    print('Camera moved to: ${position.target}');
                  },
                  onCameraIdle: () {
                    print('Camera idle');
                  },
                  onTap: (position) {
                    print('Map tapped at: $position');
                  },
                  markers: _markers.values.toSet(),
                ),

                // Overlay the loading screen on top when map is not ready
                if (!_isMapReady)
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ),

                // Only show these controls when map is ready
                if (_isMapReady)
                  Positioned(
                    right: 16,
                    top: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'location',
                      backgroundColor: Colors.black.withOpacity(0.5),
                      onPressed: () async {
                        if (currentPosition != null) {
                          mapController?.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(currentPosition!.latitude,
                                  currentPosition!.longitude),
                            ),
                          );
                        }
                      },
                      child: const Icon(Icons.my_location,
                          size: 18, color: Colors.white),
                    ),
                  ),

                // Add tap hint overlay
                if (_isMapReady && _markers.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app,
                                color: Colors.white.withOpacity(0.8), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Tap icons for details',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (_isMapReady)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'zoomIn',
                          backgroundColor: Colors.black.withOpacity(0.5),
                          onPressed: () {
                            mapController?.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                          child: const Icon(Icons.add,
                              size: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'zoomOut',
                          backgroundColor: Colors.black.withOpacity(0.5),
                          onPressed: () {
                            mapController?.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                          child: const Icon(Icons.remove,
                              size: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                // Show the marker loading indicator only if map is ready
                if (_isMapReady && _isMarkerLoading)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "MARKER LOADING",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(
                child: Text(
                    'Unable to get location. Check permissions and ensure location services are enabled.'));
          }
        },
      ),
    );
  }

  Future<Marker> _createMarker(Machine machine) async {
    // Check if icon is already cached
    BitmapDescriptor? markerIcon = _markerIconCache[machine.icon];

    // If not cached, create and cache it
    if (markerIcon == null) {
      final iconBytes = await getBytesFromAsset(machine.icon, 100);
      markerIcon = BitmapDescriptor.fromBytes(iconBytes);
      _markerIconCache[machine.icon] = markerIcon;
    }

    return Marker(
      markerId: MarkerId(machine.id.toString()),
      position: LatLng(machine.lat, machine.lon),
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (context) => MachineBottomSheet(machine),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),
      icon: markerIcon,
    );
  }

  // Sourced from https://github.com/flutter/flutter/issues/34657 to resize images in code
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }
}
