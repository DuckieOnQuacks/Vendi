import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/backend/classes/firebase.dart';
import 'package:vendi_app/backend/classes/machine.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:vendi_app/backend/classes/user.dart';
import 'package:vendi_app/backend/message_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendi_app/backend/camera_helper.dart';

// All code on this page was developed by the team using the flutter framework

Machine? selectedMachine;

class MachineBottomSheet extends StatefulWidget {
  MachineBottomSheet(Machine machine, {super.key}) {
    super.key;
    selectedMachine = machine;
  }

  @override
  State<MachineBottomSheet> createState() => _MachineBottomSheetState();
}

class _MachineBottomSheetState extends State<MachineBottomSheet> {
  List<Machine> isFavorited = [];
  bool hasRated = false;
  bool _isNearMachine = false;
  final _reportController = TextEditingController();
  final List<String> _reportOptions = [
    'Out of order',
    'Not accepting cash',
    'Not accepting cards',
    'Incorrect information',
    'Wrong location',
    'Other issue'
  ];
  String _selectedReportOption = 'Out of order';
  late List<CameraDescription> cameras = [];

  Future<Machine?> selectedMachineDB =
      FirebaseHelper().getMachineById(selectedMachine!);

  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    getMachinesFavorited().then((machines) {
      setState(() {
        isFavorited = machines;
      });
    });
    _checkProximityToMachine();
    // Initialize camera properly
    _initializeCamera();
  }

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  // Check if user is near the machine (within 50 meters)
  Future<void> _checkProximityToMachine() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return; // Not allowed to check location
        }
      }

      // Get current position
      Position userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Calculate distance to machine
      double distanceInMeters = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          selectedMachine!.lat,
          selectedMachine!.lon);

      setState(() {
        // Consider user near if within 50 meters
        _isNearMachine = distanceInMeters <= 50;
      });
    } catch (e) {
      print("Error checking proximity: $e");
    }
  }

  // Add dedicated camera initialization method
  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras found on device');
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  // Use the shared camera helper implementation
  Future<String?> takeMachinePhoto(BuildContext context) async {
    try {
      // Call the openCamera function from the imported camera_helper.dart
      return await openCamera(context);
    } catch (e) {
      print("Camera operation error: $e");
      showMessage(context, 'Camera Error',
          'An unexpected error occurred: ${e.toString()}');
      return null;
    }
  }

  // Upload image to Firebase Storage
  Future<void> uploadImage(String imagePath) async {
    try {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      // Get a reference to the Firebase Storage bucket
      Reference storageRef = FirebaseStorage.instance.ref();
      // Upload the image file to Firebase Storage
      Reference uploadTask = storageRef.child('images');
      Reference referenceImage = uploadTask.child(uniqueFileName);
      await referenceImage.putFile(File(imagePath));
      String imageUrl = await referenceImage.getDownloadURL();

      // Update machine with new image URL
      Machine updatedMachine = Machine(
        id: selectedMachine!.id,
        name: selectedMachine!.name,
        desc: selectedMachine!.desc,
        lat: selectedMachine!.lat,
        lon: selectedMachine!.lon,
        imagePath: imageUrl,
        icon: selectedMachine!.icon,
        card: selectedMachine!.card,
        cash: selectedMachine!.cash,
        operational: selectedMachine!.operational,
        upvotes: selectedMachine!.upvotes,
        dislikes: selectedMachine!.dislikes,
      );

      // Update machine in database
      await FirebaseHelper().updateMachine(updatedMachine);

      // Show success message and award points
      showConfettiDialog(context,
          'Image updated successfully!\n\nYou\'ve earned 20 Vendi points!');
      await setUserPoints(20);

      // Refresh machine data
      setState(() {
        selectedMachineDB = FirebaseHelper().getMachineById(selectedMachine!);
      });
    } catch (e) {
      print('Error uploading image: $e');
      showMessage(context, 'Error', 'Failed to upload image: ${e.toString()}');
    }
  }

  // Toggle machine status (card, cash, operational)
  Future<void> _toggleMachineStatus(
      String statusType, bool currentValue) async {
    if (!_isNearMachine) {
      // Show location-based warning message
      showNotice(context,
          'You must be near the machine to update its status. Move closer and try again.');
      return;
    }

    // Check if user can interact with this machine
    bool canInteract = await canUserInteractWithMachine(selectedMachine!.id);
    if (!canInteract) {
      showNotice(context,
          'You can only update a machine\'s status once per day. Please try again tomorrow.');
      return;
    }

    try {
      Machine updatedMachine = Machine(
        id: selectedMachine!.id,
        name: selectedMachine!.name,
        desc: selectedMachine!.desc,
        lat: selectedMachine!.lat,
        lon: selectedMachine!.lon,
        imagePath: selectedMachine!.imagePath,
        icon: selectedMachine!.icon,
        card: statusType == 'card' ? !currentValue : selectedMachine!.card,
        cash: statusType == 'cash' ? !currentValue : selectedMachine!.cash,
        operational: statusType == 'operational'
            ? !currentValue
            : selectedMachine!.operational,
        upvotes: selectedMachine!.upvotes,
        dislikes: selectedMachine!.dislikes,
      );

      // Update machine in database
      await FirebaseHelper().updateMachineStatus(updatedMachine);

      // Track the status change
      if (statusType == 'card') {
        await incrementCardChanges();
      } else if (statusType == 'operational') {
        await incrementStatusChanges();
      }
      await recordMachineInteraction(selectedMachine!.id);

      // Refresh machine data
      setState(() {
        selectedMachineDB = FirebaseHelper().getMachineById(selectedMachine!);
      });

      // Show success dialog with confetti
      String message = '';
      if (statusType == 'card') {
        message = currentValue
            ? 'You\'ve updated this machine to not accept cards.'
            : 'You\'ve updated this machine to accept cards.';
      } else if (statusType == 'cash') {
        message = currentValue
            ? 'You\'ve updated this machine to not accept cash.'
            : 'You\'ve updated this machine to accept cash.';
      } else if (statusType == 'operational') {
        message = currentValue
            ? 'You\'ve marked this machine as not working.'
            : 'You\'ve marked this machine as operational.';
      }

      setState(() {
        Navigator.of(context).pop();
      });
      await setUserPoints(10);
      showConfettiDialog(context, "$message\n\nYou've earned 10 Vendi points!");
    } catch (e) {
      // Show error dialog
      showMessage(
          context, 'Error', 'Unable to update machine status: ${e.toString()}');
    }
  }

  void _showMachineReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Report Machine Issue',
                style: GoogleFonts.bebasNeue(fontSize: 36)),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Issue Type:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedReportOption,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      items: _reportOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7),
                            child: Text(
                              option,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedReportOption = value!;
                        });
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),
                    Text('Additional Details (Optional):',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reportController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue in detail...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel',
                    style: TextStyle(
                      fontSize: 16,
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Submit Report'),
                onPressed: () async {
                  // Check if user can report
                  final canReport =
                      await canUserReportMachine(selectedMachine!.id);
                  if (!canReport) {
                    Navigator.of(context).pop();
                    showMessage(
                      context,
                      'Report Limit',
                      'You can only report a machine once per day. Please try again tomorrow.',
                    );
                    return;
                  }

                  // Submit report
                  String reportText = _selectedReportOption;
                  if (_reportController.text.isNotEmpty) {
                    reportText += ': ${_reportController.text}';
                  }

                  await FirebaseHelper()
                      .addReport(selectedMachine!.id, reportText);
                  await recordUserReport(selectedMachine!.id, reportText);

                  // Clear the form
                  _reportController.clear();

                  Navigator.of(context).pop();

                  // Show confirmation and points awarded
                  showConfettiDialog(context,
                      'Thank you for your report! You\'ve earned 10 Vendi points!');

                  // Refresh machine data
                  setState(() {
                    selectedMachineDB =
                        FirebaseHelper().getMachineById(selectedMachine!);
                  });
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //Future builder for grabbing a snapshot of the selectedMachine from the firebase database.
    return FutureBuilder(
        future: selectedMachineDB,
        builder: (BuildContext context, AsyncSnapshot<Machine?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
            //Error handling
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            Machine machineSnapshot = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).cardColor,
                          Theme.of(context).cardColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: machineSnapshot.icon ==
                                    'assets/images/BlueMachine.png'
                                ? Colors.blue.withOpacity(0.1)
                                : machineSnapshot.icon ==
                                        'assets/images/PinkMachine.png'
                                    ? Colors.pink.withOpacity(0.1)
                                    : Colors.amber.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 12.0, bottom: 8.0),
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: machineSnapshot.icon ==
                                          'assets/images/BlueMachine.png'
                                      ? Colors.blue.withOpacity(0.3)
                                      : machineSnapshot.icon ==
                                              'assets/images/PinkMachine.png'
                                          ? Colors.pink.withOpacity(0.3)
                                          : Colors.amber.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).cardColor,
                          Theme.of(context).cardColor.withOpacity(1),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        // Header row with machine icon, type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(machineSnapshot.icon, height: 55),
                            const SizedBox(width: 15),
                            if (machineSnapshot.icon ==
                                'assets/images/BlueMachine.png') ...[
                              Flexible(
                                child: Text('Beverage Machine',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.bebasNeue(fontSize: 48)),
                              ),
                            ] else if (machineSnapshot.icon ==
                                'assets/images/PinkMachine.png') ...[
                              Flexible(
                                child: Text('Snack Machine',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.bebasNeue(fontSize: 48)),
                              ),
                            ] else ...[
                              Flexible(
                                child: Text('Supply Machine',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.bebasNeue(fontSize: 48)),
                              ),
                            ],
                            const SizedBox(width: 15),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Main content section with image and machine information
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Machine image on the left
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    selectedMachine?.imagePath == ''
                                        ? const SizedBox.shrink()
                                        : Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Scaffold(
                                                        appBar: AppBar(
                                                          automaticallyImplyLeading:
                                                              false,
                                                          title: Image.asset(
                                                            'assets/images/logo.png',
                                                            fit: BoxFit.contain,
                                                            height: 32,
                                                          ),
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .surface,
                                                          foregroundColor:
                                                              Colors.white,
                                                          leading: IconButton(
                                                            icon: Icon(Icons
                                                                .arrow_back),
                                                            color: Colors.white,
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                          ),
                                                        ),
                                                        body: SafeArea(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: Container(
                                                              height:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child:
                                                                  Image.network(
                                                                selectedMachine!
                                                                    .imagePath,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 180,
                                                  height: 275,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Image.network(
                                                      selectedMachine!
                                                          .imagePath,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          width: 180,
                                                          height: 275,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surface
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                size: 40,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                    .withOpacity(
                                                                        0.5),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Text(
                                                                'No Image Available',
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withOpacity(
                                                                          0.5),
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return Container(
                                                          width: 180,
                                                          height: 275,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surface
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : null,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Edit image button in top right
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[600]
                                                        ?.withOpacity(0.7),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: IconButton(
                                                    icon: Icon(
                                                      _isNearMachine
                                                          ? Icons.camera_alt
                                                          : Icons
                                                              .no_photography,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    constraints: BoxConstraints(
                                                      minWidth: 36,
                                                      minHeight: 36,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    onPressed: _isNearMachine
                                                        ? () async {
                                                            String? imagePath =
                                                                await takeMachinePhoto(
                                                                    context);
                                                            if (imagePath !=
                                                                    null &&
                                                                imagePath
                                                                    .isNotEmpty) {
                                                              await uploadImage(
                                                                  imagePath);
                                                            }
                                                          }
                                                        : () {
                                                            showNotice(context,
                                                                'You must be near the machine to update its image. Move closer and try again.');
                                                          },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),

                              // Machine information on the right
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Card with machine details
                                      Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        shadowColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Location information
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        showMessage(
                                                          context,
                                                          'Location',
                                                          '${machineSnapshot.name}, Floor ${machineSnapshot.desc}',
                                                        );
                                                      },
                                                      child: Text(
                                                        '${machineSnapshot.name}, Floor ${machineSnapshot.desc}',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              const Divider(
                                                  height: 16, thickness: 1),
                                              // Payment methods
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  // Card payment
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () =>
                                                          _toggleMachineStatus(
                                                              'card',
                                                              machineSnapshot
                                                                  .card),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8.0,
                                                                horizontal:
                                                                    2.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: _isNearMachine
                                                              ? Border.all(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withOpacity(
                                                                          0.5),
                                                                  width: 1,
                                                                )
                                                              : null,
                                                          color: _isNearMachine
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surface
                                                                  .withOpacity(
                                                                      0.2)
                                                              : null,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Icon(
                                                              machineSnapshot
                                                                      .card
                                                                  ? Icons
                                                                      .credit_card
                                                                  : Icons
                                                                      .credit_card_off,
                                                              size: 26,
                                                              color: machineSnapshot
                                                                      .card
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface
                                                                      .withOpacity(
                                                                          0.4),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              machineSnapshot
                                                                      .card
                                                                  ? 'Card'
                                                                  : 'No Card',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: machineSnapshot
                                                                        .card
                                                                    ? Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.color
                                                                    : Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.color
                                                                        ?.withOpacity(
                                                                            0.6),
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            if (_isNearMachine)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            4.0),
                                                                child: Text(
                                                                  'Tap to update',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color: Colors
                                                                            .grey[
                                                                        600],
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  // Cash payment
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () =>
                                                          _toggleMachineStatus(
                                                              'cash',
                                                              machineSnapshot
                                                                  .cash),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8.0,
                                                                horizontal:
                                                                    4.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: _isNearMachine
                                                              ? Border.all(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withOpacity(
                                                                          0.5),
                                                                  width: 1,
                                                                )
                                                              : null,
                                                          color: _isNearMachine
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surface
                                                                  .withOpacity(
                                                                      0.2)
                                                              : null,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Icon(
                                                              machineSnapshot
                                                                      .cash
                                                                  ? Icons
                                                                      .payments_outlined
                                                                  : Icons
                                                                      .money_off,
                                                              size: 26,
                                                              color: machineSnapshot
                                                                      .cash
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface
                                                                      .withOpacity(
                                                                          0.4),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              machineSnapshot
                                                                      .cash
                                                                  ? 'Cash'
                                                                  : 'No Cash',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: machineSnapshot
                                                                        .cash
                                                                    ? Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.color
                                                                    : Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.color
                                                                        ?.withOpacity(
                                                                            0.6),
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            if (_isNearMachine)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            4.0),
                                                                child: Text(
                                                                  'Tap to update',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color: Colors
                                                                            .grey[
                                                                        600],
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  // Operational status
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () =>
                                                          _toggleMachineStatus(
                                                              'operational',
                                                              machineSnapshot
                                                                  .operational),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8.0,
                                                                horizontal:
                                                                    4.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: _isNearMachine
                                                              ? Border.all(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withOpacity(
                                                                          0.5),
                                                                  width: 1,
                                                                )
                                                              : null,
                                                          color: _isNearMachine
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surface
                                                                  .withOpacity(
                                                                      0.2)
                                                              : null,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Icon(
                                                              machineSnapshot
                                                                      .operational
                                                                  ? Icons
                                                                      .check_circle
                                                                  : Icons.error,
                                                              size: 26,
                                                              color: machineSnapshot
                                                                      .operational
                                                                  ? Colors.green
                                                                      .shade400
                                                                  : Colors.red
                                                                      .shade400,
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              machineSnapshot
                                                                      .operational
                                                                  ? 'Works'
                                                                  : 'Broken',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: machineSnapshot.operational
                                                                    ? Colors
                                                                        .green
                                                                        .shade400
                                                                    : Colors.red
                                                                        .shade400,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            if (_isNearMachine)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            4.0),
                                                                child: Text(
                                                                  'Tap to update',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color: Colors
                                                                            .grey[
                                                                        600],
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
                                              // Last updated time
                                              FutureBuilder<String>(
                                                future: machineSnapshot
                                                    .getImageCreationTime(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<String>
                                                        snapshot) {
                                                  if (snapshot.connectionState ==
                                                          ConnectionState
                                                              .waiting ||
                                                      snapshot.hasError ||
                                                      !snapshot.hasData) {
                                                    return const SizedBox
                                                        .shrink();
                                                  } else {
                                                    initializeDateFormatting();
                                                    DateFormat format =
                                                        DateFormat(
                                                            "MM/dd/yyyy hh:mm a");
                                                    DateTime lastUpdate = format
                                                        .parse(snapshot.data!);
                                                    Duration diff =
                                                        DateTime.now()
                                                            .difference(
                                                                lastUpdate);

                                                    String formattedDiff;
                                                    if (diff.inDays > 0) {
                                                      formattedDiff =
                                                          '${diff.inDays} days ago';
                                                    } else if (diff.inHours >
                                                        0) {
                                                      formattedDiff =
                                                          '${diff.inHours} hours ago';
                                                    } else {
                                                      formattedDiff =
                                                          '${diff.inMinutes} minutes ago';
                                                    }

                                                    return Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.update,
                                                            size: 14,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Flexible(
                                                            child: Text(
                                                              'Last updated $formattedDiff',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .grey[600],
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FutureBuilder<bool>(
                                            future: isMachineFavorited(
                                                selectedMachine!),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<bool> snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                bool isFavorite =
                                                    snapshot.data ?? false;
                                                return FavoriteButton(
                                                    isFavorite: isFavorite,
                                                    valueChanged:
                                                        (value) async {
                                                      if (value) {
                                                        await setMachineToFavorited(
                                                            selectedMachine!.id,
                                                            context);
                                                      } else {
                                                        await removeMachineFromFavorited(
                                                            selectedMachine!
                                                                .id);
                                                      }
                                                      setState(() {
                                                        isFavorite = value;
                                                      });
                                                    });
                                              } else {
                                                return const CircularProgressIndicator();
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 20),
                                          // Report icon button
                                          IconButton(
                                            icon: Icon(
                                              Icons.report_problem_outlined,
                                              color: Colors.orange,
                                              size: 32,
                                            ),
                                            onPressed: _showMachineReportDialog,
                                            tooltip: 'Report Issue',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 45),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
