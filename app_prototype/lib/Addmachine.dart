import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vendi_app/backend/firebase_helper.dart';
import 'backend/machine_class.dart';
import 'bottom_bar.dart';

const List<String> list = <String>['I don\'t know', 'Yes', 'No'];
late String machineImage;
String imageUrl = ' ';

class AddMachinePage extends StatefulWidget {
  const AddMachinePage({Key? key}) : super(key: key);

  @override
  _AddMachinePageState createState() => _AddMachinePageState();
}

class _AddMachinePageState extends State<AddMachinePage> {
  late List<CameraDescription> cameras;
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  bool _isSnackSelected = false;
  bool _isDrinkSelected = false;
  bool _isSupplySelected = false;
  Position? _currentPosition;
  late int _selectedValueOperational = 2;
  late int _selectedValueCash = 2;
  late int _selectedValueCard = 2;
  late int _selectedValueStock = 2;

  @override
  void initState() {
    super.initState();
    // Get a list of available cameras on the device
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
    });
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  _getCurrentLocation() async {
    // Check if location permission is granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permission if it is not granted
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // User has denied location permission, handle the error
        if (kDebugMode) {
          print('Location permission denied');
        }
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
      if (kDebugMode) {
        print(e);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    _getCurrentLocation();

    return Scaffold(
      appBar: AppBar(
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
              const SizedBox(height: 16.0),
              const Text('Please take a front facing picture of the machine*',
                  style: TextStyle(fontSize: 16)),
              //camera icon
              Center(
                child: IconButton(
                    onPressed: () {
                      openCamera();
                    },
                    icon: const Icon(Icons.camera_alt)),
              ),
              const SizedBox(height: 40.0),
              //input fields
              const Text('Building Name*', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _buildingController,
              ),
              const SizedBox(height: 16.0),
              const Text('Floor Number*', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _floorController,
              ),
              const SizedBox(height: 40.0),
              const Text('Select Machine Type(s)*',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: const Text('Snack'),
                value: _isSnackSelected,
                onChanged: (value) {
                  setState(() {
                    _isSnackSelected = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Drink'),
                value: _isDrinkSelected,
                onChanged: (value) {
                  setState(() {
                    _isDrinkSelected = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Supply'),
                value: _isSupplySelected,
                onChanged: (value) {
                  setState(() {
                    _isSupplySelected = value!;
                  });
                },
              ),
              const SizedBox(height: 40.0),
              const Text('Select Machine Options',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),
              const Text('Is the machine currently operating?',
                  style: TextStyle(fontSize: 16)),
              DropdownButton(
                value: _selectedValueOperational,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Not Sure'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedValueOperational = value!;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              const Text('Is the machine stocked more than halfway?',
                  style: TextStyle(fontSize: 16)),
              DropdownButton(
                value: _selectedValueStock,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Not Sure'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedValueStock = value!;
                  });
                },
              ),
              //const DropdownButtonMenu(),
              const SizedBox(height: 20.0),
              const Text('Does the machine take cash?',
                  style: TextStyle(fontSize: 16)),
              DropdownButton(
                value: _selectedValueCash,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Not Sure'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedValueCash = value!;
                  });
                },
              ),
              //const DropdownButtonMenu(),
              const SizedBox(height: 20.0),
              const Text('Does the machine take card?',
                  style: TextStyle(fontSize: 16)),
              DropdownButton(
                value: _selectedValueCard,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Not Sure'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedValueCard = value!;
                  });
                },
              ),
              // const DropdownButtonMenu(),
              const SizedBox(height: 20.0),
              const Text('*Required', style: TextStyle(color: Colors.red)),
              const SizedBox(height: 20.0),

              Center(
                //submit button
                child: TextButton(
                    onPressed: () {
                      setState(() {
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
                                    setState(() {
                                      if (_isDrinkSelected == true) {
                                        Machine test1 = Machine(
                                          id: '',
                                          name: _buildingController.text,
                                          desc: _floorController.text,
                                          lat: _currentPosition!.latitude,
                                          lon: _currentPosition!.longitude,
                                          imagePath: imageUrl,
                                          isFavorited: 0,
                                          icon: "assets/images/BlueMachine.png",
                                          card: 1,
                                          cash: 1,
                                          operational: _selectedValueOperational,
                                          stock: 1,
                                        );
                                        FirebaseHelper().addMachine(test1);
                                        _isDrinkSelected = false;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BottomBar()),
                                        );
                                      } else if (_isSnackSelected == true) {
                                        Machine test2 = Machine(
                                          id: '',
                                          name: _buildingController.text,
                                          desc: _floorController.text,
                                          lat: _currentPosition!.latitude,
                                          lon: _currentPosition!.longitude,
                                          imagePath: imageUrl,
                                          isFavorited: 0,
                                          icon: "assets/images/PinkMachine.png",
                                          card: 1,
                                          cash: 1,
                                          operational: _selectedValueOperational,
                                          stock: 1,
                                        );
                                        FirebaseHelper().addMachine(test2);
                                        _isSnackSelected = false;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BottomBar()),
                                        );
                                      } else if (_isSupplySelected == true) {
                                        Machine test3 = Machine(
                                          id: '',
                                          name: _buildingController.text,
                                          desc: _floorController.text,
                                          lat: _currentPosition!.latitude,
                                          lon: _currentPosition!.longitude,
                                          imagePath: imageUrl,
                                          isFavorited: 0,
                                          icon: "assets/images/YellowMachine.png",
                                          card: 1,
                                          cash: 1,
                                          operational: _selectedValueOperational,
                                          stock: 1,
                                        );
                                        FirebaseHelper().addMachine(test3);
                                        _isSupplySelected = false;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BottomBar()),
                                        );
                                      }
                                    });
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
                      });
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
      body: CameraPreview(widget.controller),
      // Add a floating action button to take pictures
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Take a picture and store it as a file
            var image = await widget.controller.takePicture();

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
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              await uploadImage(image.path);
                              //selectedMachine?.imagePath = image.path;
                              //dbHelper.updateMachine(selectedMachine!);
                          }),
                    ]),
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
