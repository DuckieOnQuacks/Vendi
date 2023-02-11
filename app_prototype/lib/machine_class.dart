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
  late final int id;
  late final String desc;
  late final double lat;
  late final double lon;
  late final String imagePath;
  late final int isFavorited;
  late final String icon;

  // Constructor
  Machine(
      {required this.id,
      required this.desc,
      required this.lat,
      required this.lon,
      required this.imagePath,
      required this.isFavorited,
      required this.icon});

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
      id: json['id'],
      desc: json['description'],
      lat: json['latitude'],
      lon: json['longitude'],
      imagePath: json['imagePath'],
      isFavorited: json['favorite'],
      icon: json['icon']
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': desc,
        'latitude': lat,
        'longitude': lon,
        'imagePath': imagePath,
        'favorite': isFavorited,
        'icon': icon
  };
}
