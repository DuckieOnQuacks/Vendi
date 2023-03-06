import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/backend/machine_class.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Image.asset('assets/images/BlueMachine.png', height: 50),
            SizedBox(width: 20),
            Text('Beverage Machine', style: GoogleFonts.bebasNeue(fontSize: 30)),
            SizedBox(width: 20),
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
            children: <Widget> [
              SizedBox(width: 15),
              Text('Ansari Building,', style: GoogleFonts.bebasNeue(fontSize: 25)),
              SizedBox(width: 10),
              Text('3rd Floor', style: GoogleFonts.bebasNeue(fontSize: 25)),
    ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            SizedBox(width: 15),
            Text('Last updated:', style: GoogleFonts.bebasNeue(fontSize: 25)),
            SizedBox(width: 10),
            Text('January 1, 2023', style: GoogleFonts.getFont('Bebas Neue', fontSize: 25, color: Colors.grey[600])),
            SizedBox(width: 5),
            Text('12:00pm', style: GoogleFonts.getFont('Bebas Neue', fontSize: 25, color: Colors.grey[600])),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
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

        // Interactable close menu button
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMachinePage()),
              );
            },
            child: const Text("Update Machine"))
      ]),
    );
  }
}