import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bottom_nav/backend/classes/user.dart';
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
        .limit(10)
        .get();

    // Convert to list and assign ranks
    List<Map<String, dynamic>> leaderboardData = [];
    int rank = 1;

    for (var doc in topUsersSnapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;

      leaderboardData.add({
        'id': doc.id,
        'rank': rank,
        'username':
            "${userData['username'][0].toUpperCase() + userData['username'].substring(1)}", // Capitalize username first letter
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color headerTextColor =
        isDarkMode ? Colors.white : Theme.of(context).colorScheme.secondary;
    final Color cardBackgroundColor = isDarkMode
        ? Theme.of(context).cardColor.withAlpha(150)
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final Color rankTextColor =
        isDarkMode ? Colors.white70 : Theme.of(context).colorScheme.primary;
    final Color podiumShadowColor = isDarkMode ? Colors.black : Colors.black38;

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
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 25),

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
                                  padding: const EdgeInsets.only(bottom: 30.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15),
                                        child: Text(
                                          "Top US Contributors",
                                          style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: headerTextColor,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          // 2nd place
                                          _buildPodiumItem(
                                            leaderboardData[1]['username'] ??
                                                'Unknown',
                                            leaderboardData[1]['points'] ?? 0,
                                            Icons.looks_two,
                                            Colors.grey,
                                            100.0,
                                            false,
                                            leaderboardData[1]
                                                    ['isCurrentUser'] ??
                                                false,
                                            isDarkMode,
                                            podiumShadowColor,
                                            2,
                                          ),

                                          // 1st place
                                          _buildPodiumItem(
                                            leaderboardData[0]['username'] ??
                                                'Unknown',
                                            leaderboardData[0]['points'] ?? 0,
                                            Icons.looks_one,
                                            Colors.amber,
                                            120.0,
                                            true,
                                            leaderboardData[0]
                                                    ['isCurrentUser'] ??
                                                false,
                                            isDarkMode,
                                            podiumShadowColor,
                                            1,
                                          ),

                                          // 3rd place
                                          _buildPodiumItem(
                                            leaderboardData[2]['username'] ??
                                                'Unknown',
                                            leaderboardData[2]['points'] ?? 0,
                                            Icons.looks_3,
                                            Colors.brown,
                                            80.0,
                                            false,
                                            leaderboardData[2]
                                                    ['isCurrentUser'] ??
                                                false,
                                            isDarkMode,
                                            podiumShadowColor,
                                            3,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                              // Leaderboard list container
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      cardBackgroundColor,
                                      cardBackgroundColor
                                          .withAlpha(isDarkMode ? 200 : 220),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: podiumShadowColor.withAlpha(13),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "US RANK",
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: rankTextColor,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          Text(
                                            "CONTRIBUTOR",
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: rankTextColor,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          Text(
                                            "POINTS",
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: rankTextColor,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                        height: 2,
                                        thickness: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withAlpha(isDarkMode ? 50 : 25)),
                                    const SizedBox(height: 10),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withAlpha(
                                                        isDarkMode ? 50 : 26)
                                                : isDarkMode
                                                    ? Theme.of(context)
                                                        .cardColor
                                                        .withAlpha(180)
                                                    : Theme.of(context)
                                                        .cardColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: isCurrentUser
                                                ? Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    width: 1.5,
                                                  )
                                                : null,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                    isDarkMode ? 20 : 8),
                                                spreadRadius: 0,
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                            leading: Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: isCurrentUser
                                                      ? [
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                        ]
                                                      : [
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary,
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary,
                                                        ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (isCurrentUser
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .secondary)
                                                        .withAlpha(77),
                                                    spreadRadius: 0,
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  user['rank'].toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
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
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  )
                                                : null,
                                            trailing: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: isCurrentUser
                                                      ? [
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                              .withAlpha(51),
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                              .withAlpha(77),
                                                        ]
                                                      : isDarkMode
                                                          ? [
                                                              Colors.grey
                                                                  .withAlpha(
                                                                      45),
                                                              Colors.grey
                                                                  .withAlpha(
                                                                      50),
                                                            ]
                                                          : [
                                                              Colors.grey
                                                                  .withAlpha(
                                                                      26),
                                                              Colors.grey
                                                                  .withAlpha(
                                                                      38),
                                                            ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: isCurrentUser
                                                    ? Border.all(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withAlpha(77),
                                                        width: 1,
                                                      )
                                                    : null,
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
                                                        : Colors.amber,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${user['points']}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isCurrentUser
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
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
    bool isDarkMode,
    Color shadowColor,
    int place,
  ) {
    // Determine the medal colors for all elements
    final Color medalBaseColor;
    final List<Color> medalGradient;
    final Color medalAccent;
    final Color medalTextColor;

    switch (place) {
      case 1: // Gold
        medalBaseColor = Colors.amber;
        medalGradient = [
          Colors.amber.shade300,
          Colors.amber.shade600,
        ];
        medalAccent = Colors.amber.shade700;
        medalTextColor =
            isDarkMode ? Colors.amber.shade200 : Colors.amber.shade800;
        break;
      case 2: // Silver
        medalBaseColor = Colors.grey.shade400;
        medalGradient = [
          Colors.grey.shade300,
          Colors.grey.shade500,
        ];
        medalAccent = Colors.grey.shade600;
        medalTextColor =
            isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
        break;
      case 3: // Bronze
        medalBaseColor = Colors.brown.shade300;
        medalGradient = [
          Colors.brown.shade200,
          Colors.brown.shade400,
        ];
        medalAccent = Colors.brown.shade500;
        medalTextColor =
            isDarkMode ? Colors.brown.shade200 : Colors.brown.shade700;
        break;
      default: // Fallback
        medalBaseColor = Colors.amber;
        medalGradient = [
          Colors.amber.shade300,
          Colors.amber.shade600,
        ];
        medalAccent = Colors.amber.shade700;
        medalTextColor =
            isDarkMode ? Colors.amber.shade200 : Colors.amber.shade800;
    }

    // If it's place 1 (gold), use gold colors even for current user
    // Otherwise use user colors for current user elements
    final bool forceGold = place == 1;
    final Color itemColor = (isCurrentUser && !forceGold)
        ? Theme.of(context).colorScheme.primary
        : medalAccent;

    final Color textColor = (isCurrentUser && !forceGold)
        ? Theme.of(context).colorScheme.primary
        : medalTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // User avatar/medal
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: (isCurrentUser && !forceGold)
                    ? [
                        Theme.of(context).colorScheme.primary.withAlpha(70),
                        Theme.of(context).colorScheme.primary
                      ]
                    : medalGradient,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: itemColor,
                width: isCurrentUser ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isCurrentUser && !forceGold)
                      ? Theme.of(context).colorScheme.primary.withAlpha(60)
                      : medalBaseColor.withAlpha(60),
                  spreadRadius: 1,
                  blurRadius: place == 1
                      ? 10
                      : place == 2
                          ? 9
                          : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              place == 1 ? Icons.emoji_events : icon,
              color: itemColor,
              size: place == 1
                  ? 40
                  : place == 2
                      ? 35
                      : 30,
            ),
          ),
          const SizedBox(height: 8),
          // Username
          Container(
            constraints: BoxConstraints(maxWidth: 90),
            child: Text(
              username,
              style: TextStyle(
                fontWeight: place == 1 ? FontWeight.bold : FontWeight.w600,
                fontSize: place == 1 ? 16 : 14,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // You indicator for current user - always show in primary color
          if (isCurrentUser)
            Container(
              margin: EdgeInsets.only(top: 2),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha(isDarkMode ? 50 : 26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'You',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          const SizedBox(height: 4),
          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: (isCurrentUser && !forceGold)
                    ? [
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(isDarkMode ? 70 : 51),
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(isDarkMode ? 100 : 77),
                      ]
                    : [
                        medalGradient[0].withAlpha(isDarkMode ? 100 : 70),
                        medalGradient[1].withAlpha(isDarkMode ? 150 : 100),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isCurrentUser && !forceGold)
                    ? Theme.of(context).colorScheme.primary.withAlpha(77)
                    : medalAccent.withAlpha(100),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDarkMode ? 30 : 8),
                  spreadRadius: 0,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 12,
                  color: itemColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '$points',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: textColor,
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: medalGradient, // Always use medal gradient for podium
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: medalAccent.withAlpha(isDarkMode ? 100 : 77),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: place == 1
                ? Center(
                    child: Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                : Center(
                    child: Text(
                      place.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
