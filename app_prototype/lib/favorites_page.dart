import 'package:flutter/material.dart';
import 'package:vendi_app/home_page.dart';

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
    // Stateful widget for dynamically updating the favorites page as favorite machines are added to it
    var newMachines = machines.where((machine) => machine.isFavorited == true).toList();
    return ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: newMachines.length,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[200],
          ),
          child: Card(
            child: ListTile(
              leading: Image.asset(newMachines[index].asset),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    newMachines[index].isFavorited = false;
                  });
                },
              ),
              title: Text(
                newMachines[index].name,
              ),
              subtitle: Text(
                newMachines[index].machineDesc,
              ),
              onTap:() {print('onTap pressed');},
              tileColor: Colors.grey[200],
      ),
          ),
        ),
    );
  }
}
