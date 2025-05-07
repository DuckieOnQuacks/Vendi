import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendi_app/pages/login.dart';
import '../backend/classes/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../backend/classes/theme_provider.dart';
import 'package:vendi_app/backend/classes/machine.dart';
import 'settings.dart';
import 'debug_menu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final user = FirebaseAuth.instance.currentUser!;
  String? imagePath = ' ';
  int currentPoints = 0;
  int userMachinesCount = 0;
  bool isSnackCollectiblesInitialized = false;
  // State for the toggle buttons
  List<bool> _isSelected = [
    true,
    false,
    false
  ]; // Index 0: Stats, Index 1: Global, Index 2: Achievements
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

  // Define level thresholds
  final List<Map<String, dynamic>> levels = [
    {
      'name': 'Rookie',
      'threshold': 0,
      'color': Colors.teal,
      'icon': Icons.emoji_events_outlined
    },
    {
      'name': 'Explorer',
      'threshold': 500,
      'color': Colors.deepPurple,
      'icon': Icons.explore
    },
    {
      'name': 'Hunter',
      'threshold': 1000,
      'color': Colors.amber.shade700,
      'icon': Icons.trending_up
    },
    {
      'name': 'Champion',
      'threshold': 2000,
      'color': Colors.orange.shade800,
      'icon': Icons.whatshot
    },
    {
      'name': 'Hero',
      'threshold': 3500,
      'color': Colors.red.shade700,
      'icon': Icons.bolt
    },
    {
      'name': 'Legend',
      'threshold': 5000,
      'color': Colors.indigo,
      'icon': Icons.auto_awesome
    },
    {
      'name': 'Vendi Master',
      'threshold': 10000,
      'color': Colors.deepPurple.shade900,
      'icon': Icons.workspace_premium
    },
  ];

  // Define the snack collectibles
  final List<Map<String, dynamic>> snackCollectibles = [
    {
      'id': 1,
      'name': 'Generic Chips',
      'rarity': 'Common',
      'description': 'A classic snack that never goes out of style',
      'achievement': 'Add your first vending machine',
      'pointsNeeded': 0,
      'machinesNeeded': 1,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_02.png',
      'color': Colors.orange,
    },
    {
      'id': 2,
      'name': 'Juciebox',
      'rarity': 'Common',
      'description': 'Fresh and nutritious, pairs well with a hot day',
      'achievement': 'Reach 50 points',
      'pointsNeeded': 50,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_04.png',
      'color': Colors.green,
    },
    {
      'id': 3,
      'name': 'Strawberry Jam',
      'rarity': 'Common',
      'description': 'Sweet and fruity, perfect for toast',
      'achievement': 'Add 3 vending machines',
      'pointsNeeded': 0,
      'machinesNeeded': 3,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_10.png',
      'color': Colors.pink,
    },
    {
      'id': 4,
      'name': 'Creme Soda',
      'rarity': 'Uncommon',
      'description': 'Nature\'s liquid gold, sweet and delicious',
      'achievement': 'Reach 150 points',
      'pointsNeeded': 150,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_13.png',
      'color': Colors.amber.shade700,
    },
    {
      'id': 5,
      'name': 'Water Bottle',
      'rarity': 'Common',
      'description': 'Stay hydrated with this refreshing drink',
      'achievement': 'Log in 3 days in a row',
      'pointsNeeded': 30,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_17.png',
      'color': Colors.blue,
    },
    {
      'id': 6,
      'name': 'Energy Drink',
      'rarity': 'Uncommon',
      'description': 'Get an extra boost when you need it most',
      'achievement': 'Add 5 machines',
      'pointsNeeded': 0,
      'machinesNeeded': 5,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_18.png',
      'color': Colors.indigo,
    },
    {
      'id': 7,
      'name': 'Magic Muffin',
      'rarity': 'Rare',
      'description': 'Add some magic to your collection',
      'achievement': 'Reach 300 points',
      'pointsNeeded': 300,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_21.png',
      'color': Colors.red,
    },
    {
      'id': 8,
      'name': 'Frosty',
      'rarity': 'Uncommon',
      'description':
          'Cool beverage for a hot day, or a hot day for a cool beverage',
      'achievement': 'Add your first machine description',
      'pointsNeeded': 75,
      'machinesNeeded': 1,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_23.png',
      'color': Colors.yellow.shade800,
    },
    {
      'id': 9,
      'name': 'Chocolate Bar',
      'rarity': 'Rare',
      'description': 'Rich and satisfying, a classic favorite',
      'achievement': 'Reach 450 points',
      'pointsNeeded': 450,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_26.png',
      'color': Colors.brown,
    },
    {
      'id': 10,
      'name': 'Choco Supreme',
      'rarity': 'Rare',
      'description': 'Crunchy and addictive, impossible to eat just one',
      'achievement': 'Add 10 machines',
      'pointsNeeded': 0,
      'machinesNeeded': 10,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_27.png',
      'color': Colors.green.shade700,
    },
    {
      'id': 11,
      'name': 'Decent Chips',
      'rarity': 'Uncommon',
      'description': 'A sweet treat that lasts and lasts',
      'achievement': 'Reach 600 points',
      'pointsNeeded': 600,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_28.png',
      'color': Colors.red.shade400,
    },
    {
      'id': 12,
      'name': 'Dang Now Thats Some Good Candy',
      'rarity': 'Epic',
      'description': 'A rare and precious treat for dedicated collectors',
      'achievement': 'Reach 800 points',
      'pointsNeeded': 800,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_30.png',
      'color': Colors.blue.shade300,
    },
    {
      'id': 13,
      'name': 'Infinity Pop',
      'rarity': 'Epic',
      'description': 'Contains mysterious powers and flavors',
      'achievement': 'Add 15 machines',
      'pointsNeeded': 0,
      'machinesNeeded': 15,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_31.png',
      'color': Colors.purple,
    },
    {
      'id': 14,
      'name': 'Commitment Candy',
      'rarity': 'Common',
      'description': 'Pure, clean, and essential for any collection',
      'achievement': 'Log in 7 days total',
      'pointsNeeded': 70,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_32.png',
      'color': Colors.lightBlue.shade200,
    },
    {
      'id': 15,
      'name': 'Premium Soda',
      'rarity': 'Rare',
      'description': 'Fizzy, refreshing, and full of flavor',
      'achievement': 'Reach 1000 points',
      'pointsNeeded': 1000,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_33.png',
      'color': Colors.amber,
    },
    {
      'id': 16,
      'name': 'Fireball',
      'rarity': 'Uncommon',
      'description': 'Adds a kick to your growing collection',
      'achievement': 'Add 20 machines',
      'pointsNeeded': 0,
      'machinesNeeded': 20,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_34.png',
      'color': Colors.deepOrange,
    },
    {
      'id': 17,
      'name': 'Cosmic Chocolate',
      'rarity': 'Rare',
      'description': 'A colorful treat that brightens any collection',
      'achievement': 'Reach 1500 points',
      'pointsNeeded': 1500,
      'machinesNeeded': 0,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_35.png',
      'color': Colors.purple.shade300,
    },
    {
      'id': 18,
      'name': 'Milk Bottle',
      'rarity': 'Uncommon',
      'description': 'Farm fresh and delicious',
      'achievement': 'Add 25 machines',
      'pointsNeeded': 0,
      'machinesNeeded': 25,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_36.png',
      'color': Colors.white70,
    },
    {
      'id': 19,
      'name': 'Golden Syrup',
      'rarity': 'Legendary',
      'description': 'The rarest and most precious liquid treat',
      'achievement': 'Reach 2000 points and add 25 machines',
      'pointsNeeded': 2000,
      'machinesNeeded': 25,
      'isUnlocked': false,
      'imagePath': 'assets/achievements/Icon5_38.png',
      'color': Colors.amber.shade900,
    },
  ];

  // Get current level based on points
  Map<String, dynamic> getCurrentLevel() {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (currentPoints >= levels[i]['threshold']) {
        return levels[i];
      }
    }
    return levels[0]; // Default to first level
  }

  // Get next level based on points
  Map<String, dynamic> getNextLevel() {
    for (int i = 0; i < levels.length; i++) {
      if (currentPoints < levels[i]['threshold']) {
        return levels[i];
      }
    }
    return levels.last; // Return highest level if all levels are achieved
  }

  // Calculate progress to next level (0.0 to 1.0)
  double getLevelProgress() {
    final currentLevel = getCurrentLevel();
    final nextLevel = getNextLevel();

    // If already at max level
    if (currentLevel == nextLevel) {
      return 1.0;
    }

    final pointsForCurrentLevel = currentLevel['threshold'];
    final pointsForNextLevel = nextLevel['threshold'];
    final pointsNeeded = pointsForNextLevel - pointsForCurrentLevel;
    final pointsAchieved = currentPoints - pointsForCurrentLevel;

    return pointsAchieved / pointsNeeded;
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void loadProfilePicture() async {
    final imagePath = await getProfilePic();
    setState(() {
      this.imagePath = imagePath;
    });
  }

  void loadUserMachines() async {
    final machines = await getUserMachinesEntered();
    setState(() {
      userMachinesCount = machines ?? 0;
    });
    // After loading both points and machines, update the snack collectibles
    _updateSnackCollectibles();
  }

  void loadUserPoints() async {
    final points = await getUserPoints();
    setState(() {
      currentPoints = points ?? 0;
    });
    // After loading both points and machines, update the snack collectibles
    _updateSnackCollectibles();
  }

  @override
  void initState() {
    super.initState();
    isSnackCollectiblesInitialized = false; // Reset initialization flag
    loadProfilePicture();
    loadUserPoints();
    loadUserMachines();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If we've returned to this page and achievements were already initialized before
    if (isSnackCollectiblesInitialized) {
      isSnackCollectiblesInitialized = false;
      _updateSnackCollectibles();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _selectProfilePicture(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).cardColor,
                      Theme.of(context).cardColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 12.0, bottom: 8.0),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).cardColor,
                      Theme.of(context).cardColor.withOpacity(1),
                    ],
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(imagePath!, height: 40),
                        const SizedBox(width: 15),
                        Text(
                          'Choose Profile Picture',
                          style: GoogleFonts.bebasNeue(fontSize: 36),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // First row of 4 icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              imagePath = profilePicture[index];
                            });

                            // Update the theme primary color based on profile picture
                            Provider.of<ThemeProvider>(context, listen: false)
                                .updatePrimaryColor(profilePicture[index]);

                            Navigator.pop(context);
                            // update user's profile picture
                            await updateProfilePic(imagePath);
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  profilePicture[index],
                                  height: 65,
                                  width: 60,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    // Second row of 4 icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              imagePath = profilePicture[index + 4];
                            });

                            // Update the theme primary color based on profile picture
                            Provider.of<ThemeProvider>(context, listen: false)
                                .updatePrimaryColor(profilePicture[index + 4]);

                            Navigator.pop(context);
                            // update user's profile picture
                            await updateProfilePic(imagePath);
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  profilePicture[index + 4],
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon:
                Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: Icon(Icons.bug_report,
                color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DebugMenu()),
              );
            },
            tooltip: 'Debug Menu',
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
              );
            },
            tooltip: 'Logout',
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
                            SizedBox(height: 10),
                            // Name with animated effect
                            Text(
                              '${user.username[0].toUpperCase() + user.username.substring(1)}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.bebasNeue(
                                fontSize: 40,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color,
                                letterSpacing: 1.5,
                              ),
                            ),
                            // Email display
                          ],
                        ),
                      ),
                    ),
                    // Section Toggle Buttons
                    ToggleButtons(
                      isSelected: _isSelected,
                      onPressed: (int index) {
                        setState(() {
                          // Basic logic to ensure only one button is selected
                          for (int i = 0; i < _isSelected.length; i++) {
                            _isSelected[i] = i == index;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      selectedBorderColor:
                          Theme.of(context).colorScheme.primary,
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).colorScheme.primary,
                      color: Theme.of(context).colorScheme.primary,
                      constraints: BoxConstraints(
                        minHeight: 40.0,
                        minWidth: (MediaQuery.of(context).size.width - 60) /
                            3, // Adjust width based on screen
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_rounded, size: 16),
                              SizedBox(width: 4),
                              Text('Snackbox', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.insights, size: 16),
                              SizedBox(width: 4),
                              Text('Stats', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.public, size: 16),
                              SizedBox(width: 4),
                              Text('Global', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Conditionally display content based on selection
                    if (_isSelected[1]) ...[
                      // --- Your Stats Section ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Your Stats Breakdown',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                              'Total Machines Added',
                              getUserMachinesEntered(),
                              Theme.of(context).colorScheme.secondary,
                            ),
                            _buildStatCard(
                              context,
                              Icons.today, // Changed icon
                              'Points Received Today',
                              getUserCap(),
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Level Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  getCurrentLevel()['color'].withOpacity(0.05),
                                  getNextLevel()['color'].withOpacity(0.15),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: getCurrentLevel()['color']
                                            .withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        getCurrentLevel()['icon'],
                                        color: getCurrentLevel()['color'],
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'LEVEL',
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        Text(
                                          getCurrentLevel()['name']
                                              .toUpperCase(),
                                          style: GoogleFonts.bebasNeue(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: getCurrentLevel()['color'],
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Level progress
                                getCurrentLevel() == getNextLevel()
                                    ? Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: getCurrentLevel()['color']
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: getCurrentLevel()['color']
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.verified,
                                              color: getCurrentLevel()['color'],
                                              size: 24,
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'Max Level Achieved! You\'re a Vendi Master!',
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: getCurrentLevel()[
                                                      'color'],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '$currentPoints pts',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: getCurrentLevel()[
                                                      'color'],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${getNextLevel()['threshold']} pts',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      getNextLevel()['color'],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Stack(
                                            children: [
                                              // Background progress bar
                                              Container(
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 3,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Progress indicator
                                              FractionallySizedBox(
                                                widthFactor: getLevelProgress(),
                                                child: Container(
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        getCurrentLevel()[
                                                            'color'],
                                                        getNextLevel()['color'],
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                            getCurrentLevel()[
                                                                    'color']
                                                                .withOpacity(
                                                                    0.4),
                                                        blurRadius: 4,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: getNextLevel()['color']
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(getNextLevel()['icon'],
                                                    color:
                                                        getNextLevel()['color'],
                                                    size: 18),
                                                SizedBox(width: 6),
                                                Text(
                                                  '${getNextLevel()['threshold'] - currentPoints} more points to reach ${getNextLevel()['name']}',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        getNextLevel()['color'],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                    if (_isSelected[2]) ...[
                      // --- Global Impact Section ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Vendi Community Impact',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
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
                    if (_isSelected[0]) ...[
                      // --- SnackDex / Achievements Section ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Your Snackbox Collection',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Collection Stats Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Collection progress
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Collection Progress',
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '${snackCollectibles.where((snack) => snack['isUnlocked']).length}/${snackCollectibles.length}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Snacks',
                                          style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Rarity legend
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Common',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Rare',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.purple,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Epic',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // SnackDex Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: snackCollectibles.length,
                          itemBuilder: (context, index) {
                            final snack = snackCollectibles[index];
                            return GestureDetector(
                              onTap: () {
                                // Show snack details when tapped
                                if (snack['isUnlocked']) {
                                  _showSnackDetails(context, snack);
                                } else {
                                  _showLockedSnackDetails(context, snack);
                                }
                              },
                              onLongPress: () {
                                // Toggle unlock status for testing/development
                                setState(() {
                                  bool newState = !snack['isUnlocked'];

                                  if (newState) {
                                    // Use the consistent method for unlocking
                                    _manuallyUnlockAchievement(snack['id']);
                                  } else {
                                    // For locking, update the state and save
                                    snack['isUnlocked'] = false;
                                    _saveUnlockedAchievements();
                                  }
                                });

                                // Show feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      snack['isUnlocked']
                                          ? 'Manually unlocked: ${snack['name']}'
                                          : 'Manually locked: ${snack['name']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: snack['isUnlocked']
                                        ? snack['color']
                                        : Colors.grey,
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                    color: snack['isUnlocked']
                                        ? snack['color']
                                        : Theme.of(context).dividerColor,
                                    width: 2,
                                  ),
                                ),
                                elevation: snack['isUnlocked'] ? 4 : 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: snack['isUnlocked']
                                        ? snack['color'].withOpacity(0.1)
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerLowest,
                                  ),
                                  child: Stack(
                                    children: [
                                      // Rarity indicator
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: snack['isUnlocked']
                                                ? snack['color']
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            snack['rarity'],
                                            style: TextStyle(
                                              color: snack['isUnlocked']
                                                  ? Colors.white
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Snack content
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Snack image or placeholder
                                              Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: snack['isUnlocked']
                                                      ? Colors.transparent
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .surfaceContainerHigh,
                                                ),
                                                child: snack['isUnlocked']
                                                    ? Image.asset(
                                                        snack['imagePath'],
                                                        height: 50,
                                                        width: 50,
                                                        fit: BoxFit.contain,
                                                        filterQuality:
                                                            FilterQuality.none,
                                                        isAntiAlias: false,
                                                      )
                                                    : Icon(
                                                        Icons.lock,
                                                        size: 40,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant
                                                            .withOpacity(0.6),
                                                      ),
                                              ),
                                              SizedBox(height: 12),
                                              // Snack name
                                              Text(
                                                snack['isUnlocked']
                                                    ? snack['name']
                                                    : '???',
                                                style: GoogleFonts.roboto(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: snack['isUnlocked']
                                                      ? Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.color
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 4),
                                              // Achievement text
                                              Text(
                                                snack['isUnlocked']
                                                    ? 'Collected!'
                                                    : 'Locked',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: snack['isUnlocked']
                                                      ? snack['color']
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant
                                                          .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
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
                    Icon(icon,
                        // Conditional color based on title
                        color: title == 'Total Points'
                            ? Colors.amber
                            : title == 'Added Today'
                                ? Colors.blue
                                : iconColor, // Use passed color for others
                        size: 26),
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

  // Update the snack collectibles based on user's achievements
  void _updateSnackCollectibles() {
    // Create a local copy to work with
    List<Map<String, dynamic>> updatedSnacks = List.from(snackCollectibles);

    // Always load from Firebase first (regardless of points/machines)
    if (!isSnackCollectiblesInitialized) {
      getUserAchievements().then((unlockedIds) {
        if (unlockedIds.isNotEmpty) {
          // Update from Firebase saved achievements
          for (int i = 0; i < updatedSnacks.length; i++) {
            Map<String, dynamic> snack = Map.from(updatedSnacks[i]);
            if (unlockedIds.contains(snack['id'])) {
              snack['isUnlocked'] = true;
            }
            updatedSnacks[i] = snack;
          }
        }

        // Only check for new achievements based on requirements if we have valid data
        if (currentPoints > 0 || userMachinesCount > 0) {
          for (int i = 0; i < updatedSnacks.length; i++) {
            Map<String, dynamic> snack = Map.from(updatedSnacks[i]);
            // Check if user meets the requirements to unlock this snack
            if ((snack['pointsNeeded'] > 0 &&
                    currentPoints >= snack['pointsNeeded']) ||
                (snack['machinesNeeded'] > 0 &&
                    userMachinesCount >= snack['machinesNeeded']) ||
                (snack['pointsNeeded'] > 0 &&
                    snack['machinesNeeded'] > 0 &&
                    currentPoints >= snack['pointsNeeded'] &&
                    userMachinesCount >= snack['machinesNeeded'])) {
              snack['isUnlocked'] = true;
            }
            updatedSnacks[i] = snack;
          }
        }

        setState(() {
          // Replace the entire collection at once to minimize rebuilds
          for (int i = 0; i < snackCollectibles.length; i++) {
            snackCollectibles[i]['isUnlocked'] = updatedSnacks[i]['isUnlocked'];
          }

          // Save to Firebase if any achievements are unlocked
          _saveUnlockedAchievements();

          // Mark as initialized to prevent multiple updates
          isSnackCollectiblesInitialized = true;
        });
      });
    }
  }

  // Save unlocked achievements to Firebase
  void _saveUnlockedAchievements() {
    List<int> unlockedIds = [];
    for (var snack in snackCollectibles) {
      if (snack['isUnlocked']) {
        unlockedIds.add(snack['id']);
      }
    }
    saveUserAchievements(unlockedIds);
  }

  // Show details of an unlocked snack
  void _showSnackDetails(BuildContext context, Map<String, dynamic> snack) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 5),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: 30),

              // Snack content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Snack image
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.transparent,
                      ),
                      child: Image.asset(
                        snack['imagePath'],
                        height: 150,
                        width: 150,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        isAntiAlias: false,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Snack name and rarity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          snack['name'],
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: snack['color'],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            snack['rarity'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Achievement
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: snack['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: snack['color'].withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: snack['color'],
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Achievement Unlocked',
                                  style: TextStyle(
                                    color: snack['color'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  snack['achievement'],
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Description
                    Text(
                      snack['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),

                    // Date collected placeholder (would require storing this information)
                    Text(
                      'Collected today',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show details of a locked snack
  void _showLockedSnackDetails(
      BuildContext context, Map<String, dynamic> snack) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 5),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: 30),

              // Snack content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Snack image (locked)
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock,
                              size: 50,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.6),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Mystery text
                        Text(
                          '???',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'This snack is still locked!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: 30),

                        // How to unlock
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'How to unlock',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                snack['achievement'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Add manual unlock button for testing
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _manuallyUnlockAchievement(snack['id']);
                            Navigator.pop(context);
                            // Show a confirmation snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Achievement unlocked!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text('Manually Unlock (Debug)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // New method to manually unlock an achievement (for testing/debugging)
  void _manuallyUnlockAchievement(int achievementId) {
    // Find the achievement by ID
    int index =
        snackCollectibles.indexWhere((snack) => snack['id'] == achievementId);
    if (index != -1) {
      setState(() {
        snackCollectibles[index]['isUnlocked'] = true;
        // Save to Firebase
        _saveUnlockedAchievements();
      });
    }
  }
}
