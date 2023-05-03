import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/backend/machine_database_helper.dart';
import 'package:vendi_app/backend/machine_class.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:vendi_app/backend/user_helper.dart';
import 'backend/message_helper.dart';
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

  Future<Machine?> selectedMachineDB = FirebaseHelper().getMachineById(selectedMachine!);

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
                            }
                          });
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              //Row that shows the machine name and description
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(width: 15),
                  Text('Location: ',
                      style: GoogleFonts.bebasNeue(fontSize: 26)),
                  Text('${machineSnapshot.name}',
                      style: GoogleFonts.bebasNeue(fontSize: 25, color: Colors.grey[800])),
                  const SizedBox(width: 5),
                  Text('Floor ${machineSnapshot.desc}',
                      style: GoogleFonts.bebasNeue(fontSize: 26, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                ],
              ),
              //Row shows how long ago the machine was last updated at.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(width: 15),
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
              //Row that shows operational, card, or cash
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          const SizedBox(width: 25),
                          if (machineSnapshot.card == 1) ...[
                            Image.asset('assets/images/card.png', height: 30),
                            const SizedBox(width: 20),
                            Text('Card accepted',
                                style: GoogleFonts.bebasNeue(fontSize: 18)),
                          ] else ...[
                            Image.asset('assets/images/nocard.png', height: 30),
                            const SizedBox(width: 20),
                            Text('Card Not accepted',
                                style: GoogleFonts.bebasNeue(fontSize: 18)),
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
                            Image.asset('assets/images/cash.png', height: 30),
                            const SizedBox(width: 20),
                            Text('Cash accepted',
                                style: GoogleFonts.bebasNeue(fontSize: 18)),
                          ] else ...[
                            Image.asset('assets/images/cash.png', height: 30),
                            const SizedBox(width: 20),
                            Text('Cash Not accepted',
                                style: GoogleFonts.bebasNeue(fontSize: 18)),
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
                                style: GoogleFonts.bebasNeue(fontSize: 18)),
                          ] else if(machineSnapshot.operational == 0)...[
                            const Icon(Icons.clear_rounded, color: Colors.red),
                            const SizedBox(width: 20),
                            Text('Not Operational',
                                style: GoogleFonts.bebasNeue(fontSize: 18)),
                          ] else ...[
                            //not sure if operational
                          ],
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                          const SizedBox(height: 60),
                          const SizedBox(width: 20),
                            ElevatedButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.all(20)),
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.pinkAccent),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(color: Colors.pink[900]!,
                                              width: 2)))),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const UpdateMachinePage()));
                              },
                              child: const Text('Update Machine'),
                            ),
                      ],
                      ),
                    ]),
                  ),
                  //Enlarge image when clicked
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        selectedMachine?.imagePath == ''
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
                                      color: Colors.pink,
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),

                                  body: SafeArea(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        height: MediaQuery.of(context).size.height,
                                        width: MediaQuery.of(context).size.width,
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
                          child: SizedBox(
                            width: 200,
                            height: 280,
                            child: Image.network(
                              selectedMachine!.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                  const SizedBox(height: 30),
            ]));
          }
        });
  }
}
