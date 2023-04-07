
class userInfo {
  // Variables to store user data
  final String firstname;
  final String lastname;
  final String email;
  final int points;
  final int cap;
  final List<String> machinesEntered; // New property to store machines entered

  // Constructor for the userInfo class
  userInfo({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.points,
    required this.cap,
    required this.machinesEntered, // Add new property to constructor
  });

  // Factory method to create a userInfo object from JSON data
  factory userInfo.fromJson(Map<String, dynamic> json) => userInfo(
    firstname: json['firstname'],
    lastname: json['lastname'],
    email: json['email'],
    points: json['points'],
    cap: json['cap'],
    machinesEntered: List<String>.from(json['machinesEntered']),
  );

  // Method to convert a userInfo object to JSON data
  Map<String, dynamic> toJson() => {
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'points': points,
    'cap': cap,
    'machinesEntered': machinesEntered,
  };
}

