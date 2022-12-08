import 'package:flutter/material.dart';
import 'package:vendi_app/favorites_page.dart';
import 'package:vendi_app/points_page.dart';
import 'package:vendi_app/profile_page.dart';
import 'package:vendi_app/register_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {

  int currentPage = 0;
  List<Widget> pages = const [RegisterPage(), FavoritesPage(), PointsPage(), ProfilePage()]; // Switch RegisterPage to the map SDK on
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],

      // Navigation bar at the bottom of the screen
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pin_drop), label: 'Locations',),
          NavigationDestination(icon: Icon(Icons.thumb_up), label: 'Favorites',),
          NavigationDestination(icon: Icon(Icons.attach_money), label: 'Points',),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile',),
        ],
        onDestinationSelected: (int index)
        {
          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}