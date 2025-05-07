import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vendi_app/backend/classes/tflite_helper.dart';
import 'message_helper.dart';

Future<String?> openCamera(BuildContext context) async {
  try {
    // Ensure platform channels are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Check if camera permission is granted
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // Request camera permission
      status = await Permission.camera.request();
      if (status.isDenied) {
        showMessage(context, 'Permission Required',
            'Camera permission is required to take pictures. Please enable it in settings.');
        return null;
      }
    }

    // Get available cameras
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      showMessage(context, 'Error', 'No cameras available');
      return null;
    }

    // Initialize the camera controller
    final controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    // Initialize the camera with proper error handling
    try {
      await controller.initialize();
    } catch (e) {
      controller.dispose();
      showMessage(
          context, 'Error', 'Failed to initialize camera: ${e.toString()}');
      return null;
    }

    // Navigate to the camera screen
    final String? imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(controller),
      ),
    );

    // Always dispose the controller
    controller.dispose();

    return imagePath;
  } catch (e) {
    print('Error in openCamera: $e');
    showMessage(context, 'Error', 'Failed to open camera: ${e.toString()}');
    return null;
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen(this.controller, {super.key});

  final CameraController controller;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isInitialized = false;
  bool _isTFLiteInitialized = false;
  final TFLiteHelper _tfliteHelper = TFLiteHelper();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTFLite();
  }

  Future<void> _initializeTFLite() async {
    try {
      await _tfliteHelper.initialize();
      if (mounted) {
        setState(() {
          _isTFLiteInitialized = true;
        });
      }
      print('TFLite initialized in camera screen');
    } catch (e) {
      print('Error initializing TFLite in camera screen: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      await widget.controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        showMessage(
            context, 'Error', 'Failed to initialize camera: ${e.toString()}');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Apply background color
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        title: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          height: 32,
        ),
        backgroundColor: Theme.of(context)
            .appBarTheme
            .backgroundColor, // Use theme AppBar backgroundColor
        elevation: 0, // Remove app bar shadow for a flatter look
      ),
      body: Stack(
        children: [
          if (_isInitialized)
            Positioned.fill(
              child: CameraPreview(widget.controller),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
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
      floatingActionButton: _isInitialized
          ? FloatingActionButton(
              onPressed: () async {
                try {
                  final image = await widget.controller.takePicture();
                  if (!mounted) return;

                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return Scaffold(
                          appBar: AppBar(
                            iconTheme: IconThemeData(
                                color: Theme.of(context).iconTheme.color),
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
                                  // Show loading dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 20),
                                              Text("Analyzing image..."),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  try {
                                    // Use TFLiteHelper to analyze the image
                                    print('Analyzing image: ${image.path}');
                                    bool isVendingMachine = await _tfliteHelper
                                        .isVendingMachine(image.path);
                                    print('Analysis result: $isVendingMachine');

                                    // Close loading dialog
                                    Navigator.of(context).pop();

                                    if (isVendingMachine) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop(image.path);
                                      showMessage(context, 'Woohoo!',
                                          'Image Updated Successfully');
                                    } else {
                                      Navigator.of(context).pop();
                                      showWarning(context,
                                          'Image is not a vending machine. Please try with a clearer photo of a vending machine.');
                                    }
                                  } catch (e) {
                                    // Close loading dialog if still open
                                    Navigator.of(context).pop();
                                    print('Error analyzing image: $e');
                                    showMessage(context, 'Error',
                                        'Failed to analyze image: ${e.toString()}');
                                  }
                                },
                              ),
                            ],
                          ),
                          body: Image.file(File(image.path)),
                        );
                      },
                    ),
                  );
                } catch (e) {
                  debugPrint(e.toString());
                  if (mounted) {
                    showMessage(context, 'Error',
                        'Failed to take picture: ${e.toString()}');
                  }
                }
              },
              child: const Icon(Icons.camera),
            )
          : null,
    );
  }

  @override
  void dispose() {
    print('Disposing camera screen');
    try {
      _tfliteHelper.dispose();
    } catch (e) {
      print('Error disposing TFLiteHelper: $e');
    }
    super.dispose();
  }
}
