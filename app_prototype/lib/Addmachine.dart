import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as Path;
import 'package:vendi_app/home_page.dart';


const List<String> list = <String>['I don\'t know','Yes', 'No'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Machine'),
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
              child: IconButton(onPressed: () {
                openCamera();
              },
                  icon: const Icon(Icons.camera_alt)),
            ),
            const SizedBox(height:  40.0),
            //input fields
            const Text('Building Name*',
                style: TextStyle(fontSize: 16)),
            TextField(
              controller: _buildingController,
            ),
            const SizedBox(height: 16.0),
            const Text('Floor Number*',
                style: TextStyle(fontSize: 16)),
            TextField(
              controller: _floorController,
            ),
            const SizedBox(height:  40.0),
            const Text('Select Machine Type(s)*',
                style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: Text('Snack'),
              value: _isSnackSelected,
              onChanged: (value) {
                setState(() {
                  _isSnackSelected = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Drink'),
              value: _isDrinkSelected,
              onChanged: (value) {
                setState(() {
                  _isDrinkSelected = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Supply'),
              value: _isSupplySelected,
              onChanged: (value) {
                setState(() {
                  _isSupplySelected = value!;
                });
              },
            ),
            const SizedBox(height:  40.0),
            const Text('Select Machine Options',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            const Text('Is the machine currently operating?',
                style: TextStyle(fontSize: 16)),
            const DropdownButtonMenu(),
            const SizedBox(height: 20.0),
            const Text('Is the machine stocked more than halfway?',
                style: TextStyle(fontSize: 16)),
            const DropdownButtonMenu(),
            const SizedBox(height: 20.0),
            const Text('Does the machine take cash?',
                style: TextStyle(fontSize: 16)),
            const DropdownButtonMenu(),
            const SizedBox(height: 20.0),
            const Text('Does the machine take card?',
                style: TextStyle(fontSize: 16)),
            const DropdownButtonMenu(),
            const SizedBox(height:  20.0),
            const Text('*Required',
                style: TextStyle(color: Colors.red)),
            const SizedBox(height:  20.0),
            Center(
              //submit button
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Submission'),
                          content: Text('Are you sure you want to submit a form for a new vending machine?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                });
                              },
                              child: Text('Submit'),
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
                    'Submit', style: TextStyle(
                    fontSize: 24,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  )
              ),
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
    if (cameras == null || cameras.isEmpty) {
      return;
    }

    // Take the first camera in the list (usually the back camera)
    CameraDescription camera = cameras[0];

    // Open the camera and store the resulting CameraController
    CameraController controller = CameraController(
        camera, ResolutionPreset.high);
    await controller.initialize();

    // Navigate to the CameraScreen and pass the CameraController to it
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(controller),
      ),
    );
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
                            setState(() {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              //selectedMachine?.imagePath = image.path;
                            //  dbHelper.updateMachine(selectedMachine!);
                            });
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
/////////////////////////////////////////////////////////////////////////////////
class DropdownButtonMenu extends StatefulWidget {
  const DropdownButtonMenu({super.key});

  @override
  State<DropdownButtonMenu> createState() => _DropdownButtonMenuState();
}

class _DropdownButtonMenuState extends State<DropdownButtonMenu> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.black87),
      underline: Container(
        height: 2,
        color: Colors.pinkAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
