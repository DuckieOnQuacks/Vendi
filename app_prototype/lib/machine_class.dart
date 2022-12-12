

class MachineClass
{
  bool isFavorited = false;
  String machineName;
  String machineIcon;
  int machineId;

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