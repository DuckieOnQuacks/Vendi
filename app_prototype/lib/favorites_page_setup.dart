import 'package:flutter/material.dart';
import 'package:vendi_app/home_page.dart';
import 'package:vendi_app/favorites_page.dart';

// All code on this page was developed by the team using the flutter framework

class FavoritesPageSetup extends StatelessWidget {
  const FavoritesPageSetup({super.key});
  @override
  Widget build(BuildContext context) {
    //var newMachines = machines.where((machine) => machine.isFavorited == true).toList();
    // Sets up a favorites page using a scaffold object
    return Scaffold(
      appBar: AppBar( automaticallyImplyLeading: false,
        title: const Text(
          'Favorites Page',
        ),
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