

class MachineClass
{
  late bool isFavorited = false;
  late String machineName;
  late String machineIcon;
  late int machineId;

  // Constructor
  MachineClass(String name, String icon, int id)
  {
    machineName = name;
    machineIcon = icon;
    machineId = id;
  }

  // Get methods
  bool get getFavorited {
    return isFavorited;
  }
  String get name {
    return machineName;
  }
  String get asset {
    return machineIcon;
  }

  // Set methods
  set setFavorited (bool favorited) {
    isFavorited = favorited;
  }
}