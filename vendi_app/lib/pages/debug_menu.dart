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
  bool isAuthenticated = false;
  final TextEditingController _feedbackController = TextEditingController();
  final String _adminPassword = "3122";

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
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

  void _showFeedbackDialog() {
    showBetaFeedbackDialog(context);
  }

  void _handlePasswordSubmit(String password) {
    if (password == _adminPassword) {
      setState(() {
        isAuthenticated = true;
      });
      showMessage(context, 'Success', 'Access granted');
    } else {
      showMessage(context, 'Error', 'Incorrect password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beta Menu'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Machine Management'),
              Tab(text: 'Beta Feedback'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Machine Management Tab
            !isAuthenticated
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Machine Management is Password Protected',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please enter the admin password to access this feature.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            showPasswordDialog(
                              context,
                              onPasswordSubmit: _handlePasswordSubmit,
                            );
                          },
                          icon: const Icon(Icons.lock_open),
                          label: const Text('Enter Password'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: machines.length,
                        itemBuilder: (context, index) {
                          final machine = machines[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(machine.name),
                              subtitle: Text(machine.desc),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showConfirmationDialog(
                                    context,
                                    title: 'Delete Machine',
                                    message:
                                        'Are you sure you want to delete ${machine.name}? This action cannot be undone.',
                                    confirmText: 'Delete',
                                    onConfirm: () => _deleteMachine(machine),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),

            // Beta Feedback Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Help Improve Vendi',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your feedback helps us make Vendi better. Please let us know about any issues you encounter or suggestions you have.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showFeedbackDialog,
                            icon: const Icon(Icons.feedback),
                            label: const Text('Submit Feedback'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Known Issues',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          _buildIssueItem(
                            'Map Loading',
                            'The map may take a few seconds to load initially.',
                            Icons.map,
                          ),
                          _buildIssueItem(
                            'Location Services',
                            'Please ensure location services are enabled for full functionality.',
                            Icons.location_on,
                          ),
                          _buildIssueItem(
                            'Image Upload',
                            'Large images may take longer to upload.',
                            Icons.image,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
