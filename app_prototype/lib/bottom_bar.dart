import 'package:flutter/material.dart';
import 'package:vendi_app/favorites_page_setup.dart';
import 'package:vendi_app/home_page.dart';
import 'package:vendi_app/points_page.dart';
import 'package:vendi_app/profile_page.dart';

// All code on this page was developed by the team using the flutter framework

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  int currentPage = 0;
  // What pages to load depending on the bottom bar index
  List<Widget> pages = [
    const Homepage(),
    const FavoritesPageSetup(),
    const PointsPage(),
    ProfilePage()
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: pages.elementAt(_selectedIndex),
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
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey[700],
        selectedItemColor: Colors.pink,
        onTap: _onItemTapped,
      ),
    );
  }
}


