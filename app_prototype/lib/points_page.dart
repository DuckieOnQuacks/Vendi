import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/user_helper.dart';

// All code on this page was developed by the team using the Flutter framework

class PointsPage extends StatefulWidget {
  const PointsPage({Key? key}) : super(key: key);

  @override
  _PointsPageState createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  int currentPoints = 0;

  // Sample leaderboard data
  List<Map<String, dynamic>> leaderboardData = [
    {'rank': 1, 'username': 'Alice', 'points': 1500},
    {'rank': 2, 'username': 'Bob', 'points': 1200},
    {'rank': 3, 'username': 'Charlie', 'points': 900},
    {'rank': 4, 'username': 'YourUsername', 'points': 800}, // Placeholder for current user
    {'rank': 5, 'username': 'Eve', 'points': 700},
  ];

  @override
  void initState() {
    super.initState();
    getUserPoints().then((points) {
      setState(() {
        currentPoints = points!;
        // Update the user's points in the sample leaderboard
        leaderboardData[3]['points'] = currentPoints;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the current theme is dark
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
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView( // Make the page scrollable
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Existing widgets
                Image.asset(
                  'assets/images/3MachinesStacked.png',
                  scale: 2,
                ),
                const SizedBox(height: 20),
                // Smaller display for current user's points
                FutureBuilder<String>(
                  future: getUserName(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        '${snapshot.data ?? ""}, you have $currentPoints Vendi Points',
                        style: GoogleFonts.bebasNeue(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Leaderboard section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Text(
                        'Leaderboard',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: leaderboardData.length,
                        itemBuilder: (context, index) {
                          final user = leaderboardData[index];
                          bool isCurrentUser = user['username'] == 'YourUsername'; // Replace with actual username check
                          return Card(
                            color: isCurrentUser
                                ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                                : Theme.of(context).cardColor,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                child: Text(
                                  user['rank'].toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                user['username'],
                                style: TextStyle(
                                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              trailing: Text(
                                '${user['points']} pts',
                                style: TextStyle(
                                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
