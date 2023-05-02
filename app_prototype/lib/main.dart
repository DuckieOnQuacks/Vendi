import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:vendi_app/backend/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';

// Main function that runs when the app is launched
Future<void> main() async {
  // Ensuring that the widgets are initialized
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Initializing Firebase
  await Firebase.initializeApp();
  // Running the MyApp widget
  runApp(const MyApp());
  FlutterNativeSplash.remove();
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
