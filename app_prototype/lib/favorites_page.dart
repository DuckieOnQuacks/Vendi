import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'backend/machine_class.dart';
import 'main.dart';

// All code on this page was developed by the team using the flutter framework

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritesPage> {
  Future<List<Machine>>? futureMachines;

  @override
  void initState() {
    super.initState();
    futureMachines = dbHelper.getAllFavorited();
  }

  void onDeleteButtonPressed(Machine machine) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => DeleteMachineDialog(machine: machine),
    );
    if (result != null && result) {
      setState(() {
        futureMachines = dbHelper.getAllFavorited();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Machine>>(
      future: futureMachines,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final favMachines = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: favMachines.length,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[200],
              ),
              child: Card(
                child: ListTile(
                  leading: Image.asset(favMachines[index].icon),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDeleteButtonPressed(favMachines[index]),
                  ),
                  title: Text(
                    favMachines[index].name,
                  ),
                  subtitle: Text(
                    favMachines[index].desc,
                  ),
                  onTap: () {
                    if (kDebugMode) {
                      print('onTap pressed');
                    }
                  },
                  tileColor: Colors.grey[200],
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class DeleteMachineDialog extends StatelessWidget {
  final Machine machine;

  const DeleteMachineDialog({Key? key, required this.machine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Are you sure you want to delete this item?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            machine.isFavorited = 0;
            await dbHelper.saveMachine(machine);
            Navigator.of(context).pop(true);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class FavoritesPageSetup extends StatelessWidget {
  const FavoritesPageSetup({super.key});
  @override
  Widget build(BuildContext context) {
    // Sets up a favorites page using a scaffold object
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: const [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: FavoritesPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

