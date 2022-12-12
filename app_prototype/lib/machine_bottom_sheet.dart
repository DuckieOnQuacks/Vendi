import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

String displayedImage = '';

class MachineBottomSheet extends StatefulWidget {
  const MachineBottomSheet({super.key});

  @override
  State<MachineBottomSheet> createState() => _MachineBottomSheetState();
}

class _MachineBottomSheetState extends State<MachineBottomSheet> {
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    // Get a list of available cameras on the device
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
    });
  }

  bool? isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Bottom sheets cannot be updated from outside the page so a stateful builder is needed to handle state changes.
          // Currently this checkbox should only work for a single vending machine. Whether or not this should be expanded is tbd.
          StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Checkbox(value: isChecked, onChanged: (bool? checked) {
                setState(() {
                  isChecked = checked;
                });
              });
            },
          ),
          ElevatedButton(onPressed: () {
            setState(() {
              displayedImage = '';
            });
            Navigator.pop(context);
          }, child: const Text("Close Menu")),
          displayedImage == ''? IconButton(
            onPressed: () {
              setState(() {});
              openCamera();
            }, icon: const Icon(Icons.camera_alt),
          ): SizedBox(
            width: 54,
            height: 96,
            child: Image.file(File(displayedImage)),
          ),
        ],
      )
    );
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
    ).then((value)=>setState((){}));
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
            var image = await widget.controller.takePicture();

            await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(title: const Text("Is this image ok?"),
                automaticallyImplyLeading: false,
                leading: IconButton(icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      displayedImage = image.path;
                      debugPrint(displayedImage);
                    }
                  ),
                ]),
                body: Image.file(File(image.path)),
              );
            }
            ));
          } catch (e) {
            // If an error occurs, log the error to the console
            debugPrint(e.toString());
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}