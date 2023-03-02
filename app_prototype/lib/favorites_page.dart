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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dbHelper.getAllFavorited(),
      builder: (context, AsyncSnapshot<List<Machine>> snapshot) {
        if (snapshot.hasData) {
          final favMachines = snapshot.data;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: favMachines!.length,
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
                    onPressed: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this item?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      favMachines[index].isFavorited = 0;
                                      dbHelper.saveMachine(favMachines[index]);
                                      dbHelper.getAllFavorited();
                                      Navigator.of(context).pop(true);
                                    });
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        ).then((value) {
                          if (value != null && value == true) {
                            // Perform deletion logic here
                          }
                        });
                      });
                    },
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
