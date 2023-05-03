import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'package:vendi_app/backend/message_helper.dart';
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

  //This is very slow right now so im using futures to speed it up
  Future<void> _getAllMachines() async {
    final machineList = await FirebaseHelper().getAllMachines();

    final markerFutures = <Future<void>>[];
    for (final machine in machineList) {
      markerFutures.add(_createMarker(machine).then((marker) {
        _markers[machine.id.toString()] = marker;
      }));
    }

    await Future.wait(markerFutures);
  }

  Future<void> _getFilteredMachines(bool snack, bool drink, bool supply) async
  {
    final machineList = await FirebaseHelper().getFilteredMachines(snack, drink, supply);

    final markerFutures = <Future<void>>[];
    for (final machine in machineList) {
      markerFutures.add(_createMarker(machine).then((marker) {
        _markers[machine.id.toString()] = marker;
      }));
    }

    await Future.wait(markerFutures);
  } 

  @override
  void initState() {
    super.initState();
    //initHomepage();
    List<bool> bools = filterValues.values.toList();
    rebuildHomepage(bools[0], bools[1], bools[2]);
  }

  Future<void> initHomepage() async {
    currentPosition = await getCurrentPosition();
    await _getAllMachines();
    if (mounted) {
      setState(() {});
    }
  }

    Future<void> rebuildHomepage(bool snack, bool drink, bool supply) async
  {
    currentPosition = await getCurrentPosition();
    await _getFilteredMachines(snack, drink, supply);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
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
            icon: const Icon(Icons.help_outline, color: Colors.pink),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder:(context) => const MachineHelpPage()),
              );
            },
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt, color: Colors.pink),
                onPressed: () => showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: ((context) => FilterPage())
                ),
              ),
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

          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
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