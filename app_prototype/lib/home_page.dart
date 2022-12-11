import 'dart:math';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vendi_app/machine_bottom_sheet.dart';


const currentLocation =  LatLng(39.54411893434308, -119.8160761741225);
const machines = [
  LatLng(39.541124878293125, -119.8146587094217),
  LatLng(39.54687777057448, -119.81770069829096),
  LatLng(39.53783496758882, -119.8180473779956),
  LatLng(39.54250126604798, -119.8162125037587),
];

const machineType = [
  'assets/images/BlueMachine.png',
  'assets/images/PinkMachine.png',
  'assets/images/YellowMachine.png',
];

class Homepage extends StatefulWidget
{
  const Homepage({Key? key}) : super(key: key);
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Maps")),
      body: GoogleMap(
        mapToolbarEnabled: false,
        initialCameraPosition: const CameraPosition(
          target: currentLocation,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          for(var i = 0; i <= machines.length; i++)
            {
              addMarker('Test Marker $i', machines[i]);
            }
        },
        markers: _markers.values.toSet(),
      ),
    );
  }

  addMarker(String id, LatLng location) async {
    var markerIcon = await getBytesFromAsset(getRandomElement(machineType), 100);
    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(
        title: "Name of machine",
        snippet: "Specific location of machine",
        onTap: () {
          showModalBottomSheet(context: context, builder: (context) {
            return const MachineBottomSheet();
          });
        },
      ),
      icon: BitmapDescriptor.fromBytes((markerIcon)),
    );
    _markers[id] = marker;
    setState(() {});
  }

  T getRandomElement<T>(List<T> list) 
  {
    final random = new Random();
    var i = random.nextInt(list.length);
    return list[i];
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
}


