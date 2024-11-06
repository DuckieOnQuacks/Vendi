import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'flask_helper.dart';
import 'message_helper.dart';

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
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            )
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          Navigator.of(context).pop();
                          Navigator.of(context).pop(image.path);
                          //Show message when Ai approves
                          showMessage(context, 'Woohoo!', 'Image Updated Successfully');
                        }
                        else {
                          Navigator.of(context).pop();
                          showWarning(context, 'Image is not a vending machine.');
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