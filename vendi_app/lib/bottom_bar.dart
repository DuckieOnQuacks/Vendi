import 'package:flutter/material.dart';
import 'package:vendi_app/pages/home.dart';
import 'package:vendi_app/pages/leaderboard.dart';
import 'package:vendi_app/pages/profile.dart';
import 'package:vendi_app/pages/favorites.dart';

// All code on this page was developed by the team using the flutter framework

class BottomBar extends StatefulWidget {
  final VoidCallback? onMachineAdded;
  const BottomBar({Key? key, this.onMachineAdded}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int selectedIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      Homepage(),
      FavoritesPage(),
      PointsPage(),
      ProfilePage(),
    ];
    // Call the callback after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onMachineAdded != null) {
        widget.onMachineAdded!();
      }
    });
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          elevation: 1,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.pin_drop_outlined),
              activeIcon: Icon(Icons.pin_drop),
              label: 'Locations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
