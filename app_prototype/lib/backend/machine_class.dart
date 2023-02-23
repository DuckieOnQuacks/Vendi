import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vendi_app/home_page.dart';

//Things to store:
//Machine ID (unique to each machine)
//Machine Desc (snack/drink/located on this floor)
//Machine Latitude
//Machine Longitude
//Machine Image (path to image)
//Machine isFavorited
//Machine icon (icon on google maps)

// Because of no backend this is a template file for storing machine data
class Machine {
  int? id;
  final String name;
  final String desc;
  final double lat;
  final double lon;
  late String imagePath;
  late int isFavorited;
  final String icon;

  // Constructor
  Machine(
      {this.id,
      required this.name,
      required this.desc,
      required this.lat,
      required this.lon,
      required this.imagePath,
      required this.isFavorited,
      required this.icon});

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
      id: json['id'],
      name: json['name'],
      desc: json['description'],
      lat: json['latitude'],
      lon: json['longitude'],
      imagePath: json['imagePath'],
      isFavorited: json['favorite'],
      icon: json['icon']
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': desc,
        'latitude': lat,
        'longitude': lon,
        'imagePath': imagePath,
        'favorite': isFavorited,
        'icon': icon
  };
}
