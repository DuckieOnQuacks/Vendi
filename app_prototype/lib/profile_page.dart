import 'backend/machine_database_helper.dart';
import 'backend/message_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendi_app/login_page.dart';
import 'backend/user_helper.dart';
import 'package:google_fonts/google_fonts.dart';

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
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image.asset(
                    profilePicture[index],
                    height: 50,
                    width: 50,
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
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.pink),
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
                            color: Colors.pink,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Confirm Logout',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ]
                    ),
                    content: const Text(
                        'Are you sure you want to log out of your account?'),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[300],
                          onPrimary: Colors.black54,
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
                          primary: Colors.pinkAccent,
                          onPrimary: Colors.white,
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  user.lastname,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.bebasNeue(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    editName(context, "Enter your new first and last name");
                                  },
                                  icon: Icon(Icons.edit),
                                  color: Colors.pink,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(user.email, style: const TextStyle(fontSize: 15)),
                            ],
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
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.pinkAccent),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.pink[900]!,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                              ),
                              child: const Center(
                                child: Text(
                                'Update Profile Picture',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder<int?>(
                                future: getUserPoints(),
                                builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text('Error fetching points data');
                                  } else {
                                    final points = snapshot.data!;
                                    return Container(
                                      child: Text(
                                        'Total points gained: $points',
                                        style: GoogleFonts.bebasNeue(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder<int?>(
                                future: getUserMachines(),
                                builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text('Error fetching points data');
                                  } else {
                                    final totalMachines = snapshot.data!;
                                    return Text(
                                      'Total machines entered: $totalMachines',
                                      style: GoogleFonts.bebasNeue(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,

                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder<int?>(
                                future: getUserCap(),
                                builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text('Error fetching points data');
                                  } else {
                                    final totalPointsToday = snapshot.data!;
                                    return Text(
                                      'Total points today: $totalPointsToday',
                                      style: GoogleFonts.bebasNeue(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,

                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder<int>(
                                future: getMachineCount(),
                                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text('Error fetching points data');
                                  } else {
                                    final globalMachineCount = snapshot.data!;
                                    return Text(
                                      'Total Global Machines: $globalMachineCount',
                                      style: GoogleFonts.bebasNeue(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ])
                ),
              ),
            );
          }
        },
      ),
    );
  }
}