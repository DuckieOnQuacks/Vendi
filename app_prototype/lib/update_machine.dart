import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'package:vendi_app/machine_bottom_sheet.dart';
import 'backend/flask_helper.dart';
import 'bottom_bar.dart';

late String machineImage;
String imageUrl = ' ';
int pictureTaken = 0;

class UpdateMachinePage extends StatefulWidget {
  const UpdateMachinePage({Key? key}) : super(key: key);

  @override
  _UpdateMachinePageState createState() => _UpdateMachinePageState();
}

class _UpdateMachinePageState extends State<UpdateMachinePage> {
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
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //photo
              const SizedBox(height: 16.0),
              const Text('Please take a front facing picture of the machine*',
                  style: TextStyle(fontSize: 20,  fontWeight: FontWeight.bold)),
              //camera icon
              Center(
                child: IconButton(
                    onPressed: () {
                      openCamera();
                    },
                    icon: const Icon(Icons.camera_alt)),
              ),
              const SizedBox(height: 40.0),
              //operating
              const SizedBox(height: 16.0),
              const Text('Is the machine currently operating?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10.0),
              const Text('Note: If you did not attempt to buy anything from the machine, please select "Not Sure"',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
              const SizedBox(height: 10.0),
              DropdownButton(
                value: selectedMachine?.operational,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Not Sure'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Yes'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedMachine?.operational = value!;
                    FirebaseHelper().updateMachine(selectedMachine!);
                  });
                },
              ),
              const SizedBox(height: 20.0),
              const Text('*Required', style: TextStyle(color: Colors.red)),
              const SizedBox(height: 20.0),
              Center(
                //submit button
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        if(pictureTaken == 0) {
                          // Show alert dialog if any of the required fields are null
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Missing Information'),
                                content: const Text('Please enter all information.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Submission'),
                                content: const Text(
                                    'Are you sure you want to submit a form for a new vending machine?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  //Creating a machine class object out of the choices made by the user
                                  TextButton(
                                    onPressed: () {
                                      selectedMachine?.imagePath = imageUrl;
                                      FirebaseHelper().updateMachine(selectedMachine!);
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                          const BottomBar()),
                                      );
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ],
                              );
                            },
                          ).then((value) {
                            if (value != null && value == true) {
                              // Perform deletion logic here
                            }
                          });
                        }});
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
////////////////////////////////////////////////////////////////////

  void openCamera() async {
    // Ensure that there is a camera available on the device
    if (cameras.isEmpty) {
      return;
    }

    // Take the first camera in the list (usually the back camera)
    CameraDescription camera = cameras[0];

    // Open the camera and store the resulting CameraController
    CameraController controller =
    CameraController(camera, ResolutionPreset.high);
    await controller.initialize();

    // Navigate to the CameraScreen and pass the CameraController to it
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(controller),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen(this.controller, {super.key});

  final CameraController controller;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  Future<void> uploadImage(String imagePath) async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    // Get a reference to the Firebase Storage bucket
    Reference storageRef = FirebaseStorage.instance.ref();
    // Upload the image file to Firebase Storage
    Reference uploadTask = storageRef.child('images');
    Reference referenceImage = uploadTask.child(uniqueFileName);
    await referenceImage.putFile(File(imagePath));
    imageUrl = await referenceImage.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Add the camera preview widget to the stack
          Positioned.fill(
            child: CameraPreview(widget.controller),
          ),

          // Add the guidelines to the stack
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 7,
                ),
              ),
              width: 300,
              height: 600,
            ),
          ),
        ],
      ),
      // Add a floating action button to take pictures
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Take a picture and store it as a file
            var image = await widget.controller.takePicture();

            // Navigate to the confirmation screen
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              // Checks whether or not the picture is fine for the user
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Is this image ok?"),
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        bool status = await predict(image);
                        if (status == true) {
                          pictureTaken = 1;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          await uploadImage(image.path);
                        }
                        else {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context, builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  "Image not accepted. Please try again."),
                              actions: [
                                ElevatedButton(
                                  child: const Text("Ok"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          },
                          );
                        }
                      },
                    ),
                  ],
                ),
                body: Image.file(File(image.path)),
              );
            }));
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