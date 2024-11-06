import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vendi_app/backend/user_helper.dart';
import 'package:vendi_app/machine_bottom_sheet.dart';
import 'backend/machine_class.dart';

// All code on this page was developed by the team using the flutter framework
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritesPage> {
  Future<List<Machine>>? favMachines;

  @override
  void initState() {
    super.initState();
    favMachines = getMachinesFavorited();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          height: 32,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<List<Machine>>(
        future: favMachines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final favMachines = snapshot.data!;
            if (favMachines.isEmpty) {
              return const Center(
                child: Text("No Favorite Machines"),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: favMachines.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Theme.of(context).cardColor.withOpacity(0.8), // Changed background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Image.asset(favMachines[index].icon),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Theme.of(context).iconTheme.color, // Adapt icon color to theme
                      ),
                      onPressed: () =>
                          onDeletePressed(favMachines[index]),
                    ),
                    title: Text(
                      favMachines[index].name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Floor: ${favMachines[index].desc}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () =>
                        showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              MachineBottomSheet(favMachines[index]),
                        ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("No Favorite Machines"),
            );
          }
        },
      ),
    );
  }

  void onDeletePressed(Machine machine) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => DeleteMachineDialog(machine: machine),
    );
    if (result != null && result) {
      await removeMachineFromFavorited(machine.id);
        setState(() {
          //Scan for favorites again after deletion
          favMachines = getMachinesFavorited();
        });
    }
  }
}

  class DeleteMachineDialog extends StatelessWidget {
  final Machine machine;

  const DeleteMachineDialog({Key? key, required this.machine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      buttonPadding: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orangeAccent
          ),
          SizedBox(width: 10),
          Text(
            'Confirm Delete',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color, // Adapt icon color to theme
            ),
          ),
        ],
      ),
      content: const Text('Are you sure you want to remove this machine from your favorites?'),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            removeMachineFromFavorited(machine.id);
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

