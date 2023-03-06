import 'package:flutter/material.dart';
import 'package:vendi_app/home_page.dart';
import 'package:vendi_app/points_page.dart';
import 'package:vendi_app/profile_page.dart';

import 'favorites_page.dart';

// All code on this page was developed by the team using the flutter framework

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int selectedIndex = 0;
  // What pages to load depending on the bottom bar index
  final Map<int, Widget> _pages = {
    0: const Homepage(),
    1: const FavoritesPageSetup(),
    2: const PointsPage(),
    3: ProfilePage(),
  };

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages[selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Points',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        unselectedItemColor: Colors.grey[700],
        selectedItemColor: Colors.pink,
        onTap: _onItemTapped,
      ),
    );
  }
}


