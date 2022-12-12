import 'package:flutter/material.dart';
import 'package:vendi_app/home_page.dart';
import 'package:vendi_app/favorites_page.dart';

class FavoritesPageSetup extends StatelessWidget {
  const FavoritesPageSetup({super.key});

  @override
  Widget build(BuildContext context) {
    var newMachines = machines.where((machine) => machine.isFavorited == true).toList();
    return Scaffold(
      appBar: AppBar( automaticallyImplyLeading: false,
        title: Text(
          'Favorites Page',
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: FavoritesPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}