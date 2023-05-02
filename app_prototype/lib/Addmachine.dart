import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'package:vendi_app/backend/camera_helper.dart';
import 'backend/machine_class.dart';
import 'backend/message_helper.dart';
import 'backend/user_helper.dart';
import 'bottom_bar.dart';

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
  late String machineImage;
  String imageUrl = ' ';
  String imagePath = ' ';
  int pictureTaken = 0;

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

  Future<void> uploadImage(String imagePath) async {
    try {
      String uniqueFileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      // Get a reference to the Firebase Storage bucket
      Reference storageRef = FirebaseStorage.instance.ref();
      // Upload the image file to Firebase Storage
      Reference uploadTask = storageRef.child('images');
      Reference referenceImage = uploadTask.child(uniqueFileName);
      await referenceImage.putFile(File(imagePath));
      imageUrl = await referenceImage.getDownloadURL();
      print('Image uploaded successfully');
    } catch (e) {
      print('Error uploading image.');
    }
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
                    onPressed: () async {
                      imagePath = await openCamera(context);
                      if (imagePath.isNotEmpty) {
                        pictureTaken = 1;
                      }
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
                decoration: const InputDecoration(hintText: 'Ex: 2'),
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
                      print('Building: ${_buildingController.text}');
                      print('Floor: ${_floorController.text}');
                      print('Picture Taken Add: $pictureTaken');
                      setState(() {
                        if (_buildingController.text.isEmpty ||
                            _floorController.text.isEmpty ||
                            pictureTaken == 0) {
                          // Show alert dialog if any of the required fields are null
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  buttonPadding: EdgeInsets.all(15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 10,
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.pink,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Warning',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text('Missing Information. Please fill out all fields and try again.'),
                                  actions: <Widget>[
                                  ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.pinkAccent,
                                onPrimary: Colors.white,
                              ),
                              child: const Text('Ok'),
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
                                buttonPadding: EdgeInsets.all(15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.pink,
                                    ),
                                    Text(
                                      'Confirm Submission',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                content: const Text(
                                    'Are you sure you want to submit a form for a new vending machine?'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey[300],
                                      onPrimary: Colors.black54,
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                  //Creating a machine class object out of the choices made by the user
                                  ElevatedButton(
                                    onPressed: () async {
                                      int cap = await getUserCap() ?? 0;
                                      DateTime? timeAfter24HoursStored =
                                      await getTimeAfter24Hours();
                                      //If cap is 90, and 24 hours has passed, get the time that the last picture was taken
                                      //(which would be this if statement) and add 24 hours to it and display message with time remaining.
                                      //Check to see if the value is Dec 31, 1969 4pm utc because that is the default when a new user is made.
                                      DateTime targetDate =
                                      DateTime.utc(1969, 12, 31, 16, 0);

                                      if (cap >= 90 &&
                                          (timeAfter24HoursStored == null ||
                                              DateTime.now().isAfter(
                                                  timeAfter24HoursStored) ||
                                              timeAfter24HoursStored
                                                  .isAtSameMomentAs(
                                                  targetDate))) {
                                        await setUserCap(
                                            -cap); // Make the cap value zero
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
                                                      'Upload again in: ${timeLeft
                                                          .inHours} hours, and ${timeLeft
                                                          .inMinutes.remainder(
                                                          60)} minutes'),
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
                                        }
                                      } else if (cap < 90 &&
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
                                                    'Upload again in: ${timeLeft
                                                        .inHours} hours, and ${timeLeft
                                                        .inMinutes.remainder(
                                                        60)} minutes'),
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
                                        await uploadImage(imagePath);
                                        setState(() {
                                          if (_isDrinkSelected == true) {
                                            Machine test1 = Machine(
                                                id: '',
                                                name: _buildingController.text,
                                                desc: _floorController.text,
                                                lat: _currentPosition!.latitude,
                                                lon:
                                                _currentPosition!.longitude,
                                                imagePath: imageUrl,
                                                icon:
                                                "assets/images/BlueMachine.png",
                                                card: _selectedValueCard,
                                                cash: _selectedValueCash,
                                                operational:
                                                _selectedValueOperational,
                                                upvotes: 0,
                                                dislikes: 0);
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
                                                lon:
                                                _currentPosition!.longitude,
                                                imagePath: imageUrl,
                                                icon:
                                                "assets/images/PinkMachine.png",
                                                card: _selectedValueCard,
                                                cash: _selectedValueCash,
                                                operational:
                                                _selectedValueOperational,
                                                upvotes: 0,
                                                dislikes: 0);
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
                                                lon:
                                                _currentPosition!.longitude,
                                                imagePath: imageUrl,
                                                icon:
                                                "assets/images/YellowMachine.png",
                                                card: _selectedValueCard,
                                                cash: _selectedValueCash,
                                                operational:
                                                _selectedValueOperational,
                                                upvotes: 0,
                                                dislikes: 0);
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
                                        await setUserPoints(
                                            30); // Call the updatePoints function to add 30 points for adding a machine
                                        await setUserCap(
                                            30); // Call the updateCap function to increase the cap value by 10
                                        showConfettiDialog(context,
                                            'You\'ve earned 30 Vendi Points');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.pinkAccent,
                                      onPrimary: Colors.white,
                                    ),
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
  Future<String> openCamera(BuildContext context) async {
    // Ensure that there is a camera available on the device
    if (cameras.isEmpty) {
      showMessage(context, 'Uh Oh!', 'Camera not available');
    }
    // Take the first camera in the list (usually the back camera)
    CameraDescription camera = cameras[0];

    // Open the camera and store the resulting CameraController
    CameraController controller =
    CameraController(camera, ResolutionPreset.high);
    await controller.initialize();

    // Navigate to the CameraScreen and pass the CameraController to it
    String imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(controller),
      ),
    );
    return imagePath;
  }
}


