import 'package:google_maps_flutter/google_maps_flutter.dart';

// All code on this page was developed by the team using the flutter framework

// Because of no backend this is a template file for storing machine data
class MachineClass
{
  late bool isFavorited = false;
  late String machineName;
  late String machineDesc;
  late String machineIcon;
  late int machineId;
  String image = '';
  var machineLoc = const LatLng(39.54007668689109, -119.81492289354577);

  // Constructor
  MachineClass(String name, String icon, String description, int id, var location) {
    machineName = name;
    machineIcon = icon;
    machineId = id;
    machineLoc = location;
    machineDesc = description;
  }

  // Get methods
  bool? get getFavorited {
    return isFavorited;
  }
  String get name {
    return machineName;
  }
  String get asset {
    return machineIcon;
  }
  String get macImage {
    return image;
  }

  // Set methods
  set setFavorited (bool favorited)
  {
    isFavorited = favorited;
  }
  set machineImage (String macImage)
  {
    image = macImage;
  }
}