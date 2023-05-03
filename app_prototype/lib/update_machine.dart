import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'package:vendi_app/machine_bottom_sheet.dart';
import 'backend/message_helper.dart';
import 'backend/user_helper.dart';
import 'bottom_bar.dart';
import 'backend/camera_helper.dart';



class UpdateMachinePage extends StatefulWidget {
  const UpdateMachinePage({Key? key}) : super(key: key);

  @override
  _UpdateMachinePageState createState() => _UpdateMachinePageState();
}

class _UpdateMachinePageState extends State<UpdateMachinePage> {
  late List<CameraDescription> cameras;
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
  }

  Future<void> uploadImage(String imagePath) async {
    try {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
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

  Future<void> deleteImage(String imageUrl) async {
    try {
      // Get a reference to the image file in Firebase Storage
      Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      // Delete the image file
      await imageRef.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Error deleting image: $e');
    }
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
                    onPressed: () async{
                      imagePath = (await openCamera(context))!;
                      if(imagePath.isNotEmpty)
                      {
                        pictureTaken = 1;
                      }
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
                    print(value);
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
                                    onPressed: () async {
                                      await FirebaseHelper().updateMachine(selectedMachine!);
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  //Creating a machine class object out of the choices made by the user
                                  TextButton(
                                    onPressed: () async {
                                      int cap = await getUserCap() ?? 0;
                                      DateTime? timeAfter24HoursStored = await getTimeAfter24Hours();
                                      //If cap is 90, and 24 hours has passed, get the time that the last picture was taken
                                      //(which would be this if statement) and add 24 hours to it and display message with time remaining.
                                      //Check to see if the value is Dec 31, 1969 4pm utc because that is the default when a new user is made.
                                      DateTime targetDate = DateTime.utc(1969, 12, 31, 16, 0);

                                      if (cap >= 90 && (timeAfter24HoursStored == null || DateTime.now().isAfter(timeAfter24HoursStored) || timeAfter24HoursStored.isAtSameMomentAs(targetDate))) {
                                        await setUserCap(-cap); // Make the cap value zero
                                        DateTime? timeTaken = await getImageTakenTime(imageUrl);

                                        if (timeTaken != null) {
                                          print('Image was taken at: $timeTaken');
                                          DateTime timeAfter24Hours = timeTaken.add(Duration(hours: 24)); // Add 24hrs
                                          print('Time after 24 hours: $timeAfter24Hours');

                                          // Calculate the time left
                                          Duration timeLeft = timeAfter24Hours.difference(DateTime.now());
                                          await setTimeAfter24Hours(timeAfter24Hours);

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
                                        }
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context) =>
                                            const BottomBar()),
                                        );
                                      } else if (cap < 90 && timeAfter24HoursStored != null && DateTime.now().isBefore(timeAfter24HoursStored)) {
                                        Duration timeLeft = timeAfter24HoursStored.difference(DateTime.now());
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
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context) =>
                                            const BottomBar()),
                                        );
                                      }else {
                                        String imagePathBefore = selectedMachine!.imagePath;
                                        await deleteImage(imagePathBefore);
                                        await uploadImage(imagePath);
                                        selectedMachine!.imagePath = imageUrl;
                                        FirebaseHelper().updateMachine(selectedMachine!);
                                        await setUserPoints(15); // Call the updatePoints function to add 30 points for adding a machine
                                        await setUserCap(15);
                                        Navigator.pop(context);
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context) =>
                                            const BottomBar()),
                                        );
                                        showConfettiDialog(context, 'You\'ve earned 15 Vendi points!');
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
  Future<String?> openCamera(BuildContext context) async {
    // Ensure that there is a camera available on the device
    if (cameras.isEmpty) {
      showMessage(context, 'Uh Oh!', 'Camera not available');
      return null;
    }

    // Check if the user has granted camera permission
    PermissionStatus cameraPermission = await Permission.camera.status;
    if (cameraPermission != PermissionStatus.granted) {
      // Request camera permission
      PermissionStatus permissionStatus = await Permission.camera.request();
      if (permissionStatus == PermissionStatus.denied) {
        // Permission denied show warning
        showWarning2(context, "App require access to camera... Press allow camera to allow the camera.");
        // Request camera permission again
        PermissionStatus permissionStatus2 = await Permission.camera.request();
        if (permissionStatus2 != PermissionStatus.granted) {
          // Permission still not granted, return null
          showMessage(context, 'Uh Oh!', 'Camera permission denied');
          return null;
        }
      } else if (permissionStatus != PermissionStatus.granted) {
        // Permission not granted, return null
        showMessage(context, 'Uh Oh!', 'Camera permission denied');
        return null;
      }
    }

    // Take the first camera in the list
    CameraDescription camera = cameras[0];

    // Open the camera and store the resulting CameraController
    CameraController controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();

    // Navigate to the CameraScreen and pass the CameraController to it
    String? imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(controller),
      ),
    );
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }
    return imagePath;
  }
}

