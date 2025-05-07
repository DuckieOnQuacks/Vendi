import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vendi_app/backend/classes/firebase.dart';
import 'package:vendi_app/backend/camera_helper.dart';
import 'package:vendi_app/backend/classes/machine.dart';
import 'package:vendi_app/backend/message_helper.dart';
import 'package:vendi_app/backend/classes/user.dart';
import 'package:vendi_app/bottom_bar.dart';
import 'package:vendi_app/backend/classes/tflite_helper.dart';
import 'package:confetti/confetti.dart';

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
  bool _isOperational = false;
  bool _acceptsCash = false;
  bool _acceptsCard = false;
  late String machineImage;
  String imageUrl = ' ';
  String imagePath = ' ';
  int pictureTaken = 0;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = false;
  final TFLiteHelper _tfliteHelper = TFLiteHelper();
  late ConfettiController _confettiController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    getCurrentLocation();
    _tfliteHelper.initialize();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _floorController.dispose();
    _tfliteHelper.dispose();
    _confettiController.dispose();
    // Cancel any ongoing location requests
    Geolocator.getCurrentPosition().timeout(Duration(seconds: 5));
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_isInitializingCamera) return;

    _isInitializingCamera = true;
    try {
      cameras = await availableCameras();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        showMessage(context, 'Error',
            'Failed to initialize camera. Please check permissions and try again.');
      }
    } finally {
      _isInitializingCamera = false;
    }
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

  Future<void> getCurrentLocation() async {
    // Check if location permission is granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permission if it is not granted
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Location permission denied');
        }
        return;
      }
    }

    // Only update if we don't already have a position
    if (_currentPosition == null) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 5));
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error getting location: $e');
        }
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  const Text(
                    'Add a New Machine',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Help others find vending machines in your area',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Required fields note
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Fields marked with * are required',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Photo Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.camera_alt,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                            const SizedBox(width: 8),
                            Text(
                              'Take a Photo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            if (!_isCameraInitialized) {
                              showMessage(context, 'Error',
                                  'Camera is not ready yet. Please wait.');
                              return;
                            }
                            try {
                              if (pictureTaken == 0) {
                                String? path = await openCamera(context);
                                if (path != null && path.isNotEmpty) {
                                  setState(() {
                                    imagePath = path;
                                    pictureTaken = 1;
                                  });
                                }
                              } else {
                                setState(() {
                                  pictureTaken = 0;
                                  imagePath = '';
                                });
                              }
                            } catch (e) {
                              print('Error opening camera: $e');
                              showMessage(context, 'Error',
                                  'Failed to open camera. Please check permissions and try again.');
                            }
                          },
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                  width: 2,
                                ),
                              ),
                              child: pictureTaken == 0
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 48,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to take a photo',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(imagePath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .cardColor
                                                  .withOpacity(0.8),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.refresh,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                            const SizedBox(width: 8),
                            Text(
                              'Location Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _buildingController,
                          decoration: InputDecoration(
                            labelText: 'Building Name',
                            hintText: 'Ex: Davidson Building',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.business,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          maxLength: 25,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _floorController,
                          decoration: InputDecoration(
                            labelText: 'Floor Number',
                            hintText: 'Ex: 2',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.stairs,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          maxLength: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Machine Type Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.category,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                            const SizedBox(width: 8),
                            Text(
                              'Machine Type',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMachineTypeCard(
                              Icons.fastfood,
                              'Snack',
                              _isSnackSelected,
                              () {
                                setState(() {
                                  _isSnackSelected = true;
                                  _isDrinkSelected = false;
                                  _isSupplySelected = false;
                                });
                              },
                            ),
                            _buildMachineTypeCard(
                              Icons.local_drink,
                              'Beverage',
                              _isDrinkSelected,
                              () {
                                setState(() {
                                  _isSnackSelected = false;
                                  _isDrinkSelected = true;
                                  _isSupplySelected = false;
                                });
                              },
                            ),
                            _buildMachineTypeCard(
                              Icons.inventory,
                              'Supply',
                              _isSupplySelected,
                              () {
                                setState(() {
                                  _isSnackSelected = false;
                                  _isDrinkSelected = false;
                                  _isSupplySelected = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Options Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payment,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                            const SizedBox(width: 8),
                            Text(
                              'Payment Options',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Accepts Cash'),
                          subtitle: const Text('Does the machine take cash?'),
                          value: _acceptsCash,
                          onChanged: (value) {
                            setState(() {
                              _acceptsCash = value;
                            });
                          },
                          secondary: Icon(
                            Icons.money,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Accepts Card'),
                          subtitle: const Text('Does the machine take card?'),
                          value: _acceptsCard,
                          onChanged: (value) {
                            setState(() {
                              _acceptsCard = value;
                            });
                          },
                          secondary: Icon(
                            Icons.credit_card,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Operational Status Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.power_settings_new,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                            const SizedBox(width: 8),
                            Text(
                              'Machine Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Machine is Operational'),
                          subtitle:
                              const Text('Is the machine working properly?'),
                          value: _isOperational,
                          onChanged: (value) {
                            setState(() {
                              _isOperational = value;
                            });
                          },
                          secondary: Icon(
                            Icons.check_circle,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkAndSubmitMachine,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Machine',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildMachineTypeCard(
      IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAndSubmitMachine() async {
    // First check if we have location data
    if (_currentPosition == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Error'),
            content: Text(
                'Unable to get your current location. Please make sure location services are enabled and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  getCurrentLocation(); // Try to get location again
                },
                child: Text('Retry'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_buildingController.text.isEmpty ||
        _floorController.text.isEmpty ||
        pictureTaken == 0) {
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
                  color: Colors.orangeAccent,
                ),
                SizedBox(width: 10),
                Text(
                  'Warning',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            content: const Text(
                'Missing Information. Please fill out all fields and try again.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check if image is a vending machine
    final isVendingMachine = await _tfliteHelper.isVendingMachine(imagePath);
    if (!isVendingMachine) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Image'),
            content: Text(
                'The image does not appear to be a vending machine. Please take a clear photo of a vending machine.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    pictureTaken = 0;
                    imagePath = '';
                  });
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Show confirmation dialog
    bool? shouldSubmit = await showDialog<bool>(
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
                color: Colors.orangeAccent,
              ),
              Text(
                'Confirm Submission',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          content: const Text(
              'Are you sure you want to submit a form for a new vending machine?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (shouldSubmit != true) return;

    setState(() {
      _isSubmitting = true;
    });

    // Process submission
    int cap = await getUserCap() ?? 0;
    DateTime? timeAfter24HoursStored = await getTimeAfter24Hours();
    DateTime targetDate = DateTime.utc(1969, 12, 31, 16, 0);

    if (cap >= 90 &&
        (timeAfter24HoursStored == null ||
            DateTime.now().isAfter(timeAfter24HoursStored) ||
            timeAfter24HoursStored.isAtSameMomentAs(targetDate))) {
      await setUserCap(-cap);
      DateTime? timeTaken = await getImageTakenTime(imageUrl);

      if (timeTaken != null) {
        DateTime timeAfter24Hours = timeTaken.add(Duration(hours: 24));
        Duration timeLeft = timeAfter24Hours.difference(DateTime.now());
        await setTimeAfter24Hours(timeAfter24Hours);

        setState(() {
          _isSubmitting = false;
        });
        Navigator.of(context).pop(true);
        return;
      }
    } else if (cap < 90 &&
        timeAfter24HoursStored != null &&
        DateTime.now().isBefore(timeAfter24HoursStored)) {
      Duration timeLeft = timeAfter24HoursStored.difference(DateTime.now());

      setState(() {
        _isSubmitting = false;
      });
      Navigator.of(context).pop(true);
      return;
    } else {
      // Upload image first and wait for the URL
      String uploadedImageUrl = '';
      try {
        String uniqueFileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref();
        Reference uploadTask = storageRef.child('images');
        Reference referenceImage = uploadTask.child(uniqueFileName);

        await referenceImage.putFile(File(imagePath));
        uploadedImageUrl = await referenceImage.getDownloadURL();
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        print('Error uploading image: $e');
        showMessage(
            context, 'Error', 'Failed to upload image. Please try again.');
        return;
      }

      // When creating the machine object, use null-safe access
      Machine createMachine(String imageUrl, String iconPath) {
        return Machine(
          id: '',
          name: _buildingController.text,
          desc: _floorController.text,
          lat: _currentPosition?.latitude ?? 0.0, // Null-safe access
          lon: _currentPosition?.longitude ?? 0.0, // Null-safe access
          imagePath: imageUrl,
          icon: iconPath,
          card: _acceptsCard,
          cash: _acceptsCash,
          operational: _isOperational,
          upvotes: 0,
          dislikes: 0,
        );
      }

      // In the submission section, after successful machine addition:
      if (_isDrinkSelected) {
        Machine test1 =
            createMachine(uploadedImageUrl, "assets/images/BlueMachine.png");
        await FirebaseHelper().addMachine(test1);
        final machineId =
            await FirebaseHelper().getMachineIdByLocation(test1.lat, test1.lon);
        if (machineId != null) {
          await addMachineToUser(machineId);
        }
      } else if (_isSnackSelected) {
        Machine test2 =
            createMachine(uploadedImageUrl, "assets/images/PinkMachine.png");
        await FirebaseHelper().addMachine(test2);
        final machineId =
            await FirebaseHelper().getMachineIdByLocation(test2.lat, test2.lon);
        if (machineId != null) {
          await addMachineToUser(machineId);
        }
      } else if (_isSupplySelected) {
        Machine test3 =
            createMachine(uploadedImageUrl, "assets/images/YellowMachine.png");
        await FirebaseHelper().addMachine(test3);
        final machineId =
            await FirebaseHelper().getMachineIdByLocation(test3.lat, test3.lon);
        if (machineId != null) {
          await addMachineToUser(machineId);
        }
      }

      await setUserPoints(50);
      await setUserCap(50);

      setState(() {
        _isSubmitting = false;
      });
      Navigator.of(context).pop(true);
      return;
    }
  }
}
