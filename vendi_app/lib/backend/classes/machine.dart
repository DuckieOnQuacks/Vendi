// Define the class Machine
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Machine {
  // Variables to store machine data
  final String id; // Unique ID for each machine (nullable)
  final String name; // Name of the machine
  final String
      desc; // Description of the machine (snack/drink/located on this floor)
  final double lat; // Latitude of the machine's location
  final double lon; // Longitude of the machine's location
  late String imagePath; // Path to the image of the machine
  final String icon; // Icon of the machine on Google Maps
  final bool card; // Whether the machine accepts card payments or not
  final bool cash; // Whether the machine accepts cash payments or not
  late bool operational; // Whether the machine is operational or not
  late int upvotes; // Number of upvotes for the machine
  late int dislikes; // Number of dislikes for the machine
  late double rating; // Average star rating of the machine (1-5)
  late int ratingCount; // Number of ratings the machine has received
  late List<String> reports; // List of reports for the machine
  late int reportCount; // Number of reports the machine has received

  // Constructor for the Machine class
  Machine({
    required this.id,
    required this.name,
    required this.desc,
    required this.lat,
    required this.lon,
    required this.imagePath,
    required this.icon,
    required this.card,
    required this.cash,
    required this.operational,
    required this.upvotes,
    required this.dislikes,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.reports = const [],
    this.reportCount = 0,
  });

  // Factory method to create a Machine object from JSON data
  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      desc: json['description'] ?? '',
      lat: (json['latitude'] ?? 0.0).toDouble(),
      lon: (json['longitude'] ?? 0.0).toDouble(),
      imagePath: json['imagePath'] ?? '',
      icon: json['icon'] ?? '',
      card: json['card'] ?? false,
      cash: json['cash'] ?? false,
      operational: json['operational'] ?? true,
      upvotes: json['upvotes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      reports:
          json['reports'] != null ? List<String>.from(json['reports']) : [],
      reportCount: json['reportCount'] ?? 0,
    );
  }

  // Method to convert a Machine object to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': desc,
      'latitude': lat,
      'longitude': lon,
      'imagePath': imagePath,
      'icon': icon,
      'card': card,
      'cash': cash,
      'operational': operational,
      'upvotes': upvotes,
      'dislikes': dislikes,
      'rating': rating,
      'ratingCount': ratingCount,
      'reports': reports,
      'reportCount': reportCount,
    };
  }

  // Cache for image creation time to avoid repeated Firebase Storage calls
  String? _cachedImageCreationTime;

  Future<String> getImageCreationTime() async {
    if (_cachedImageCreationTime != null) {
      return _cachedImageCreationTime!;
    }

    try {
      final Uri uri = Uri.parse(imagePath);
      final String imagePathDecoded = Uri.decodeFull(uri.path);
      final String imageId = imagePathDecoded.split('/').last;

      final Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$imageId');
      final FullMetadata metadata = await storageRef.getMetadata();
      final DateTime? creationTime = metadata.timeCreated;

      if (creationTime != null) {
        _cachedImageCreationTime =
            DateFormat('MM/dd/yyyy hh:mm a').format(creationTime);
        return _cachedImageCreationTime!;
      }
    } catch (e) {
      print('Error getting image creation time: $e');
    }

    return 'Unknown';
  }
}

Future<DateTime?> getImageTakenTime(String imageUrl) async {
  try {
    // Ensure the URL is properly formatted
    if (!imageUrl.startsWith('http') && !imageUrl.startsWith('gs://')) {
      print('Invalid image URL format: $imageUrl');
      return null;
    }

    // If it's a Firebase Storage URL, convert it to a reference
    if (imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
      final Uri uri = Uri.parse(imageUrl);
      final String path = uri.path;
      final String decodedPath = Uri.decodeFull(path);
      final String imageId = decodedPath.split('/').last;
      final Reference ref =
          FirebaseStorage.instance.ref().child('images/$imageId');
      final FullMetadata metadata = await ref.getMetadata();
      return metadata.timeCreated;
    } else if (imageUrl.startsWith('gs://')) {
      final Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
      final FullMetadata metadata = await ref.getMetadata();
      return metadata.timeCreated;
    } else {
      print('Unsupported URL format: $imageUrl');
      return null;
    }
  } catch (e) {
    print("Error fetching image metadata: $e");
    return null;
  }
}

//Creates instance, gets snapshot
//Returns size of snapshot (number of total machines)
Future<int> getMachineCount() async {
  final machinesCollection = FirebaseFirestore.instance.collection('Machines');
  final querySnapshot = await machinesCollection.get();
  return querySnapshot.size;
}
