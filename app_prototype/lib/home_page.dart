import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vendi_app/machine_bottom_sheet.dart';
import 'package:vendi_app/backend/machine_class.dart';
import 'main.dart';
import 'Addmachine.dart';


// List of real machines and their locations
//const _currentLocation = LatLng(39.54411893434308, -119.8160761741225);
Position? _currentPosition;

//Machine test = Machine(id: 1, name: "Ansari Building", desc: 'Located on the second floor', lat: 39.54006690730848, lon: -119.81491866643591, imagePath: "", isFavorited: 0, icon: "assets/images/PinkMachine.png");

//Machine test2 = Machine(id: 2, name: "Schulich Lecture Hall", desc: 'Located on the first floor', lat: 39.543534319081886, lon: -119.81577690579334, imagePath: "app_prototype/appdata/machineImages/24E55E52-B42B-4C75-A3AD-042B4C19A059.jpg", isFavorited: 0, icon: "assets/images/BlueMachine.png");

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


  _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator();
    // Check if location permission is granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permission if it is not granted
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // User has denied location permission, handle the error
        print('Location permission denied');
        return;
      }
    }

    // Retrieve the current location if location permission is granted
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentLocation();
    // The stateless widget for the google maps home page
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
          Image.asset('assets/images/logo.png',
          fit: BoxFit.contain,
          height: 32,
        )
  ],
        ),

        actions: [
          IconButton(
              icon: const Icon(Icons.add,
              color: Colors.pink),
              onPressed:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddMachinePage()),
                    //dbHelper.addMachine(test);
                  );
              },
            ),
            ],
            backgroundColor: Colors.white,
            ),

      body: GoogleMap(
                  mapToolbarEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition?.latitude ?? 0.0, _currentPosition?.longitude ?? 0.0),
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
    var markerIcon = await getBytesFromAsset(machines.icon, 100);
    var marker = Marker(
      markerId: MarkerId(machines.id.toString()),
      position: LatLng(machines.lat, machines.lon),
      infoWindow: InfoWindow(
        title: machines.name,
        snippet: machines.desc,
        onTap: () {
          // Opens the bottom sheet when the screen is tapped
          showModalBottomSheet(context: context, builder: (context) {
            return MachineBottomSheet(machines);
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


