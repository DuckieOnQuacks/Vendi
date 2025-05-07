import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:vendi_app/backend/classes/user.dart';

// Beta feedback options
final List<String> betaFeedbackOptions = [
  'Bug Report',
  'Feature Request',
  'UI/UX Feedback',
  'Performance Issue',
  'Other Feedback'
];

// Show the beta feedback dialog
void showBetaFeedbackDialog(BuildContext context) {
  // Default selected option
  String selectedOption = betaFeedbackOptions[0];
  // Text controller for feedback details
  final feedbackController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.bug_report,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Beta Feedback',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
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
                    Text(
                      'Feedback Type:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedOption,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: betaFeedbackOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
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
                          selectedOption = value!;
                        });
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Feedback Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: feedbackController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Describe your feedback in detail...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Submit Feedback'),
                onPressed: () async {
                  // Check if feedback details are provided
                  if (feedbackController.text.isEmpty) {
                    showMessage(
                      context,
                      'Missing Details',
                      'Please provide some details for your feedback.',
                    );
                    return;
                  }

                  // Submit the feedback
                  await saveBetaNote(
                    selectedOption,
                    feedbackController.text,
                  );

                  // Clear the form
                  feedbackController.clear();

                  Navigator.of(context).pop();

                  // Show confirmation
                  showConfettiDialog(
                    context,
                    'Thank you for your feedback! Your input helps us improve Vendi.',
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}

void showConfettiDialog(BuildContext context, String message) {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      Timer(const Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });

      return WillPopScope(
        onWillPop: () async {
          _confettiController.stop();
          return true;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Confetti background
                Positioned.fill(
                  left: 100,
                  right: 100,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    blastDirection: 3.14 * 2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 10,
                    maxBlastForce: 60,
                    minBlastForce: 40,
                    colors: [
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.red,
                      Colors.purple,
                      Colors.orange,
                      Colors.pink,
                    ],
                  ),
                ),
                // Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Congratulations!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  _confettiController.play();
}

//Message widget that can be used to show pop up messages throughout the app
//Pass in context and the message you want on the pop up
void showMessage(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title + ':',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  child: Text('OK', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showWarning(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Theme.of(context).colorScheme.error,
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Warning:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  child: Text('OK', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showNotice(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Notice:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  child: Text('OK', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showWarning2(BuildContext context, String message) async {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.amber,
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Warning:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  child: Text('OK', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
