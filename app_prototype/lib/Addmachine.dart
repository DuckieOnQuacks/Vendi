import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'backend/machine_class.dart';
import 'backend/user_helper.dart';
import 'bottom_bar.dart';
import 'package:vendi_app/backend/flask_helper.dart';

late String machineImage;
String imageUrl = ' ';
int pictureTakenAdd = 0;

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
  late int _selectedValueCash = 0;
  late int _selectedValueCard = 0;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    // Get a list of available cameras on the device
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
    });
    getCurrentLocation();
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
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
      if (mounted) {
        // Add this line to check if widget is mounted
        setState(() {
          _currentPosition = position;
        });
      }
    }).catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getCurrentLocation();
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
                decoration:
                    const InputDecoration(hintText: 'Ex: Davidson Building'),
                controller: _buildingController,
              ),
              const SizedBox(height: 16.0),
              const Text('Floor Number*', style: TextStyle(fontSize: 16)),
              TextField(
                decoration: const InputDecoration(hintText: 'Ex: Floor 2'),
                controller: _floorController,
              ),
              const SizedBox(height: 40.0),
              const Text('Select Machine Type*',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              RadioListTile<int>(
                title: const Text('Snack'),
                value: 0,
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value;
                    _isSnackSelected = true;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('Drink'),
                value: 1,
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value;
                    _isDrinkSelected = true;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('Supply'),
                value: 2,
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value;
                    _isSupplySelected = true;
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
                    value: 2,
                    child: Text('Not Sure'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedValueOperational = value!;
                  });
                },
              ),

              const SizedBox(height: 20.0),
              const Text('Does the machine take cash?*',
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
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedValueCash = value!;
                  });
                },
              ),
              //const DropdownButtonMenu(),
              const SizedBox(height: 20.0),
              const Text('Does the machine take card?*',
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
                        if (_buildingController.text.isEmpty ||
                            _floorController.text.isEmpty ||
                            pictureTakenAdd == 0) {
                          // Show alert dialog if any of the required fields are null
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Missing Information'),
                                content:
                                    const Text('Please enter all information.'),
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
                                    onPressed: () async {
                                      int cap = await getUserCap() ?? 0;
                                      DateTime? timeAfter24HoursStored =
                                          await getTimeAfter24Hours();
                                      //If cap is 90, and 24 hours has passed, get the time that the last picture was taken
                                      //(which would be this if statement) and add 24 hours to it and display message with time remaining.
                                      if (cap >= 90 &&
                                          (timeAfter24HoursStored == null ||
                                              DateTime.now().isAfter(
                                                  timeAfter24HoursStored))) {
                                        await updateUserCap(-cap); // Make the cap value zero
                                        DateTime? timeTaken =
                                            await getImageTakenTime(imageUrl);
                                        if (timeTaken != null) {
                                          print(
                                              'Image was taken at: $timeTaken');
                                          DateTime timeAfter24Hours =
                                              timeTaken.add(Duration(
                                                  hours: 24)); // Add 24hrs
                                          print(
                                              'Time after 24 hours: $timeAfter24Hours');

                                          // Calculate the time left
                                          Duration timeLeft = timeAfter24Hours
                                              .difference(DateTime.now());
                                          await setTimeAfter24Hours(
                                              timeAfter24Hours);

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const BottomBar()),
                                          );
                                          WidgetsBinding.instance!
                                              .addPostFrameCallback((_) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      'Upload Limit Reached'),
                                                  content: Text(
                                                      'Upload again in: ${timeLeft.inHours} hours, and ${timeLeft.inMinutes.remainder(60)} minutes'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                        } else {
                                          print(
                                              'Could not fetch image metadata.');
                                        }
                                        //Otherwise, add the machine like normal and give them points and increase daily cap.
                                      }
                                      //If statement to check and see if the user would like to submit to see remaining time.
                                      else if (cap >= 90 &&
                                          timeAfter24HoursStored != null &&
                                          DateTime.now().isBefore(
                                              timeAfter24HoursStored)) {
                                        Duration timeLeft =
                                            timeAfter24HoursStored
                                                .difference(DateTime.now());

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BottomBar()),
                                        );
                                        WidgetsBinding.instance!
                                            .addPostFrameCallback((_) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Upload Limit Reached'),
                                                content: Text(
                                                    'Upload again in: ${timeLeft.inHours} hours, and ${timeLeft.inMinutes.remainder(60)} minutes'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        });
                                      } else {
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
                                              icon:
                                                  "assets/images/BlueMachine.png",
                                              card: _selectedValueCard,
                                              cash: _selectedValueCash,
                                              operational:
                                                  _selectedValueOperational,
                                            );
                                            FirebaseHelper()
                                                .addMachine(test1)
                                                .then((_) async {
                                              final machineId =
                                                  await FirebaseHelper()
                                                      .getMachineIdByLocation(
                                                          test1.lat, test1.lon);
                                              print(machineId);
                                              if (machineId != null) {
                                                addMachineToUser(machineId);
                                              }
                                              _isDrinkSelected = false;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const BottomBar()),
                                              );
                                            });
                                          } else if (_isSnackSelected == true) {
                                            Machine test2 = Machine(
                                              id: '',
                                              name: _buildingController.text,
                                              desc: _floorController.text,
                                              lat: _currentPosition!.latitude,
                                              lon: _currentPosition!.longitude,
                                              imagePath: imageUrl,
                                              isFavorited: 0,
                                              icon:
                                                  "assets/images/PinkMachine.png",
                                              card: _selectedValueCard,
                                              cash: _selectedValueCash,
                                              operational:
                                                  _selectedValueOperational,
                                            );
                                            FirebaseHelper()
                                                .addMachine(test2)
                                                .then((_) async {
                                              final machineId =
                                                  await FirebaseHelper()
                                                      .getMachineIdByLocation(
                                                          test2.lat, test2.lon);
                                              if (machineId != null) {
                                                addMachineToUser(machineId);
                                              }
                                              _isSnackSelected = false;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const BottomBar()),
                                              );
                                            });
                                          } else if (_isSupplySelected ==
                                              true) {
                                            Machine test3 = Machine(
                                              id: '',
                                              name: _buildingController.text,
                                              desc: _floorController.text,
                                              lat: _currentPosition!.latitude,
                                              lon: _currentPosition!.longitude,
                                              imagePath: imageUrl,
                                              isFavorited: 0,
                                              icon:
                                                  "assets/images/YellowMachine.png",
                                              card: _selectedValueCard,
                                              cash: _selectedValueCash,
                                              operational:
                                                  _selectedValueOperational,
                                            );
                                            FirebaseHelper()
                                                .addMachine(test3)
                                                .then((_) async {
                                              final machineId =
                                                  await FirebaseHelper()
                                                      .getMachineIdByLocation(
                                                          test3.lat, test3.lon);
                                              if (machineId != null) {
                                                addMachineToUser(machineId);
                                              }
                                              _isSupplySelected = false;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const BottomBar()),
                                              );
                                            });
                                          }
                                        });
                                        await updateUserPoints(
                                            30); // Call the updatePoints function to add 30 points for adding a machine
                                        await updateUserCap(
                                            30); // Call the updateCap function to increase the cap value by 10
                                      }
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
                        }
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
                          pictureTakenAdd = 1;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          await uploadImage(image.path);
                          pictureTakenAdd = 0;
                        } else {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                        "Image is not a vending machine. AI Confidence:"),
                                    Text(
                                      getJson().toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Text("Please try again."),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    child: const Text("Ok"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
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
