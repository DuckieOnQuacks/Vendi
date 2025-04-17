// settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Widget buildDarkModeSwitch(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        themeProvider.toggleTheme(value);
      },
      secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
        children: [
        Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        height: 32,
    )
    ],
    ),
      ),
      body: ListView(
        children: [
          buildDarkModeSwitch(context),
        ],
      ),
    );
  }
}
