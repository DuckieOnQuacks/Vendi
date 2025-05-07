import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:vendi_app/backend/message_helper.dart';
import 'machine.dart';
import 'dart:io' show Platform;

// Cache variables for frequently accessed data
DocumentSnapshot? _cachedUserDoc;
DateTime? _userDocCacheTime;
int? _cachedPoints;
DateTime? _pointsCacheTime;
int? _cachedCap;
DateTime? _capCacheTime;
String? _cachedProfilePic;
DateTime? _profilePicCacheTime;
bool? _cachedTestMachinesSetting;
DateTime? _testMachinesSettingCacheTime;
List<int>? _cachedAchievements;
DateTime? _achievementsCacheTime;

// Achievement criteria definitions for unlocking achievements
const List<Map<String, int>> _achievementCriteria = [
  {'id': 1, 'pointsNeeded': 0, 'machinesNeeded': 1},
  {'id': 2, 'pointsNeeded': 50, 'machinesNeeded': 0},
  {'id': 3, 'pointsNeeded': 0, 'machinesNeeded': 3},
  {'id': 4, 'pointsNeeded': 150, 'machinesNeeded': 0},
  {'id': 5, 'pointsNeeded': 30, 'machinesNeeded': 0},
  {'id': 6, 'pointsNeeded': 0, 'machinesNeeded': 5},
  {'id': 7, 'pointsNeeded': 300, 'machinesNeeded': 0},
  {'id': 8, 'pointsNeeded': 75, 'machinesNeeded': 1},
  {'id': 9, 'pointsNeeded': 450, 'machinesNeeded': 0},
  {'id': 10, 'pointsNeeded': 0, 'machinesNeeded': 10},
  {'id': 11, 'pointsNeeded': 600, 'machinesNeeded': 0},
  {'id': 12, 'pointsNeeded': 800, 'machinesNeeded': 0},
  {'id': 13, 'pointsNeeded': 0, 'machinesNeeded': 15},
  {'id': 14, 'pointsNeeded': 70, 'machinesNeeded': 0},
  {'id': 15, 'pointsNeeded': 1000, 'machinesNeeded': 0},
  {'id': 16, 'pointsNeeded': 0, 'machinesNeeded': 20},
  {'id': 17, 'pointsNeeded': 1500, 'machinesNeeded': 0},
  {'id': 18, 'pointsNeeded': 0, 'machinesNeeded': 25},
  {'id': 19, 'pointsNeeded': 2000, 'machinesNeeded': 25},
];

// Track user login streaks and total login days
Future<void> recordUserLogin() async {
  final userDocRef = getUserDocRef();
  final docSnapshot = await userDocRef.get();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime? lastDate;
  if (data['lastLoginDate'] != null) {
    final ts = data['lastLoginDate'] as Timestamp;
    final ld = ts.toDate();
    lastDate = DateTime(ld.year, ld.month, ld.day);
  }
  int streak = data['loginStreak'] ?? 0;
  int totalDays = data['totalLoginDays'] ?? 0;
  if (lastDate != today) {
    if (lastDate != null && lastDate == today.subtract(Duration(days: 1))) {
      streak += 1;
    } else {
      streak = 1;
    }
    totalDays += 1;
    await userDocRef.update({
      'lastLoginDate': Timestamp.fromDate(today),
      'loginStreak': streak,
      'totalLoginDays': totalDays,
    });
    clearUserCache();
  }
  // Evaluate achievements after login update
  await _evaluateAndSaveAchievements();
}

// Helper to evaluate and save achievements based on user points and machines entered
Future<void> _evaluateAndSaveAchievements() async {
  final userDocRef = getUserDocRef();
  final docSnapshot = await userDocRef.get();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  int points = data['points'] ?? 0;
  List<dynamic> machinesEntered = data['machinesEntered'] ?? [];
  int machineCount = machinesEntered.length;
  List<int> unlocked = List<int>.from(data['unlockedAchievements'] ?? []);
  bool hasChanges = false;
  for (var def in _achievementCriteria) {
    int id = def['id']!;
    int pn = def['pointsNeeded']!;
    int mn = def['machinesNeeded']!;
    bool meets;
    if (id == 5) {
      meets = (data['loginStreak'] ?? 0) >= 3;
    } else if (id == 14) {
      meets = (data['totalLoginDays'] ?? 0) >= 7;
    } else {
      meets = (pn > 0 && mn > 0 && points >= pn && machineCount >= mn) ||
          (pn > 0 && mn == 0 && points >= pn) ||
          (mn > 0 && pn == 0 && machineCount >= mn);
    }
    if (meets && !unlocked.contains(id)) {
      unlocked.add(id);
      hasChanges = true;
    }
  }
  if (hasChanges) {
    await userDocRef.update({'unlockedAchievements': unlocked}).then((_) {
      _cachedAchievements = unlocked;
      _achievementsCacheTime = DateTime.now();
    });
    print('Achievements evaluated and saved: $unlocked');
  }
}

// Function to get user document reference directly
DocumentReference getUserDocRef() {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance.collection('Users').doc(userId);
}

// Cached user document function
Future<DocumentSnapshot> getUserDocument() async {
  // Return cached document if recent (within last 2 minutes)
  if (_cachedUserDoc != null &&
      _userDocCacheTime != null &&
      DateTime.now().difference(_userDocCacheTime!).inMinutes < 2) {
    return _cachedUserDoc!;
  }

  final docRef = getUserDocRef();
  final docSnapshot = await docRef.get();

  // Update cache
  _cachedUserDoc = docSnapshot;
  _userDocCacheTime = DateTime.now();

  return docSnapshot;
}

// Clear cache when data changes
void clearUserCache() {
  _cachedUserDoc = null;
  _userDocCacheTime = null;
  _cachedPoints = null;
  _pointsCacheTime = null;
  _cachedCap = null;
  _capCacheTime = null;
  _cachedProfilePic = null;
  _profilePicCacheTime = null;
  _cachedTestMachinesSetting = null;
  _testMachinesSettingCacheTime = null;
  _cachedAchievements = null;
  _achievementsCacheTime = null;
}

class userInfo {
  // Variables to store user data
  final String username;
  final String email;
  final int points;
  final int cap;
  final List<String> machinesEntered;
  final DateTime? timeAfter24Hours;
  final List<String>? machinesFavorited;
  final List<String>? machinesRated;
  final String? profilePicture;
  final bool? darkMode;
  final String? primaryColor;
  final List<String>? achievements;
  // New tracking fields
  final int cardChanges;
  final int statusChanges;
  final int cardSelections;
  final Map<String, int> machineInteractions;
  final Map<String, DateTime> lastMachineInteractionTime;

  // Constructor for the userInfo class
  userInfo({
    required this.username,
    required this.email,
    required this.points,
    required this.cap,
    required this.machinesEntered,
    required this.profilePicture,
    this.achievements,
    this.timeAfter24Hours,
    this.machinesFavorited,
    this.machinesRated,
    this.darkMode,
    this.primaryColor,
    this.cardChanges = 0,
    this.statusChanges = 0,
    this.cardSelections = 0,
    this.machineInteractions = const {},
    this.lastMachineInteractionTime = const {},
  });

  // Factory method to create a userInfo object from JSON data
  factory userInfo.fromJson(Map<String, dynamic> json) => userInfo(
        username: json['username'],
        email: json['email'],
        points: json['points'],
        cap: json['cap'],
        machinesEntered: List<String>.from(json['machinesEntered']),
        profilePicture: json['profilePicture'],
        timeAfter24Hours: (json['timeAfter24Hours'] as Timestamp?)?.toDate(),
        achievements: List<String>.from(json['achievements'] ?? []),
        machinesFavorited: List<String>.from(json['favoriteMachines'] ?? []),
        machinesRated: json['machinesRated'] != null
            ? List<String>.from(json['machinesRated'])
            : [],
        darkMode: json['darkMode'],
        primaryColor: json['primaryColor'],
        cardChanges: json['cardChanges'] ?? 0,
        statusChanges: json['statusChanges'] ?? 0,
        cardSelections: json['cardSelections'] ?? 0,
        machineInteractions:
            Map<String, int>.from(json['machineInteractions'] ?? {}),
        lastMachineInteractionTime:
            (json['lastMachineInteractionTime'] as Map<String, dynamic>?)?.map(
                  (key, value) => MapEntry(key, (value as Timestamp).toDate()),
                ) ??
                {},
      );

  // Method to convert a userInfo object to JSON data
  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'points': points,
        'cap': cap,
        'machinesEntered': machinesEntered,
        'profilePicture': profilePicture,
        'achievements': achievements,
        'timeAfter24Hours': timeAfter24Hours,
        'machinesFavorited': machinesFavorited,
        'machinesRated': machinesRated,
        'darkMode': darkMode,
        'primaryColor': primaryColor,
        'cardChanges': cardChanges,
        'statusChanges': statusChanges,
        'cardSelections': cardSelections,
        'machineInteractions': machineInteractions,
        'lastMachineInteractionTime': lastMachineInteractionTime.map(
          (key, value) => MapEntry(key, Timestamp.fromDate(value)),
        ),
      };
}

//Helper to retrieve the current users points.
//Uses cached value if available
Future<int?> getUserPoints() async {
  // Return cached value if recent (within last 5 minutes)
  if (_cachedPoints != null &&
      _pointsCacheTime != null &&
      DateTime.now().difference(_pointsCacheTime!).inMinutes < 5) {
    return _cachedPoints!;
  }

  final docSnapshot = await getUserDocument();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  _cachedPoints = data['points'] ?? 0;
  _pointsCacheTime = DateTime.now();
  return _cachedPoints;
}

//Helper to get the current value of cap in the users firestore storage.
Future<int> getUserMachinesEntered() async {
  final docSnapshot = await getUserDocument();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  List<dynamic> machinesEntered = data['machinesEntered'] ?? [];
  return machinesEntered.length;
}

//This function get the ids found in the users machinesFavorited field and returns the corrspnding machines that can
//be found in the firestore database.
Future<List<Machine>> getMachinesFavorited() async {
  final docSnapshot = await getUserDocument();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  List<String>? machineIds = List<String>.from(data['machinesFavorited'] ?? []);

  if (machineIds.isEmpty) {
    return [];
  }

  final machineDocs = await FirebaseFirestore.instance
      .collection('Machines')
      .where(FieldPath.documentId, whereIn: machineIds)
      .get();

  final machines =
      machineDocs.docs.map((doc) => Machine.fromJson(doc.data())).toList();

  return machines;
}

//Used to get the users email so that we can search for there data in the firestore database.
Future<userInfo?> getUserByEmail(String email) async {
  try {
    final db = FirebaseFirestore.instance;
    final query = db.collection('Users').where('email', isEqualTo: email);
    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.single.data();
      final username = userData['username'] as String?;
      final points = userData['points'] as int?;
      final cap = userData['cap'] as int?;
      final machinesEntered = List<String>.from(userData['machinesEntered']);
      final profilePicture = userData['profilePicture'] as String?;

      if (username != null &&
          points != null &&
          cap != null &&
          profilePicture != null &&
          machinesEntered != []) {
        return userInfo(
          username: username,
          email: email,
          points: points,
          cap: cap,
          machinesEntered: machinesEntered,
          profilePicture: profilePicture,
        );
      }
    }
    print('No user found with email $email');
    return null;
  } catch (e) {
    print('Error getting user by email: $e');
    return null;
  }
}

//Helper to get the current value of cap in the users firestore storage.
Future<int?> getUserCap() async {
  // Return cached value if recent (within last 5 minutes)
  if (_cachedCap != null &&
      _capCacheTime != null &&
      DateTime.now().difference(_capCacheTime!).inMinutes < 5) {
    return _cachedCap!;
  }

  final docSnapshot = await getUserDocument();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  _cachedCap = data['cap'];
  _capCacheTime = DateTime.now();
  return _cachedCap;
}

//Gets the users profile pic path and uses it for profile related things
Future<String?> getProfilePic() async {
  // Return cached value if recent (within last 10 minutes)
  if (_cachedProfilePic != null &&
      _profilePicCacheTime != null &&
      DateTime.now().difference(_profilePicCacheTime!).inMinutes < 10) {
    return _cachedProfilePic!;
  }

  final docSnapshot = await getUserDocument();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  _cachedProfilePic = data['profilePicture'];
  _profilePicCacheTime = DateTime.now();
  return _cachedProfilePic;
}

//Similar to the one above this is a helper function to get the timeAfter24Hours variable
Future<DateTime?> getTimeAfter24Hours() async {
  final docSnapshot = await getUserDocument();

  if (docSnapshot.exists) {
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    Timestamp timestamp = data['timeAfter24Hours'];
    return timestamp.toDate();
  }

  return null;
}

//This helper function updates the cap value when the user updates or adds a machine.
Future<void> setUserCap(int capToAdd) async {
  final userDocRef = getUserDocRef();
  final docSnapshot = await userDocRef.get();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  int currentCap = data['cap'] ?? 0;
  int newCap = currentCap + capToAdd;
  await userDocRef.update({'cap': newCap});

  // Clear cache after update
  _cachedCap = newCap;
  _capCacheTime = DateTime.now();
  clearUserCache();

  print('Cap updated');
}

Future<void> setMachineToFavorited(
    String machineId, BuildContext context) async {
  final userDocRef = getUserDocRef();
  final docSnapshot = await userDocRef.get();

  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  final machinesFavorited = List<String>.from(data['machinesFavorited'] ?? []);
  if (machinesFavorited.length < 10) {
    if (!machinesFavorited.contains(machineId)) {
      machinesFavorited.add(machineId);
      await userDocRef.update({
        'machinesFavorited': machinesFavorited,
      }).then((_) {
        clearUserCache();
        print('Machine added to favorites successfully!');
      }).catchError((error) {
        print('Error adding machine to favorites: $error');
      });
    } else {
      print('Machine is already in favorites');
    }
  } else {
    showWarning(context, 'You can only favorite up to 10 machines.');
  }
}

// This function is used to store the wait time between uploading 3 machines a day
// Here we are taking in the 3rd images metadata data and adding 24 hours to it to get the time the user can upload again.
Future<void> setTimeAfter24Hours(DateTime timeAfter24Hours) async {
  final userDocRef = getUserDocRef();

  // Convert the DateTime to a Timestamp
  Timestamp timeAfter24HoursTimestamp = Timestamp.fromDate(timeAfter24Hours);

  // Update the timeAfter24Hours field for the current user
  await userDocRef
      .update({'timeAfter24Hours': timeAfter24HoursTimestamp}).then((_) {
    clearUserCache();
  }).catchError((error) => print('Failed to update user: $error'));
}

Future<bool> isMachineFavorited(Machine machine) async {
  final docSnapshot = await getUserDocument();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  List<String> machineIds = List<String>.from(data['machinesFavorited'] ?? []);

  return machineIds.contains(machine.id);
}

Future<void> removeMachineFromFavorited(String machineId) async {
  final userDocRef = getUserDocRef();

  try {
    final docSnapshot = await userDocRef.get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    final machinesFavorited =
        List<String>.from(data['machinesFavorited'] ?? []);

    if (machinesFavorited.contains(machineId)) {
      machinesFavorited.remove(machineId);
      await userDocRef
          .update({'machinesFavorited': machinesFavorited}).then((_) {
        clearUserCache();
      });
      print('Machine removed from favorites successfully!');
    } else {
      print('Machine is not in favorites');
    }
  } catch (error) {
    print('Error removing machine from favorites: $error');
  }
}

//This helps add the machine name to the machine array that is stored with the user.
Future<void> addMachineToUser(String? machineName) async {
  final userDocRef = getUserDocRef();
  final docSnapshot = await userDocRef.get();

  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  final machinesEntered = List<String>.from(data['machinesEntered']);
  machinesEntered.add(machineName!);

  await userDocRef.update({
    'machinesEntered': machinesEntered,
  }).then((_) {
    clearUserCache();
    print('Machine added successfully!');
  }).catchError((error) {
    print('Error adding machine: $error');
  });
  // Evaluate achievements after adding a machine
  await _evaluateAndSaveAchievements();
}

//Helper to update the current users point value in firestore.
Future<void> setUserPoints(int pointsToAdd) async {
  final userDocRef = getUserDocRef();
  final docSnapshot = await userDocRef.get();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

  int currentPoints = data['points'] ?? 0;
  int newPoints = currentPoints + pointsToAdd;

  await userDocRef.update({'points': newPoints}).then((_) {
    // Update cache
    _cachedPoints = newPoints;
    _pointsCacheTime = DateTime.now();
    clearUserCache();
  });

  print('Points updated');
  // Evaluate achievements after points update
  await _evaluateAndSaveAchievements();
}

Future<void> updateProfilePic(String? imagePath) async {
  final userDocRef = getUserDocRef();

  await userDocRef.update({
    'profilePicture': imagePath,
  }).then((_) {
    // Update cache
    _cachedProfilePic = imagePath;
    _profilePicCacheTime = DateTime.now();
    clearUserCache();
    print('Profile picture updated successfully!');
  }).catchError((error) {
    print('Error updating profile picture: $error');
  });
}

Future<void> updateDarkModeSetting(bool isDarkMode) async {
  final userDocRef = getUserDocRef();

  await userDocRef.update({
    'darkMode': isDarkMode,
  }).then((_) {
    clearUserCache();
    print('Dark mode setting updated successfully!');
  }).catchError((error) {
    print('Error updating dark mode setting: $error');
  });
}

// Helper to check if a user has already reported a machine recently
// This prevents spam reporting by limiting reports to 1 per day per machine
Future<bool> canUserReportMachine(String machineId) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final reportsCollectionRef = FirebaseFirestore.instance.collection('Reports');

  // Get current timestamp
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  // Check for recent reports by this user for this machine
  final querySnapshot = await reportsCollectionRef
      .where('userId', isEqualTo: userId)
      .where('machineId', isEqualTo: machineId)
      .where('timestamp', isGreaterThan: Timestamp.fromDate(yesterday))
      .get();

  // If no recent reports found, user can report
  return querySnapshot.docs.isEmpty;
}

// Helper to record a user's report in a separate collection
Future<void> recordUserReport(String machineId, String reportText) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final reportsCollectionRef = FirebaseFirestore.instance.collection('Reports');

  // Use a batch write to perform multiple operations in a single transaction
  final batch = FirebaseFirestore.instance.batch();

  // Create a new report document reference
  final reportRef = reportsCollectionRef.doc();

  // Get the user document reference
  final userDocRef = getUserDocRef();
  final userDoc = await userDocRef.get();
  Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
  int currentPoints = userData['points'] ?? 0;

  // Set the report data
  batch.set(reportRef, {
    'userId': userId,
    'machineId': machineId,
    'reportText': reportText,
    'timestamp': Timestamp.now(),
    'status': 'pending' // Status can be: pending, verified, rejected
  });

  // Update the user's points in the same transaction
  batch.update(userDocRef, {'points': currentPoints + 10});

  // Commit the batch
  await batch.commit().then((_) {
    // Update cache
    _cachedPoints = currentPoints + 10;
    _pointsCacheTime = DateTime.now();
    clearUserCache();
    print('User report recorded and points awarded');
  });
}

Future<void> updateTestMachinesSetting(bool useTestMachines) async {
  final userDocRef = getUserDocRef();

  await userDocRef.update({
    'useTestMachines': useTestMachines,
  }).then((_) {
    _cachedTestMachinesSetting = useTestMachines;
    _testMachinesSettingCacheTime = DateTime.now();
    clearUserCache();
    print('Test machines setting updated successfully!');
  }).catchError((error) {
    print('Error updating test machines setting: $error');
  });
}

Future<bool> getTestMachinesSetting() async {
  // Return cached value if recent (within last 5 minutes)
  if (_cachedTestMachinesSetting != null &&
      _testMachinesSettingCacheTime != null &&
      DateTime.now().difference(_testMachinesSettingCacheTime!).inMinutes < 5) {
    return _cachedTestMachinesSetting!;
  }

  final docSnapshot = await getUserDocument();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
  _cachedTestMachinesSetting = data['useTestMachines'] ?? false;
  _testMachinesSettingCacheTime = DateTime.now();
  return _cachedTestMachinesSetting!;
}

// Add this function to save beta tester notes
Future<void> saveBetaNote(String noteType, String noteDetails) async {
  try {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Create a unique ID for the note
    final String noteId = DateTime.now().millisecondsSinceEpoch.toString();

    // Create document data
    Map<String, dynamic> data = {
      'userId': user.uid,
      'email': user.email ?? 'Unknown',
      'type': noteType,
      'details': noteDetails,
      'timestamp': FieldValue.serverTimestamp(),
      'device': Platform.isIOS ? 'iOS' : 'Android',
      'appVersion':
          'Beta', // You can replace with actual app version if available
    };

    // Save to BetaNotes collection
    await FirebaseFirestore.instance
        .collection('BetaNotes')
        .doc(noteId)
        .set(data);

    print('Beta note saved successfully');
  } catch (e) {
    print('Error saving beta note: $e');
  }
}

// Function to get user's unlocked achievements
Future<List<int>> getUserAchievements() async {
  try {
    // Return cached achievements if recent (within last 5 minutes)
    if (_cachedAchievements != null &&
        _achievementsCacheTime != null &&
        DateTime.now().difference(_achievementsCacheTime!).inMinutes < 5) {
      return _cachedAchievements!;
    }

    final docSnapshot = await getUserDocument();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

    // If achievements field exists, return it
    if (data.containsKey('unlockedAchievements') &&
        data['unlockedAchievements'] != null) {
      List<int> achievements = List<int>.from(data['unlockedAchievements']);

      // Update cache
      _cachedAchievements = achievements;
      _achievementsCacheTime = DateTime.now();

      return achievements;
    }

    // If not, initialize with an empty list
    _cachedAchievements = [];
    _achievementsCacheTime = DateTime.now();
    return [];
  } catch (e) {
    print('Error getting user achievements: $e');
    return [];
  }
}

// Function to save unlocked achievements
Future<void> saveUserAchievements(List<int> achievementIds) async {
  try {
    final userDocRef = getUserDocRef();

    // Update cache immediately to ensure consistency
    _cachedAchievements = List<int>.from(achievementIds);
    _achievementsCacheTime = DateTime.now();

    await userDocRef.update({
      'unlockedAchievements': achievementIds,
    }).then((_) {
      print('Achievements updated successfully!');
    }).catchError((error) {
      print('Error updating achievements: $error');
    });
  } catch (e) {
    print('Error saving user achievements: $e');
  }
}

// Function to delete the current user's account
Future<Map<String, dynamic>> deleteUserAccount() async {
  try {
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return {
        'success': false,
        'requiresReauth': false,
        'message': 'No user logged in'
      };

    // Get user document reference
    final userDocRef = getUserDocRef();

    try {
      // Delete the user document from Firestore first
      await userDocRef.delete();

      // Delete the user authentication account
      await user.delete();

      // Clear any cached data
      clearUserCache();

      return {
        'success': true,
        'requiresReauth': false,
        'message': 'Account deleted successfully'
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // This error means the user needs to re-authenticate before we can delete the account
        return {
          'success': false,
          'requiresReauth': true,
          'message': 'Please log in again to confirm account deletion'
        };
      } else {
        return {
          'success': false,
          'requiresReauth': false,
          'message': 'Error: ${e.message}'
        };
      }
    }
  } catch (e) {
    print('Error deleting user account: $e');
    return {
      'success': false,
      'requiresReauth': false,
      'message': 'Error: ${e.toString()}'
    };
  }
}

// Function to re-authenticate a user with email and password
Future<bool> reauthenticateUser(String password) async {
  try {
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return false;

    // Create credential
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    // Re-authenticate
    await user.reauthenticateWithCredential(credential);
    return true;
  } catch (e) {
    print('Error re-authenticating: $e');
    return false;
  }
}

// Add new functions for tracking user interactions
Future<void> incrementCardChanges() async {
  final userDocRef = getUserDocRef();
  await userDocRef.update({
    'cardChanges': FieldValue.increment(1),
  });
  clearUserCache();
}

Future<void> incrementStatusChanges() async {
  final userDocRef = getUserDocRef();
  await userDocRef.update({
    'statusChanges': FieldValue.increment(1),
  });
  clearUserCache();
}

Future<void> incrementCardSelections() async {
  final userDocRef = getUserDocRef();
  await userDocRef.update({
    'cardSelections': FieldValue.increment(1),
  });
  clearUserCache();
}

Future<void> recordMachineInteraction(String machineId) async {
  final userDocRef = getUserDocRef();
  final docSnapshot = await userDocRef.get();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

  Map<String, int> interactions =
      Map<String, int>.from(data['machineInteractions'] ?? {});
  interactions[machineId] = (interactions[machineId] ?? 0) + 1;

  // Update the last interaction time
  Map<String, dynamic> lastInteractionTime =
      Map<String, dynamic>.from(data['lastMachineInteractionTime'] ?? {});
  lastInteractionTime[machineId] = Timestamp.now();

  await userDocRef.update({
    'machineInteractions': interactions,
    'lastMachineInteractionTime': lastInteractionTime,
  });
  clearUserCache();
}

// Add function to get interaction counts
Future<Map<String, dynamic>> getUserInteractionCounts() async {
  final docSnapshot = await getUserDocument();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

  return {
    'cardChanges': data['cardChanges'] ?? 0,
    'statusChanges': data['statusChanges'] ?? 0,
    'cardSelections': data['cardSelections'] ?? 0,
    'machineInteractions':
        Map<String, int>.from(data['machineInteractions'] ?? {}),
  };
}

// Add function to check if user can interact with a machine
Future<bool> canUserInteractWithMachine(String machineId) async {
  final docSnapshot = await getUserDocument();
  Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

  // Get the last interaction time for this machine
  final lastInteractionTime = data['lastMachineInteractionTime']?[machineId];
  if (lastInteractionTime == null) {
    return true; // No previous interaction, allow interaction
  }

  // Convert Timestamp to DateTime
  final lastInteraction = (lastInteractionTime as Timestamp).toDate();
  final now = DateTime.now();

  // Check if 24 hours have passed since last interaction
  return now.difference(lastInteraction).inHours >= 24;
}
