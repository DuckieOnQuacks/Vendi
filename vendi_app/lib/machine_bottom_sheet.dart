import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'package:vendi_app/backend/machine_class.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:vendi_app/backend/user_helper.dart';
import 'update_machine.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  /*Future<Machine?> selectedMachineDB =
      FirebaseHelper().getMachineById(selectedMachine!);*/

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
  }

  void _showMachineNotes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('Machine Notes', style: GoogleFonts.bebasNeue(fontSize: 24)),
          content: Text('No notes available for this machine yet.',
              style: GoogleFonts.getFont('Bebas Neue', fontSize: 18)),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
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
                child: Column(children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Header row with machine icon, type, and favorite button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(machineSnapshot.icon, height: 50),
                  const SizedBox(width: 20),
                  if (machineSnapshot.icon ==
                      'assets/images/BlueMachine.png') ...[
                    Text('Beverage Machine',
                        style: GoogleFonts.bebasNeue(fontSize: 30)),
                  ] else if (machineSnapshot.icon ==
                      'assets/images/PinkMachine.png') ...[
                    Text('Snack Machine',
                        style: GoogleFonts.bebasNeue(fontSize: 30)),
                  ] else ...[
                    Text('Supply Machine',
                        style: GoogleFonts.bebasNeue(fontSize: 30)),
                  ],
                  const SizedBox(width: 20),

                  // Favorite button
                  FutureBuilder<bool>(
                    future: isMachineFavorited(selectedMachine!),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        bool isFavorite = snapshot.data ?? false;
                        return FavoriteButton(
                            isFavorite: isFavorite,
                            valueChanged: (value) async {
                              if (value) {
                                await setMachineToFavorited(
                                    selectedMachine!.id, context);
                              } else {
                                await removeMachineFromFavorited(
                                    selectedMachine!.id);
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

                  // Notes icon
                  IconButton(
                    icon: Icon(Icons.notes,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: _showMachineNotes,
                    tooltip: 'View machine notes',
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Location information
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Location: ',
                      style: GoogleFonts.bebasNeue(fontSize: 26)),
                  Text('${machineSnapshot.name}',
                      style: GoogleFonts.bebasNeue(
                          fontSize: 25, color: Colors.grey[800])),
                  const SizedBox(width: 5),
                  Text('Floor ${machineSnapshot.desc}',
                      style: GoogleFonts.bebasNeue(
                          fontSize: 26,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600)),
                ],
              ),

              // Last updated time
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Last updated:',
                      style: GoogleFonts.bebasNeue(fontSize: 20)),
                  const SizedBox(width: 10),
                  FutureBuilder<String>(
                    future: machineSnapshot.getImageCreationTime(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return const Text('No data found');
                      } else {
                        initializeDateFormatting();
                        // This is the format of the metadata we receive
                        DateFormat format = DateFormat("MM/dd/yyyy hh:mm a");
                        DateTime lastUpdate = format.parse(snapshot.data!);
                        // Calculate difference in time
                        Duration diff = DateTime.now().difference(lastUpdate);

                        // Calculate differences for days, hours, or minutes
                        int days = diff.inDays;
                        int hours = diff.inHours % 24;
                        int minutes = diff.inMinutes % 60;

                        String formattedDiff;
                        if (days > 0) {
                          if (days == 1) {
                            formattedDiff =
                                '$days day $hours hrs $minutes mins ago';
                          } else {
                            formattedDiff =
                                '$days days $hours hrs $minutes mins ago';
                          }
                        } else if (hours > 0) {
                          formattedDiff = '$hours hrs $minutes mins ago';
                        } else {
                          formattedDiff = '$minutes mins ago';
                        }

                        return Text(formattedDiff,
                            style: GoogleFonts.getFont('Bebas Neue',
                                fontSize: 20, color: Colors.grey[600]));
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Main content with image and machine information in two columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Machine image on the left
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: selectedMachine?.imagePath == ''
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(
                                        automaticallyImplyLeading: false,
                                        title: Image.asset(
                                          'assets/images/logo.png',
                                          fit: BoxFit.contain,
                                          height: 32,
                                        ),
                                        backgroundColor: Colors.white,
                                        leading: IconButton(
                                          icon: Icon(Icons.arrow_back),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ),
                                      body: SafeArea(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Image.network(
                                              selectedMachine!.imagePath,
                                              fit: BoxFit.cover,
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
                                height: 250,
                                child: Image.network(
                                  selectedMachine!.imagePath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Machine information on the right
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment methods and operational status
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  // Card payment status
                                  Row(
                                    children: [
                                      if (machineSnapshot.card == true) ...[
                                        Image.asset('assets/images/card.png',
                                            height: 30),
                                        const SizedBox(width: 15),
                                        Text('Card accepted',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 18)),
                                      ] else ...[
                                        Image.asset('assets/images/nocard.png',
                                            height: 30),
                                        const SizedBox(width: 15),
                                        Text('Card Not accepted',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 18)),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Cash payment status
                                  Row(
                                    children: [
                                      if (machineSnapshot.cash == true) ...[
                                        Image.asset('assets/images/cash.png',
                                            height: 30),
                                        const SizedBox(width: 15),
                                        Text('Cash accepted',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 18)),
                                      ] else ...[
                                        Image.asset('assets/images/cash.png',
                                            height: 30),
                                        const SizedBox(width: 15),
                                        Text('Cash Not accepted',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 18)),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Operational status
                                  Row(
                                    children: [
                                      if (machineSnapshot.operational ==
                                          true) ...[
                                        const Icon(Icons.check,
                                            color: Colors.green, size: 30),
                                        const SizedBox(width: 15),
                                        Text('Operational',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 18)),
                                      ] else ...[
                                        const Icon(Icons.clear_rounded,
                                            color: Colors.red, size: 30),
                                        const SizedBox(width: 15),
                                        Text('Not Operational',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 18)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Update button
                          Center(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.update),
                              label: Text('Update Machine',
                                  style: GoogleFonts.bebasNeue(fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const UpdateMachinePage()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ]));
          }
        });
  }
}
