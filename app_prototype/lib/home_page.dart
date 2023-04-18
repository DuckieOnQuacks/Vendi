import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'package:vendi_app/machine_bottom_sheet.dart';
import 'package:vendi_app/backend/machine_class.dart';
import 'Addmachine.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  Position? currentPosition;
  late MapType _currentMapType = MapType.hybrid;

  // Helper method to get the current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location permission is granted
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request location permission if it is not granted
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // User has denied location permission
          return null;
        }
      }

      // Retrieve the current location if location permission is granted
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<void> _getAllMachines() async {
    final machineList = await FirebaseHelper().getAllMachines();
    for (final machine in machineList) {
      _markers[machine.id.toString()] = await _createMarker(machine);
    }
  }

  @override
  void initState() {
    super.initState();
    initHomepage();
  }

  Future<void> initHomepage() async {
    currentPosition = await getCurrentPosition();
    await _getAllMachines();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    mapController.dispose();
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
            icon: const Icon(Icons.add, color: Colors.pink),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMachinePage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: _currentMapType,
              mapToolbarEnabled: false,
              myLocationEnabled:
                  true, // Add this line to enable the user's location
              buildingsEnabled: true,
              myLocationButtonEnabled:
                  true, // Add this line to enable the location button
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentPosition!.latitude, currentPosition!.longitude),
                zoom: 18,
              ),
              onMapCreated: (controller) async {
                mapController = controller;
              },
              markers: _markers.values.toSet(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_currentMapType == MapType.normal) {
              _currentMapType = MapType.hybrid;
            } else {
              _currentMapType = MapType.normal;
            }
          });
        },
        child: Icon(
          _currentMapType == MapType.normal ? Icons.satellite : Icons.map,
        ),
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
        snippet: machine.desc,
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
