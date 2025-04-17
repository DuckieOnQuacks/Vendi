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
    'assets/images/profile_pic5.png',
    'assets/images/profile_pic6.png',
    'assets/images/profile_pic7.png',
    'assets/images/profile_pic8.png',
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
          height: 250,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First row of 4 icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
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
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        profilePicture[index],
                        height: 70,
                        width: 70,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 15),
              // Second row of 4 icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        imagePath = profilePicture[index + 4];
                      });
                      Navigator.pop(context);
                      // update user's profile picture
                      await updateProfilePic(imagePath);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        profilePicture[index + 4],
                        height: 70,
                        width: 70,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            icon:
                Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
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
                    title: Row(children: [
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
                    ]),
                    content: Text(
                      'Are you sure you want to log out of your account?',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          signUserOut();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return const LoginPage();
                          }));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
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
            return Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top profile section with curved background
                    Container(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25.0),
                        child: Column(
                          children: [
                            // Profile picture with ring decoration
                            GestureDetector(
                              onTap: () => _selectProfilePicture(context),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Decorative outer ring
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Profile picture
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        width: 4,
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(imagePath!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Edit icon
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Name with animated effect
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                '${user.firstname} ${user.lastname}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 40,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Email display
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Stats section title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insights,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Stats',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Stats cards in a row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _buildStatCard(
                            context,
                            Icons.star,
                            'Total Points',
                            getUserPoints(),
                            Theme.of(context).colorScheme.primary,
                          ),
                          _buildStatCard(
                            context,
                            Icons.vpn_key,
                            'Machines',
                            getUserMachines(),
                            Theme.of(context).colorScheme.secondary,
                          ),
                          _buildStatCard(
                            context,
                            Icons.update,
                            'Today',
                            getUserCap(),
                            Colors.amber,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Global stats card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildGlobalInfoCard(
                        context,
                        'Wow! Our Vendi Users have added a total of ',
                        getMachineCount(),
                        ' machines globally. Thank you!',
                        16,
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String title,
      Future<int?> future, Color iconColor) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: FutureBuilder<int?>(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error'));
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: iconColor, size: 26),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.data.toString(),
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalInfoCard(BuildContext context, String prefix,
      Future<int> future, String suffix, double fontSize) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: FutureBuilder<int>(
          future: future,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            } else if (snapshot.hasError) {
              return const Text('Error fetching data');
            } else {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.public, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Global Impact',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.roboto(
                        fontSize: fontSize,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: prefix),
                        TextSpan(
                          text: '${snapshot.data!}',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize + 2,
                          ),
                        ),
                        TextSpan(text: suffix),
                      ],
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
}
