import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/user_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// All code on this page was developed by the team using the Flutter framework

class PointsPage extends StatefulWidget {
  const PointsPage({Key? key}) : super(key: key);

  @override
  _PointsPageState createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  int currentPoints = 0;
  String currentUserId = '';

  // Define level thresholds
  final List<Map<String, dynamic>> levels = [
    {'name': 'Beginner', 'threshold': 0, 'color': Colors.grey},
    {'name': 'Bronze', 'threshold': 500, 'color': Colors.brown},
    {'name': 'Silver', 'threshold': 1000, 'color': Colors.grey.shade400},
    {'name': 'Gold', 'threshold': 2000, 'color': Colors.amber},
    {'name': 'Platinum', 'threshold': 3500, 'color': Colors.blueGrey},
    {'name': 'Diamond', 'threshold': 5000, 'color': Colors.lightBlue.shade200},
    {'name': 'Master', 'threshold': 10000, 'color': Colors.purple},
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

  // Fetch leaderboard data
  Future<List<Map<String, dynamic>>> fetchLeaderboardData() async {
    // Get top 5 users by points
    final QuerySnapshot topUsersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .orderBy('points', descending: true)
        .limit(5)
        .get();

    // Convert to list and assign ranks
    List<Map<String, dynamic>> leaderboardData = [];
    int rank = 1;

    for (var doc in topUsersSnapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;
      String lastName = userData['last name'] ?? '';
      String lastInitial = lastName.isNotEmpty ? lastName[0] : '';

      leaderboardData.add({
        'id': doc.id,
        'rank': rank,
        'username': "${userData['first name']} $lastInitial.",
        'points': userData['points'] ?? 0,
      });
      rank++;
    }

    // Check if current user is in the list
    bool currentUserInList =
        leaderboardData.any((user) => user['id'] == currentUserId);

    // If not in list and we have a valid user ID, add them
    if (!currentUserInList && currentUserId.isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Get user's rank by counting users with more points
        final userPoints = userData['points'] ?? 0;
        final QuerySnapshot higherPointsQuery = await FirebaseFirestore.instance
            .collection('Users')
            .orderBy('points', descending: true)
            .get();

        // Count users with higher points to determine rank
        int userRank = 1;
        for (var doc in higherPointsQuery.docs) {
          if ((doc.data() as Map<String, dynamic>)['points'] > userPoints) {
            userRank++;
          }
        }

        String lastName = userData['last name'] ?? '';
        String lastInitial = lastName.isNotEmpty ? lastName[0] : '';

        leaderboardData.add({
          'id': currentUserId,
          'rank': userRank,
          'username': "${userData['first name']} $lastInitial.",
          'points': userData['points'] ?? 0,
          'isCurrentUser': true
        });
      }
    } else {
      // Mark current user in the list
      for (var user in leaderboardData) {
        if (user['id'] == currentUserId) {
          user['isCurrentUser'] = true;
        }
      }
    }

    leaderboardData.sort((a, b) => a['rank'].compareTo(b['rank']));

    return leaderboardData;
  }

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    getUserPoints().then((points) {
      setState(() {
        currentPoints = points!;
      });
    });
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
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

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
                      const SizedBox(height: 16),

                      // Leaderboard with podium and list
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchLeaderboardData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                'No leaderboard data available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          final leaderboardData = snapshot.data!;

                          return Column(
                            children: [
                              // Build podium for top 3 if we have at least 3 users
                              if (leaderboardData.length >= 3)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // 2nd place
                                      _buildPodiumItem(
                                        leaderboardData[1]['username'],
                                        leaderboardData[1]['points'],
                                        Icons.looks_two,
                                        Colors.grey.shade400,
                                        100.0,
                                        false,
                                        leaderboardData[1]['isCurrentUser'] ==
                                            true,
                                      ),

                                      // 1st place
                                      _buildPodiumItem(
                                        leaderboardData[0]['username'],
                                        leaderboardData[0]['points'],
                                        Icons.looks_one,
                                        Colors.amber,
                                        120.0,
                                        true,
                                        leaderboardData[0]['isCurrentUser'] ==
                                            true,
                                      ),

                                      // 3rd place
                                      _buildPodiumItem(
                                        leaderboardData[2]['username'],
                                        leaderboardData[2]['points'],
                                        Icons.looks_3,
                                        Colors.brown,
                                        80.0,
                                        false,
                                        leaderboardData[2]['isCurrentUser'] ==
                                            true,
                                      ),
                                    ],
                                  ),
                                ),

                              // Leaderboard list container
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.05),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: leaderboardData.length,
                                  itemBuilder: (context, index) {
                                    final user = leaderboardData[index];

                                    // Skip the top 3 in the list view if showing podium
                                    if (index < 3 &&
                                        leaderboardData.length >= 3) {
                                      return const SizedBox.shrink();
                                    }

                                    final bool isCurrentUser =
                                        user['isCurrentUser'] == true;

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isCurrentUser
                                            ? Color.fromRGBO(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .red,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .green,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .blue,
                                                0.1)
                                            : Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isCurrentUser
                                            ? Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 1.5,
                                              )
                                            : null,
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                        leading: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: isCurrentUser
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              user['rank'].toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          user['username'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isCurrentUser
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                          ),
                                        ),
                                        subtitle: isCurrentUser
                                            ? Text(
                                                'You',
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              )
                                            : null,
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isCurrentUser
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color: isCurrentUser
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${user['points']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isCurrentUser
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Colors.grey[800],
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
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Level Status Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.military_tech,
                                color: getCurrentLevel()['color'],
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Level: ${getCurrentLevel()['name']}',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: getCurrentLevel()['color'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Points info
                          FutureBuilder<String>(
                            future: getUserName(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                  '${snapshot.data ?? ""}, you have $currentPoints Vendi Points',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Level progress
                          getCurrentLevel() == getNextLevel()
                              ? Text(
                                  'Congratulations! You\'ve reached the highest level!',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : Column(
                                  children: [
                                    Text(
                                      '${getNextLevel()['threshold'] - currentPoints} more points needed for ${getNextLevel()['name']} level',
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Stack(
                                      children: [
                                        // Background progress bar
                                        Container(
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        // Progress indicator
                                        FractionallySizedBox(
                                          widthFactor: getLevelProgress(),
                                          child: Container(
                                            height: 10,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  getCurrentLevel()['color'],
                                                  getNextLevel()['color'],
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Level labels
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getCurrentLevel()['name'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: getCurrentLevel()['color'],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          getNextLevel()['name'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: getNextLevel()['color'],
                                            fontWeight: FontWeight.bold,
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to build podium items
  Widget _buildPodiumItem(
    String username,
    int points,
    IconData icon,
    Color color,
    double height,
    bool isFirst,
    bool isCurrentUser,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // User avatar/medal
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrentUser
                    ? Theme.of(context).colorScheme.primary
                    : color,
                width: isCurrentUser ? 3 : 2,
              ),
              boxShadow: isFirst
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color:
                  isCurrentUser ? Theme.of(context).colorScheme.primary : color,
              size: isFirst ? 36 : 28,
            ),
          ),
          const SizedBox(height: 8),
          // Username
          Text(
            username,
            style: TextStyle(
              fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
              fontSize: isFirst ? 16 : 14,
              color:
                  isCurrentUser ? Theme.of(context).colorScheme.primary : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          // You indicator for current user
          if (isCurrentUser)
            Text(
              'You',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          const SizedBox(height: 4),
          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: isCurrentUser
                  ? Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 12,
                  color: isCurrentUser
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
                const SizedBox(width: 2),
                Text(
                  '$points',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isCurrentUser
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Podium
          Container(
            width: 80,
            height: height,
            decoration: BoxDecoration(
              color:
                  isCurrentUser ? Theme.of(context).colorScheme.primary : color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isCurrentUser
                          ? Theme.of(context).colorScheme.primary
                          : color)
                      .withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
