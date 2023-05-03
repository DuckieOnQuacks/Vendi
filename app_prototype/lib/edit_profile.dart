import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'backend/user_helper.dart';
import 'backend/message_helper.dart';


late final user = FirebaseAuth.instance.currentUser!;
String imagePath = '';
List<String> profilePictures = [
  'assets/images/profile_pic1.png',
  'assets/images/profile_pic2.png',
  'assets/images/profile_pic3.png',
  'assets/images/profile_pic4.png',
  'assets/images/KermitProfile.jpg',];
String firstName = '';
String lastName = '';
String email = '';
String password = '';



class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}


class _EditProfileState extends State<EditProfile> {
  //late List<CameraDescription> cameras;

  @override
  /*void initState() {
    super.initState();
    // Get a list of available cameras on the device
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
    });
  }*/

  void _selectProfilePicture() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            child: ListView.builder(
              itemCount: profilePictures.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () {
                    setState(() {
                      imagePath = profilePictures[index];
                    });
                    Navigator.pop(context);
                  },
                  leading: Image.asset(
                    profilePictures[index],
                    height: 50,
                    width: 50,
                  ),
                );
              },
            ),
          );
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
          child: SingleChildScrollView(
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
                        : Image.asset(
                      imagePath,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _selectProfilePicture();
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.all(25)),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.pink),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.grey)
                              )
                          )
                      ),
                      child: const Text('Select a profile picture',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)
                      ),
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
                          obscureText: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'First Name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                            hintText: 'Last Name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  //Password Field
                  const SizedBox(height: 10),

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
                            hintText: 'Email',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

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
                  const SizedBox(height: 10),

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
                            hintText: 'Confirm Password',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  //Update Profile Button
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: ElevatedButton(
                          onPressed: () {
                            showMessage(context, 'Hooray!', 'You have successfully updated your profile.');
                            setState(() {});
                          },
                          style: ButtonStyle(
                              padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  const EdgeInsets.all(25)),
                              backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.pink),
                              shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Colors.grey),
                                  )
                              )
                          ),
                          child: const Text('Update Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)
                          )
                      )
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        )
    );
  }

  void openCamera() async {
// final cameras = await availableCameras();
// final camera = cameras.first;
// final pickedImage =
// await ImagePicker().getImage(source: ImageSource.camera);
// setState(() {
// imagePath = pickedImage!.path;
// });
  }

  void createAlertDialog(BuildContext context) {
    final alertDialog = AlertDialog(
      title: const Text("Profile Updated!"),
      content: const Text("Your profile has been updated successfully!"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Ok'))
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }
}


/*void openCamera() async {
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
}*/

createAlertDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //Will Add if statement to check if updated fields
          //meet all requirements and not currently
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

/*class CameraScreen extends StatefulWidget {
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
            }
            )
            );
          } catch (e) {
            // If an error occurs, log the error to the console
            debugPrint(e.toString());
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}*/