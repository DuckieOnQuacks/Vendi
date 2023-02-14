import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vendi_app/machine_bottom_sheet.dart';
import 'package:vendi_app/machine_class.dart';
import 'main.dart';


// List of real machines and their locations
const currentLocation = LatLng(39.54411893434308, -119.8160761741225);

Machine test = Machine(id: 1, desc: 'coomer', lat: 39.54006690730848, lon: -119.81491866643591, imagePath: "assets/images/BlueMachine.png", isFavorited: 0, icon: "assets/images/BlueMachine.png");

Machine test2 = Machine(id: 2, desc: 'coomer2', lat: 39.543534319081886, lon: -119.81577690579334, imagePath: "assets/images/BlueMachine.png", isFavorited: 0, icon: "assets/images/BlueMachine.png");

//final machines = [
 // MachineClass("Ansari Building", 'assets/images/BlueMachine.png' , 'Located on the second floor', 0, LatLng(39.54006690730848, -119.81491866643591)),
 // MachineClass("Schulich Lecture Hall", 'assets/images/PinkMachine.png' , 'Located on the first floor', 1, LatLng(39.54105463820153, -119.81470308380608)),
 // MachineClass("William Raggio Building", 'assets/images/BlueMachine.png' , 'Located on the second floor', 2, LatLng(39.54235203232871, -119.81518074721858)),
 // MachineClass("The Joe", 'assets/images/YellowMachine.png' , 'Located on the first floor', 3, LatLng(39.54466081663702, -119.81626193095232)),
 // MachineClass("Panera Bread", 'assets/images/BlueMachine.png' , 'Located on the first floor', 4, LatLng(39.54237902737183, -119.81619429719166)),
//  MachineClass("Reynolds School Of Journalism", 'assets/images/PinkMachine.png' , 'Located on the first floor', 5, LatLng(39.541418046522196, -119.81528115652931)),
//  MachineClass("Mathewson Knowledge Center", 'assets/images/PinkMachine.png' , 'Located on the first floor', 5, LatLng(39.543534319081886, -119.81577690579334)),
//];

class Homepage extends StatefulWidget
{
  const Homepage({
    Key? key,
  }) : super(key: key);
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    // The stateless widget for the google maps home page

    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps"), automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed:(){
                dbHelper.addMachine(test2);
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed:(){
              dbHelper.deleteMachine(test2);
            },
          ),
            ],
            ),
      body: GoogleMap(
                  mapToolbarEnabled: false,
                  initialCameraPosition: const CameraPosition(
                    target: currentLocation,
                    zoom: 16,
                  ),
                  onMapCreated: (controller) async {
                    _mapController = controller;
                    var count = await dbHelper.queryRowCount(); //Grab number of rows in db
                    var machineList = await dbHelper.getAllMachines(); //Grab list of machines
                    for(int i = 0; i < count; i++) { //Loop through the machines
                      addMarker(machineList[i]);
                    }
                  },
                  markers: _markers.values.toSet(),
                )
    );
  }


  // Helper method for adding a marker to the map
  addMarker(Machine machines) async {
    var markerIcon = await getBytesFromAsset("assets/images/BlueMachine.png", 100);
    var marker = Marker(
      markerId: MarkerId(machines.id.toString()),
      position: LatLng(machines.lat, machines.lon),
      infoWindow: InfoWindow(
        title: machines.id.toString(),
        snippet: machines.desc,
        onTap: () {
          // Opens the bottom sheet when the screen is tapped
          showModalBottomSheet(context: context, builder: (context) {
            return Scaffold();//MachineBottomSheet(machines);
          });
        },
      ),
      icon: BitmapDescriptor.fromBytes((markerIcon)),
    );
    _markers[machines.id.toString()] = marker;
    setState(() {});
  }


  // Sourced from https://github.com/flutter/flutter/issues/34657 to resize images in code
  Future<Uint8List> getBytesFromAsset(String path, int width) async
  {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer
        .asUint8List();
  }
}


