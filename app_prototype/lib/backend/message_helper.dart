import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';


void showConfettiDialog(BuildContext context, String message) {
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          _confettiController.stop();
          return true;
        },
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                blastDirection: 3.14 * 2, // Set blast direction to half-circle
                emissionFrequency: 0.02,
                numberOfParticles: 10,
                maxBlastForce: 60,
                minBlastForce: 40,
                colors: [
                  Colors.green,
                  Colors.yellow,
                  Colors.blue,
                  Colors.red,
                  Colors.orange,
                ],
              ),
              //SizedBox(height: 16),
              Text(
                'Congratulations!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    },
  );
  _confettiController.play();
}