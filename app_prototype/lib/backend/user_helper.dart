import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class userInfo {
  // Variables to store user data
  final String firstname;
  final String lastname;
  final String email;
  final int points;
  final int cap;
  final List<String> machinesEntered;
  final DateTime? timeAfter24Hours; // New property for timeAfter24Hours

  // Constructor for the userInfo class
  userInfo({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.points,
    required this.cap,
    required this.machinesEntered,
    this.timeAfter24Hours, // Add new property to constructor
  });

  // Factory method to create a userInfo object from JSON data
  factory userInfo.fromJson(Map<String, dynamic> json) => userInfo(
        firstname: json['firstname'],
        lastname: json['lastname'],
        email: json['email'],
        points: json['points'],
        cap: json['cap'],
        machinesEntered: List<String>.from(json['machinesEntered']),
        timeAfter24Hours: (json['timeAfter24Hours'] as Timestamp)
            .toDate(), // Convert Timestamp to DateTime
      );

  // Method to convert a userInfo object to JSON data
  Map<String, dynamic> toJson() => {
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'points': points,
        'cap': cap,
        'machinesEntered': machinesEntered,
        'timeAfter24Hours': timeAfter24Hours,
      };
}

//Helper to update the current users point value in firestore.
Future<void> updateUserPoints(int pointsToAdd) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  int currentPoints = docSnapshot.data()!['points'] ??
      0; // If the points field doesn't exist, assume 0.
  int newPoints = currentPoints + pointsToAdd;
  await userDocRef.update({'points': newPoints});
  print('Points updated');
}

//Helper to retrive the current users points.
Future<int> getUserPoints() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  int currentPoints = docSnapshot.data()!['points'] ??
      0;
  return currentPoints;
}

//This helper function updates the cap value when the user updates or adds a machine.
Future<void> updateUserCap(int capToAdd) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  int currentCap = docSnapshot.data()!['cap'] ??
      0;
  int newCap = currentCap + capToAdd;
  await userDocRef.update({'cap': newCap});
  print('Cap updated');
}

//Helper to get the current value of cap in the users firestore storage.
Future<int?> getUserCap() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  int? cap = docSnapshot.data()?['cap'];
  return cap;
}

//This helps add the machine name to the machine array that is stored with the user.
Future<void> addMachineToUser(String? machineName) async {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userRef = FirebaseFirestore.instance.collection('Users');
  final query = userRef.where('email', isEqualTo: currentUser.email);

  final snapshot = await query.get();
  if (snapshot.docs.isNotEmpty) {
    final userDoc = snapshot.docs.single;
    final machinesEntered = List<String>.from(userDoc.get('machinesEntered'));
    machinesEntered.add(machineName!);

    await userDoc.reference.update({
      'machinesEntered': machinesEntered,
    }).then((_) {
      print('Machine added successfully!');
    }).catchError((error) {
      print('Error adding machine: $error');
    });
  } else {
    print('User not found with email ${currentUser.email}');
  }
}

//Used to get the users email so that we can search for there data in the firestore database.
Future<userInfo?> getUserByEmail(String email) async {
  try {
    final db = FirebaseFirestore.instance;
    final query = db.collection('Users').where('email', isEqualTo: email);
    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.single.data();
      final firstName = userData['first name'] as String?;
      final lastName = userData['last name'] as String?;
      final points = userData['points'] as int?;
      final cap = userData['cap'] as int?;
      final machinesEntered = List<String>.from(userData['machinesEntered']);

      if (firstName != null &&
          lastName != null &&
          points != null &&
          cap != null &&
          machinesEntered != []) {
        return userInfo(
          firstname: firstName,
          lastname: lastName,
          email: email,
          points: points,
          cap: cap,
          machinesEntered: machinesEntered,
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

// This function is used to store the wait time between uploading 3 machines a day
// Here we are taking in the 3rd images metadata data and adding 24 hours to it to get the time the user can upload again.
Future<void> setTimeAfter24Hours(DateTime timeAfter24Hours) async {
  // Get the current user
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Get a reference to the Users collection in the firestore user storage
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    // Convert the DateTime to a Timestamp
    Timestamp timeAfter24HoursTimestamp = Timestamp.fromDate(timeAfter24Hours);

    // Update the timeAfter24Hours field for the current user
    await users
        .doc(user.uid)
        .update({'timeAfter24Hours': timeAfter24HoursTimestamp}).catchError(
            (error) => print('Failed to update user: $error'));
  } else {
    print('No user is currently signed in.');
  }
}

//Similar to the one above this is a helper function to get the timeAfter24Hours variable
Future<DateTime?> getTimeAfter24Hours() async {
  final user = FirebaseAuth.instance.currentUser;
  DateTime? timeAfter24Hours;

  if (user != null) {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    try {
      DocumentSnapshot userDoc = await users.doc(user.uid).get();
      if (userDoc.exists) {
        Timestamp timestamp = userDoc['timeAfter24Hours'];
        timeAfter24Hours = timestamp.toDate();
      }
    } catch (error) {
      print('Failed to get timeAfter24Hours from Firestore: $error');
    }
  } else {
    print('No user is currently signed in.');
  }

  return timeAfter24Hours;
}
