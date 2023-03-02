import 'package:flutter/material.dart';
import 'package:vendi_app/backend/auth_page.dart';
import 'backend/database_helper.dart';
import 'package:firebase_core/firebase_core.dart';

// Creating an instance of the DatabaseHelper class
final dbHelper = DatabaseHelper();

// Main function that runs when the app is launched
Future<void> main() async {
  // Ensuring that the widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initializing the database helper
  await dbHelper.init();
  // Initializing Firebase
  await Firebase.initializeApp();
  // Running the MyApp widget
  runApp(const MyApp());
}

// The main widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Returning a MaterialApp widget with the debug banner turned off
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // The home page of the app is the AuthPage widget
      home: AuthPage(),
    );
  }
}
