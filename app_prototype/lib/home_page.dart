import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vendi_app/machine_bottom_sheet.dart';
import 'package:vendi_app/machine_class.dart';

// Most of the code on this page was developed by the team using the flutter framework
// One helper method getBytesFromAsset was sourced from https://github.com/flutter/flutter/issues/34657 to rescale images in code.

// List of real machines and their locations
const currentLocation = LatLng(39.54411893434308, -119.8160761741225);
final machines = [
  MachineClass("Ansari Building", 'assets/images/BlueMachine.png' , 'Located on the second floor', 0, LatLng(39.54006690730848, -119.81491866643591)),
  MachineClass("Schulich Lecture Hall", 'assets/images/PinkMachine.png' , 'Located on the first floor', 1, LatLng(39.54105463820153, -119.81470308380608)),
  MachineClass("William Raggio Building", 'assets/images/BlueMachine.png' , 'Located on the second floor', 2, LatLng(39.54235203232871, -119.81518074721858)),
  MachineClass("The Joe", 'assets/images/YellowMachine.png' , 'Located on the first floor', 3, LatLng(39.54466081663702, -119.81626193095232)),
  MachineClass("Panera Bread", 'assets/images/BlueMachine.png' , 'Located on the first floor', 4, LatLng(39.54237902737183, -119.81619429719166)),
  MachineClass("Reynolds School Of Journalism", 'assets/images/PinkMachine.png' , 'Located on the first floor', 5, LatLng(39.541418046522196, -119.81528115652931)),
  MachineClass("Mathewson Knowledge Center", 'assets/images/PinkMachine.png' , 'Located on the first floor', 5, LatLng(39.543534319081886, -119.81577690579334)),
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
    // The stateless widget for the google maps home page
    return Scaffold(
      appBar: AppBar(title: const Text("Google Maps"), automaticallyImplyLeading: false,),
      body: GoogleMap(
        mapToolbarEnabled: false,
        initialCameraPosition: const CameraPosition(
          target: currentLocation,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          for(var i = 0; i < machines.length; i++)
            {
              addMarker('Test Marker $i', machines[i].machineLoc, i);
            }
        },
        markers: _markers.values.toSet(),
      ),
    );
  }

  // Helper method for adding a marker to the map
  addMarker(String id, LatLng location, int i) async {
    var markerIcon = await getBytesFromAsset(machines[i].asset, 100);
    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(
        title: machines[i].name,
        snippet: machines[i].machineDesc,
        onTap: () {
          // Opens the bottom sheet when the screen is tapped
          showModalBottomSheet(context: context, builder: (context) {
            return MachineBottomSheet(machines[i]);
          });
        },
      ),
      icon: BitmapDescriptor.fromBytes((markerIcon)),
    );
    _markers[id] = marker;
    setState(() {});
  }

  // Sourced from https://github.com/flutter/flutter/issues/34657 to resize images in code
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
}


