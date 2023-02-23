import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendi_app/edit_profile.dart';

// All code on this page was developed by the team using the flutter framework

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  void signUserOut() {
  FirebaseAuth.instance.signOut();
}
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          actions: <Widget>[IconButton(
              onPressed: signUserOut,
              icon: Icon(Icons.logout))],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const Image(
                        image: AssetImage('assets/images/KermitProfile.jpg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user.email!, style: Theme.of(context).textTheme.headline4),
                  Text(user.email!, style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return const EditProfile();
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          side: BorderSide.none,
                          shape: const StadiumBorder()),
                      child: const Text('Edit Profile',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ));
  }
}
