import 'backend/machine_database_helper.dart';
import 'backend/message_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendi_app/login_page.dart';
import 'backend/user_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final user = FirebaseAuth.instance.currentUser!;
  String? imagePath = ' ';
  List<String> profilePicture = [
    'assets/images/profile_pic1.png',
    'assets/images/profile_pic2.png',
    'assets/images/profile_pic3.png',
    'assets/images/profile_pic4.png',
  ];

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void loadProfilePicture() async {
    final imagePath = await getProfilePic();
    setState(() {
      this.imagePath = imagePath;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProfilePicture();
  }

  void _selectProfilePicture(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(profilePicture.length, (index) {
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    imagePath = profilePicture[index];
                  });
                  Navigator.pop(context);
                  // update user's profile picture
                  await updateProfilePic(imagePath);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: imagePath == profilePicture[index]
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    profilePicture[index],
                    height: 60,
                    width: 60,
                  ),
                ),
              );
            }),
          ),
        );
      },
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
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    buttonPadding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    title: Row(
                        children:[
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Confirm Logout',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ]
                    ),
                    content: Text(
                        'Are you sure you want to log out of your account?',
                        style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          signUserOut();
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (
                                  BuildContext context) {
                                return const LoginPage();
                              })
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              child: Image(
                                image: AssetImage(imagePath!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.firstname + ' ',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 40,
                                    color: Theme.of(context).textTheme.titleLarge?.color,
                                  ),
                                ),
                                Text(
                                  user.lastname,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 40,
                                    color: Theme.of(context).textTheme.titleLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              onPressed: () {
                                _selectProfilePicture(context);
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  const EdgeInsets.all(20),
                                ),
                                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                              ),
                              child: Center(
                                child: Text(
                                'Update Profile Picture',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondary, // Updated
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoCard(context, Icons.star, 'Total points gained', getUserPoints(), 30),
                          const SizedBox(height: 10),
                          _buildInfoCard(context, Icons.vpn_key, 'Total machines entered', getUserMachines(), 30),
                          const SizedBox(height: 10),
                          _buildInfoCard(context, Icons.update, 'Total points today', getUserCap(), 30),
                          const SizedBox(height: 30),
                          _buildGlobalInfoCard(context, 'Wow! Our Vendi Users have added a total of ', getMachineCount(), ' machines globally. Thank you!', 20),
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

  Widget _buildInfoCard(BuildContext context, IconData icon, String title, Future<int?> future, double fontSize) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black45,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<int?>(
          future: future,
          builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching data');
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Theme.of(context).iconTheme.color, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    '$title: ${snapshot.data!}',
                    style: GoogleFonts.bebasNeue(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGlobalInfoCard(BuildContext context, String prefix, Future<int> future, String suffix, double fontSize) {
    return FutureBuilder<int>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error fetching data');
        } else {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '$prefix ${snapshot.data!} $suffix',
              style: GoogleFonts.oswald(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }
      },
    );
  }
}