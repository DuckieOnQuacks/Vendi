import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vendi_app/bottom_bar.dart';
import 'package:vendi_app/home_page.dart';
import 'package:vendi_app/login_page.dart';


//This page is used to decide what the screen should look like based on if they are signed in or not.
class AuthPage extends StatelessWidget{
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context , snapshot) {
          if(snapshot.hasData){
            return const BottomBar();
          } else {
            return LoginPage();
          }
        }
      ),
    );
  }
}