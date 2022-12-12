import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:vendi_app/edit_profile.dart';
import 'package:vendi_app/register_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
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
                          image: AssetImage(
                              'assets/images/KermitProfile.jpg'
                          ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Kermit', style: Theme.of(context).textTheme.headline4),
                  Text('kermit@gmail.com', style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                          return const EditProfile();
                          return const RegisterPage();
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow, side: BorderSide.none, shape: const StadiumBorder()),
                      child: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        )

    );
  }
}