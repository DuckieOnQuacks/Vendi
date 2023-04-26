import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'machine_class.dart';

class userInfo {
  // Variables to store user data
  final String firstname;
  final String lastname;
  final String email;
  final int points;
  final int cap;
  final List<String> machinesEntered;
  final DateTime? timeAfter24Hours; // New property for timeAfter24Hours
  final List<String>? machinesFavorited;

  // Constructor for the userInfo class
  userInfo({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.points,
    required this.cap,
    required this.machinesEntered,
    this.timeAfter24Hours, // Add new property to constructor
    this.machinesFavorited,
  });

  // Factory method to create a userInfo object from JSON data
  factory userInfo.fromJson(Map<String, dynamic> json) => userInfo(
        firstname: json['firstname'],
        lastname: json['lastname'],
        email: json['email'],
        points: json['points'],
        cap: json['cap'],
        machinesEntered: List<String>.from(json['machinesEntered']),
        timeAfter24Hours: (json['timeAfter24Hours'] as Timestamp).toDate(), // Convert Timestamp to DateTime
        machinesFavorited: List<String>.from(json['favoriteMachines']),
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
        'machinesFavorited': machinesFavorited,
      };
}

//Helper to retrieve the current users points.
//Instead of reading from Firestore every time, cache the value in memory.
Future<int?> getUserPoints() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final docSnapshot = await userDocRef.get();
    int? points = docSnapshot.data()!['points'] ?? 0;
  return points;
}

//Helper to retrive the users first name.
Future<String> getUserName() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  String username = docSnapshot.data()!['first name'] ?? 0;
  return username;
}

//This function get the ids found in the users machinesFavorited field and returns the corrspnding machines that can
//be found in the firestore database.
Future<List<Machine>> getMachinesFavorited() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  List<String>? machineIds = List<String>.from(docSnapshot.data()!['machinesFavorited'] ?? []);

  if (machineIds.isEmpty) {
    return [];
  }
  final machineDocs = await FirebaseFirestore.instance.collection('Machines')
      .where(FieldPath.documentId, whereIn: machineIds)
      .limit(10)
      .get();

  final machines = machineDocs.docs.map((doc) => Machine.fromJson(doc.data())).toList();

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

//Helper to get the current value of cap in the users firestore storage.
Future<int?> getUserCap() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  int? cap = docSnapshot.data()?['cap'];
  return cap;
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

//This helper function updates the cap value when the user updates or adds a machine.
Future<void> setUserCap(int capToAdd) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  int currentCap = docSnapshot.data()!['cap'] ??
      0;
  int newCap = currentCap + capToAdd;
  await userDocRef.update({'cap': newCap});
  print('Cap updated');
}

Future<void> setMachineToFavorited(String machineId) async {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userRef = FirebaseFirestore.instance.collection('Users');
  final query =  userRef.where('email', isEqualTo: currentUser.email);

  final snapshot = await query.get();
  if(snapshot.docs.isNotEmpty)
  {
    final userDoc = snapshot.docs.single;
    final machinesFavorited = List<String>.from(userDoc.get('machinesFavorited') ?? []);
    if (!machinesFavorited.contains(machineId)) {
      machinesFavorited.add(machineId);
      await userDoc.reference.update({'machinesFavorited': machinesFavorited,
      }).then((_) {
        print('Machine added to favorites successfully!');
      }).catchError((error) {
        print('Error adding machine to favorites: $error');
      });
    } else {
      print('Machine is already in favorites');
    }
  } else {
    print('User not found with email ${currentUser.email}');
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

Future<bool> isMachineFavorited(Machine machine) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  List<String> machineIds = List<String>.from(docSnapshot.data()!['machinesFavorited'] ?? []);

  return machineIds.contains(machine.id);
}

Future<void> removeMachineFromFavorited(String machineId) async {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);

  try {
    final docSnapshot = await userDocRef.get();
    final machinesFavorited = List<String>.from(docSnapshot.get('machinesFavorited') ?? []);

    if (machinesFavorited.contains(machineId)) {
      machinesFavorited.remove(machineId);
      await userDocRef.update({'machinesFavorited': machinesFavorited});
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

//Helper to update the current users point value in firestore.
Future<void> setUserPoints(int pointsToAdd) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
  final docSnapshot = await userDocRef.get();
  int currentPoints = docSnapshot.data()!['points'] ??
      0; // If the points field doesn't exist, assume 0.
  int newPoints = currentPoints + pointsToAdd;
  await userDocRef.update({'points': newPoints});
  print('Points updated');
}
