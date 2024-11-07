import 'dart:ui' as ui;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'package:vendi_app/filter_page.dart';
import 'package:vendi_app/machine_bottom_sheet.dart';
import 'package:vendi_app/backend/machine_class.dart';
import 'Addmachine.dart';
import 'machine_help.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};
  Position? currentPosition;
  late MapType _currentMapType = MapType.hybrid;
  List<bool> bools = [ ];
  bool _isPermissionGranted = false;

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
              content: const Text('This app requires location permission to function.'),
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
    final machineList = await FirebaseHelper().getFilteredMachines(snack, drink, supply);
    final markerFutures = machineList.map((machine) => _createMarker(machine).then((marker) {
      _markers[machine.id.toString()] = marker;
    })).toList();
    await Future.wait(markerFutures);
  }

  @override
  void initState() {
    super.initState();
    //initHomepage();
    bools = filterValues.values.toList();
    rebuildHomepage(bools[0], bools[1], bools[2]);
  }

  Future<void> rebuildHomepage(bool snack, bool drink, bool supply) async
  {
    await _getFilteredMachines(snack, drink, supply);
    if (mounted) {
      setState(() {});
    }
  }

  void dispose() {
    _isPermissionGranted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          height: 32,
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MachineHelpPage()),
              );

            }),

          Row(
            children: [
              IconButton(
                icon: Icon(Icons.filter_alt, color: Theme.of(context).iconTheme.color),
                onPressed: () => showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: ((context) => FilterPage())
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddMachinePage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<Position?>(
        future: getCurrentPosition(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            currentPosition = snapshot.data;
            _getFilteredMachines(bools[0], bools[1], bools[2]);
            return GoogleMap(
              mapType: _currentMapType,
              mapToolbarEnabled: false,
              myLocationEnabled: true, // Add this line to enable the user's location
              buildingsEnabled: true,
              myLocationButtonEnabled: true, // Add this line to enable the location button
              initialCameraPosition: CameraPosition(
                target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                zoom: 18,
              ),
              onMapCreated: (controller) async {
                mapController = controller;
              },
              markers: _markers.values.toSet(),
            );
          } else if (snapshot.hasError) {
            return Container(); // Return an empty container if location permission is not granted
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<Marker> _createMarker(Machine machine) async {
    final markerIcon = await getBytesFromAsset(machine.icon, 100);
    return Marker(
      markerId: MarkerId(machine.id.toString()),
      position: LatLng(machine.lat, machine.lon),
      infoWindow: InfoWindow(
        title: machine.name,
        snippet: 'Floor: ${machine.desc}',
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (context) => MachineBottomSheet(machine),
        ),
      ),
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );
  }

  // Sourced from https://github.com/flutter/flutter/issues/34657 to resize images in code
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}

