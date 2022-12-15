import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/machine_class.dart';

// All code on this page was developed by the team using the flutter framework

MachineClass? selectedMachine;

class MachineBottomSheet extends StatefulWidget {
  MachineBottomSheet(MachineClass machine)
    {super.key; selectedMachine = machine; }

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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          selectedMachine?.image == ''? Text('Check the box to add this machine to your favorites. Click the Camera icon to upload a photo!', style: GoogleFonts.bebasNeue(fontSize: 25,)) :
              Text('If you\'re happy with the image, click save!', style: GoogleFonts.bebasNeue(fontSize: 25)),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatefulBuilder(builder: (BuildContext context, setState) {

                // Checkbox for favoriting the machine
                return Checkbox(value: selectedMachine?.getFavorited, onChanged: (bool? checked) {
                  setState(() {
                    selectedMachine?.isFavorited = checked!;
                  });
                });
    }),
              // Camera button for opening the camera
              selectedMachine?.image == ''? IconButton(onPressed: ()
              {
                openCamera();
              },
                  icon: const Icon(Icons.camera_alt)) :
                    ElevatedButton( onPressed: () {
                      setState(() {
                      selectedMachine?.image = '';
                      });
                        Navigator.pop(context);
                      },
                      child: const Text("Save")),
            ],
),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              selectedMachine?.image == ''? const SizedBox.shrink() : SizedBox(
                width: 200, height: 250,
                child: Image.file(File(selectedMachine!.image)),
              ),
            ],
          ),

          // Interactable close menu button
          ElevatedButton( onPressed: () {
            setState(() {
              selectedMachine?.image = '';
            });
            Navigator.pop(context);
          },
              child: const Text("Close Menu"))
        ]
      ),
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
              // Checks whether or not the picture is fine for the user
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
                      selectedMachine?.image = image.path;
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