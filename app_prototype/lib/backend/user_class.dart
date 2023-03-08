
class userInfo {
  // Variables to store machine data
  final String firstname; // Unique ID for each machine (nullable)
  final String lastname; // Name of the machine
  final String email; // Description of the machine (snack/drink/located on this floor)
  final int points;

  // Constructor for the Machine class
  userInfo(
      {required this.firstname,
      required this.lastname,
      required this.email,
      required this.points});

  // Factory method to create a Machine object from JSON data
  factory userInfo.fromJson(Map<String, dynamic> json) => userInfo(
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      points: json['points']);

  // Method to convert a Machine object to JSON data
  Map<String, dynamic> toJson() => {
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'points': points,
      };
}
