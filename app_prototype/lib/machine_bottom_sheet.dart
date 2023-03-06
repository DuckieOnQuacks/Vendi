import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/backend/firebase_helper.dart';
import 'package:vendi_app/backend/machine_class.dart';
import 'package:favorite_button/favorite_button.dart';
import 'Addmachine.dart';
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
  bool isFavorite = selectedMachine?.isFavorited == 1;
  Future<Machine?> selectedMachineDB = FirebaseHelper().getMachineById(selectedMachine!);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: selectedMachineDB,
        builder: (BuildContext context, AsyncSnapshot<Machine?> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData) {
        return const Center(child: Text('No data found'));
      } else {
        Machine machine = snapshot.data!;
        return Center(
          child: Column(children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Image.asset(machine.icon, height: 50),
                const SizedBox(width: 20),
                if(machine.icon == 'assets/images/BlueMachine.png')...[
                  Text('Snack Machine', style: GoogleFonts.bebasNeue(fontSize: 30)),
                  const SizedBox(width: 20),
                ]else if(machine.icon == 'assets/images/PinkMachine.png')...[
                  Text('Beverage Machine', style: GoogleFonts.bebasNeue(fontSize: 30)),
                  const SizedBox(width: 20),
                ] else...[
                  Text('Supply Machine', style: GoogleFonts.bebasNeue(fontSize: 30)),
                  const SizedBox(width: 20),
                ],
                StatefulBuilder(builder: (BuildContext context, setState) {
                  // Checkbox for favoriting the machine
                  return FavoriteButton(
                    isFavorite: isFavorite,
                    valueChanged: (value) {
                      setState(() {
                        isFavorite = value;
                      });
                      if (isFavorite) {
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
                }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 15),
                Text(machine.name,
                    style: GoogleFonts.bebasNeue(fontSize: 25)),
                const SizedBox(width: 10),
                Text(machine.desc, style: GoogleFonts.bebasNeue(fontSize: 25)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 15),
                Text('Last updated:',
                    style: GoogleFonts.bebasNeue(fontSize: 25)),
                const SizedBox(width: 10),
                Text('January 1, 2023', style: GoogleFonts.getFont(
                    'Bebas Neue', fontSize: 25, color: Colors.grey[600])),
                const SizedBox(width: 5),
                Text('12:00pm', style: GoogleFonts.getFont(
                    'Bebas Neue', fontSize: 25, color: Colors.grey[600])),
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
                          if(machine.card == 1)...[
                            Image.asset('assets/images/card.png', height: 30),
                            const SizedBox(width: 20),
                            Text('Card accepted', style: GoogleFonts.bebasNeue(fontSize: 16)),
                          ]else...[
                            Image.asset('assets/images/nocard.png', height: 30),
                            const SizedBox(width: 20),
                            Text('Card Not accepted', style: GoogleFonts.bebasNeue(fontSize: 16)),
                          ],
                        ],),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          const SizedBox(width: 20),
                          const SizedBox(width: 5),
                          if(machine.cash == 1)...[
                            Image.asset('assets/images/cash.png', height: 30),
                            const SizedBox(width: 20),
                            Text('Cash accepted', style: GoogleFonts.bebasNeue(fontSize: 16)),
                          ]else...[
                            Image.asset('assets/images/cash.png', height: 30),
                            const SizedBox(width: 20),
                            Text('Cash Not accepted', style: GoogleFonts.bebasNeue(fontSize: 16)),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          const SizedBox(width: 20),
                          if(machine.stock == 1)...[
                            const Icon(Icons.check, color: Colors.green),
                            const SizedBox(width: 20),
                            Text('Stocked', style: GoogleFonts.bebasNeue(fontSize: 16)),
                          ]else...[
                            const Icon(Icons.clear_rounded, color: Colors.red),
                            const SizedBox(width: 20),
                            Text('Not Stocked', style: GoogleFonts.bebasNeue(fontSize: 16)),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          const SizedBox(width: 20),
                          if(machine.operational == 1)...[
                            const Icon(Icons.check, color: Colors.green),
                            const SizedBox(width: 20),
                            Text('Operational', style: GoogleFonts.bebasNeue(fontSize: 16)),
                          ]else...[
                            const Icon(Icons.clear_rounded, color: Colors.red),
                            const SizedBox(width: 20),
                            Text('Not Operational', style: GoogleFonts.bebasNeue(fontSize: 16)),
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
                        child: Image.network(selectedMachine!.imagePath),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Interactable close menu button
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddMachinePage()),
                  );
                },
                child: const Text("Update Machine"))
          ]),
        );
      }
      }
    );
  }
}
