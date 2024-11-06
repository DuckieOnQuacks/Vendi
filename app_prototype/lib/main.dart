import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/backend/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart'; // Import your ThemeProvider class

// Main function that runs when the app is launched
Future<void> main() async {
  // Ensuring that the widgets are initialized
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Initializing Firebase
  await Firebase.initializeApp();
  // Running the MyApp widget wrapped with ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
  FlutterNativeSplash.remove();
}

// The main widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

// Define light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.pink),
    cardColor: Colors.white,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.grey[700]),
      titleLarge: TextStyle(color: Colors.black87),
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.pink,
      secondary: Colors.pinkAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
  );

// Define dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black54,
    iconTheme: const IconThemeData(color: Colors.pink),
    cardColor: Colors.grey[800],
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.grey[400]),
      titleLarge: TextStyle(color: Colors.white70),
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.pink,
      secondary: Colors.pinkAccent,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Obtain the ThemeProvider from the context
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Returning a MaterialApp widget with theme configurations
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // The home page of the app is the AuthPage widget
      home: const AuthPage(),
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}
