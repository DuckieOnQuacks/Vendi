import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendi_app/home_page.dart';


const LatLng currentLocation = LatLng(39.5299, -119.8143);

class Homepage extends StatefulWidget
{
  const Homepage({Key? key}) : super(key: key);
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    // Get a list of available cameras on the device
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text(""),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              openCamera();
            },
            icon: Icon(Icons.camera_alt),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: currentLocation,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          addMarker('Test Marker', currentLocation);
        },
        markers: _markers.values.toSet(),
      ),
    );
  }

  addMarker(String id, LatLng location) async {
    var markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/BlueMachine.png',
    );

    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: const InfoWindow(
        title: "Name of machine",
        snippet: "Specific location of machine",
      ),
      icon: markerIcon,
    );
    _markers[id] = marker;
    setState(() {});
  }

  // Method that opens the camera
  void openCamera() async {
    // Ensure that there is a camera available on the device
    if (cameras == null || cameras.isEmpty) {
      return;
    }

    // Take the first camera in the list (usually the back camera)
    CameraDescription camera = cameras[0];

    // Open the camera and store the resulting CameraController
    CameraController controller = CameraController(camera, ResolutionPreset.high);
    await controller.initialize();

    // Navigate to the CameraScreen and pass the CameraController to it
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(controller),
      ),
    );
  }
}


// This is an example CameraScreen widget that you could use to display
// the camera preview and take pictures. You would need to import the
// necessary packages and create this widget in your app.
class CameraScreen extends StatefulWidget {
  CameraScreen(this.controller);

  final CameraController controller;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraPreview(widget.controller),
      // Add a floating action button to take pictures
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Take a picture and store it as a file
            await widget.controller.takePicture();
          } catch (e) {
            // If an error occurs, log the error to the console
            print(e);
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}


