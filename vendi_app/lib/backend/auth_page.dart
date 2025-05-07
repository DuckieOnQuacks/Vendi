import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendi_app/bottom_bar.dart';
import 'package:vendi_app/pages/register.dart';

// This page is used to decide what the screen should look like based on if the user is signed in or not.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a StreamBuilder to listen for changes in the authentication state of the user.
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // If the user is already signed in, show the main app screen.
            if (snapshot.hasData) {
              return const BottomBar();
            }
            // If the user is not signed in, show the login screen.
            else {
              return const RegisterPage();
            }
          }),
    );
  }
}
