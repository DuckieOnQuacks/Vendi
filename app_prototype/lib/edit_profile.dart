import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

// All code on this page was developed by the team using the flutter framework

String imagePath = '';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              SizedBox(
                height: 150,
                width: 150,
                child: imagePath == ''
                    ? Image.asset(
                        'assets/images/KermitProfile.jpg',
                        scale: 4,
                      )
                    : Image.file(File(imagePath), scale: 4),
              ),

              const SizedBox(height: 50),

              //Uploading New Profile Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ElevatedButton(
                  onPressed: () {
                    openCamera();
                  },
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.all(25)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.pink),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.grey)))),
                  child: const Text('Upload New Profile Picture',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),

                  //const SizedBox(height: 10),
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //Create Space between both boxes
              //Password text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: TextField(
                      obscureText: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //Phone Number Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: TextField(
                      obscureText: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Phone Number',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              //Password Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: TextField(
                      obscureText: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        //color: Colors.white,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              //Update Profile Button
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ElevatedButton(
                      onPressed: () {
                        createAlertDialog(context);
                        setState(() {});
                      },
                      style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  const EdgeInsets.all(25)),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.pink),
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.grey)))),
                      child: const Text('Update Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20))))
            ]))));
  }

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
    setState(() {});
  }
}

createAlertDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //Will Add if statement to check if updated fields
          //meet all requriements and not currently
          //equal to current fields
          title: const Text("Profile Update Successful!"),

          actions: <Widget>[
            MaterialButton(
              child: Image.asset(
                'assets/images/YellowMachine.png',
                scale: 6,
              ),
              onPressed: () {},
            )
          ],
        );
      });
}

class CameraScreen extends StatefulWidget {
  const CameraScreen(this.controller, {super.key});

  final CameraController controller;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Add the camera preview widget to the stack
          Positioned.fill(
            child: CameraPreview(widget.controller),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Take a picture and store it as a file
            var image = await widget.controller.takePicture();

            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
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
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            imagePath = image.path;
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
