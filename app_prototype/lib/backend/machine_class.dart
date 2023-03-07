
// Define the class Machine
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class Machine {
  // Variables to store machine data
  final String id; // Unique ID for each machine (nullable)
  final String name; // Name of the machine
  final String desc; // Description of the machine (snack/drink/located on this floor)
  final double lat; // Latitude of the machine's location
  final double lon; // Longitude of the machine's location
  late String imagePath; // Path to the image of the machine
  late int? isFavorited; // Whether the machine is favorited or not
  final String icon; // Icon of the machine on Google Maps
  final int card; // Whether the machine accepts card payments or not
  final int cash; // Whether the machine accepts cash payments or not
  final int operational; // Whether the machine is operational or not
  final int stock; // Amount of stock in the machine

  // Constructor for the Machine class
  Machine(
      {required this.id,
        required this.name,
        required this.desc,
        required this.lat,
        required this.lon,
        required this.imagePath,
        this.isFavorited,
        required this.icon,
        required this.card,
        required this.cash,
        required this.operational,
        required this.stock});

  // Factory method to create a Machine object from JSON data
  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
      id: json['id'],
      name: json['name'],
      desc: json['description'],
      lat: json['latitude'],
      lon: json['longitude'],
      imagePath: json['imagePath'],
      isFavorited: json['favorite'],
      icon: json['icon'],
      card: json['card'],
      cash: json['cash'],
      operational: json['operational'],
      stock: json['stock']
  );

  // Method to convert a Machine object to JSON data
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': desc,
    'latitude': lat,
    'longitude': lon,
    'imagePath': imagePath,
    'favorite': isFavorited,
    'icon': icon,
    'card': card,
    'cash': cash,
    'operational': operational,
    'stock': stock
  };

  Future<String> getImageCreationTime() async {
    //We have to parse this link for the image id https://firebasestorage.googleapis.com/v0/b/vendimaps-371008.appspot.com/o/images%2F1677749160576?alt=media&token=27f39227-eebd-4b7b-9d89-101df695f290
    final Uri uri = Uri.parse(imagePath);
    final String imagePathDecoded = Uri.decodeFull(uri.path); // decode URL encoding in path
    final String imageId = imagePathDecoded.split('/').last; // get last segment of path
    //Once we have the name of the corresponding machines image. Retrieve the metadata.
    final Reference storageRef = FirebaseStorage.instance.ref().child('images/$imageId');
    final FullMetadata metadata = await storageRef.getMetadata();
    final DateTime? creationTime = metadata.timeCreated;
    final String formattedDate = DateFormat('MM/dd/yyyy hh:mm a').format(creationTime!);
    return formattedDate;
  }
}
