import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';

final dbHelper = DatabaseHelper();
// All code on this page was developed by the team using the flutter framework
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.init();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}