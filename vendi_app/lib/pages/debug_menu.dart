import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vendi_app/backend/classes/firebase.dart';
import 'package:vendi_app/backend/classes/machine.dart';
import 'package:vendi_app/backend/message_helper.dart';

class DebugMenu extends StatefulWidget {
  const DebugMenu({Key? key}) : super(key: key);

  @override
  _DebugMenuState createState() => _DebugMenuState();
}

class _DebugMenuState extends State<DebugMenu> {
  List<Machine> machines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    setState(() {
      isLoading = true;
    });
    try {
      final machinesList = await FirebaseHelper().getAllMachines();
      setState(() {
        machines = machinesList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading machines: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteMachine(Machine machine) async {
    try {
      // Delete the image from Firebase Storage
      if (machine.imagePath.isNotEmpty) {
        try {
          final Uri uri = Uri.parse(machine.imagePath);
          final String imagePathDecoded = Uri.decodeFull(uri.path);
          final String imageId = imagePathDecoded.split('/').last;
          final Reference storageRef =
              FirebaseStorage.instance.ref().child('images/$imageId');
          await storageRef.delete();
          print('Image deleted successfully');
        } catch (e) {
          print('Error deleting image: $e');
        }
      }

      // Delete the machine from Firestore
      await FirebaseHelper().deleteMachineById(machine);
      print('Machine deleted successfully');

      // Refresh the machine list
      await _loadMachines();

      if (mounted) {
        showMessage(context, 'Success',
            'Machine and its image have been deleted successfully.');
      }
    } catch (e) {
      print('Error deleting machine: $e');
      if (mounted) {
        showMessage(
            context, 'Error', 'Failed to delete machine: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: machines.length,
              itemBuilder: (context, index) {
                final machine = machines[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(machine.name),
                    subtitle: Text(machine.desc),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Machine'),
                              content: Text(
                                  'Are you sure you want to delete ${machine.name}? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deleteMachine(machine);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
