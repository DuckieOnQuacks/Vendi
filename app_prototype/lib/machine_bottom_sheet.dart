import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/backend/firebase_helper.dart';
import 'package:vendi_app/backend/machine_class.dart';
import 'package:favorite_button/favorite_button.dart';
import 'update_machine.dart';
import 'main.dart';

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
  Future<int?> isFavorite = dbHelper.getMachineFavoriteStatus(selectedMachine!);
  Future<Machine?> selectedMachineDB = FirebaseHelper().getMachineById(selectedMachine!);
  FirebaseStorage storage = FirebaseStorage.instance;

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
            return Center(
              child: Column(children: [
                const SizedBox(height: 10),
                //Row for the machine Icon, name, and the favorites heart icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(machineSnapshot.icon, height: 50),
                    const SizedBox(width: 20),
                    if (machineSnapshot.icon ==
                        'assets/images/BlueMachine.png') ...[
                      Text('Beverage Machine',
                          style: GoogleFonts.bebasNeue(fontSize: 30)),
                      const SizedBox(width: 20),
                    ] else if (machineSnapshot.icon ==
                        'assets/images/PinkMachine.png') ...[
                      Text('Snack Machine',
                          style: GoogleFonts.bebasNeue(fontSize: 30)),
                      const SizedBox(width: 20),
                    ] else ...[
                      Text('Supply Machine',
                          style: GoogleFonts.bebasNeue(fontSize: 30)),
                      const SizedBox(width: 20),
                    ],
                    // Checkbox for favouring the machine
                    //Future builder for the favorite button so that it can query the local db
                    FutureBuilder<int?>(
                      future:
                          dbHelper.getMachineFavoriteStatus(selectedMachine!),
                      builder:
                          (BuildContext context, AsyncSnapshot<int?> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          int isFavorite = snapshot.data ?? 0;
                          return FavoriteButton(
                            isFavorite: isFavorite == 1,
                            valueChanged: (value) {
                              setState(() {
                                isFavorite = value ? 1 : 0;
                              });
                              if (isFavorite == 1) {
                                selectedMachine?.isFavorited = 1;
                                dbHelper.saveMachine(selectedMachine!);
                                // Add to favorites
                              } else {
                                // Remove from favorites
                                selectedMachine?.isFavorited = 0;
                                dbHelper.saveMachine(selectedMachine!);
                              }
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
                //Row that shows the machine name and description
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 15),
                    Text(machineSnapshot.name,
                        style: GoogleFonts.bebasNeue(fontSize: 25)),
                    const SizedBox(width: 10),
                    Text(machineSnapshot.desc,
                        style: GoogleFonts.bebasNeue(fontSize: 25)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 15),
                    Text('Last updated:',
                        style: GoogleFonts.bebasNeue(fontSize: 25)),
                    const SizedBox(width: 10),
                    FutureBuilder<String>(
                      future: machineSnapshot.getImageCreationTime(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData) {
                          return const Text('No data found');
                        } else {
                          return Text(snapshot.data!,
                              style: GoogleFonts.getFont('Bebas Neue',
                                  fontSize: 25, color: Colors.grey[600]));
                        }
                      },
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              const SizedBox(width: 20),
                              const SizedBox(width: 5),
                              if (machineSnapshot.card == 1) ...[
                                Image.asset('assets/images/card.png',
                                    height: 30),
                                const SizedBox(width: 20),
                                Text('Card accepted',
                                    style: GoogleFonts.bebasNeue(fontSize: 16)),
                              ] else ...[
                                Image.asset('assets/images/nocard.png',
                                    height: 30),
                                const SizedBox(width: 20),
                                Text('Card Not accepted',
                                    style: GoogleFonts.bebasNeue(fontSize: 16)),
                              ],
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              const SizedBox(width: 20),
                              const SizedBox(width: 5),
                              if (machineSnapshot.cash == 1) ...[
                                Image.asset('assets/images/cash.png',
                                    height: 30),
                                const SizedBox(width: 20),
                                Text('Cash accepted',
                                    style: GoogleFonts.bebasNeue(fontSize: 16)),
                              ] else ...[
                                Image.asset('assets/images/cash.png',
                                    height: 30),
                                const SizedBox(width: 20),
                                Text('Cash Not accepted',
                                    style: GoogleFonts.bebasNeue(fontSize: 16)),
                              ],
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              const SizedBox(width: 20),
                              if (machineSnapshot.operational == 1) ...[
                                const Icon(Icons.check, color: Colors.green),
                                const SizedBox(width: 20),
                                Text('Operational',
                                    style: GoogleFonts.bebasNeue(fontSize: 16)),
                              ] else ...[
                                const Icon(Icons.clear_rounded,
                                    color: Colors.red),
                                const SizedBox(width: 20),
                                Text('Not Operational',
                                    style: GoogleFonts.bebasNeue(fontSize: 16)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          selectedMachine?.imagePath == ''
                              ? const SizedBox.shrink()
                              : SizedBox(
                                  width: 200,
                                  height: 250,
                                  child:
                                      Image.network(selectedMachine!.imagePath),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Intractable close menu button
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UpdateMachinePage()),
                      );
                    },
                    child: const Text("Update Machine"))
              ]),
            );
          }
        });
  }
}
