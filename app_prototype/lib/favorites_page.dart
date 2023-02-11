import 'package:flutter/material.dart';
import 'package:vendi_app/home_page.dart';
import 'machine_class.dart';
import 'main.dart';

// All code on this page was developed by the team using the flutter framework

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context)
  {
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
                        favMachines[index].isFavorited = 0;
                      });
                    },
                  ),
                  title: Text(
                    favMachines[index].id.toString(),
                  ),
                  subtitle: Text(
                    favMachines[index].desc,
                  ),
                  onTap:() {print('onTap pressed');},
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
