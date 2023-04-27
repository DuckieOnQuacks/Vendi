import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendi_app/edit_profile.dart';
import 'package:vendi_app/login_page.dart';
import 'backend/user_helper.dart';


// All code on this page was developed by the team using the flutter framework

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  late final user = FirebaseAuth.instance.currentUser!;
  String firstName = '';
  String lastName = '';
  int points = 0;

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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.pink),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Log Out'),
                    content: const Text(
                        'Are you sure you want to log out of your account?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          signUserOut();
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (
                                  BuildContext context) {
                                return const LoginPage();
                              }));
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  );
                },
              ).then((value) {
                if (value != null && value == true) {
                  // Perform deletion logic here
                }
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<userInfo?>(
        future: getUserByEmail(user.email!),
        builder: (BuildContext context, AsyncSnapshot<userInfo?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No user data found'));
          } else {
            final user = snapshot.data!;
            return SingleChildScrollView(
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
                            image: AssetImage(
                                'assets/images/KermitProfile.jpg'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(user.firstname, style: const TextStyle(fontSize: 30)),
                          const SizedBox(width: 5),
                          Text(user.lastname, style: const TextStyle(fontSize: 30)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const EditProfile();
                                  }),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
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
            );
          }
        },
      ),
    );
  }
}

