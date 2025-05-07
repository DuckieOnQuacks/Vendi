// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode;
  Color _primaryColor = Colors.pink; // Default primary color

  ThemeProvider({this.themeMode = ThemeMode.light}) {
    // Try to load the theme mode and primary color from user preferences
    loadUserThemePreference();
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  Color get primaryColor => _primaryColor;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Update primary color based on profile picture
  void updatePrimaryColor(String profilePicturePath) {
    if (profilePicturePath.contains('profile_pic1.png')) {
      _primaryColor = const Color(0xfffbca28);
    } else if (profilePicturePath.contains('profile_pic2.png')) {
      _primaryColor = const Color.fromARGB(255, 237, 169, 10);
    } else if (profilePicturePath.contains('profile_pic3.png')) {
      _primaryColor = const Color(0xFFF3748C);
    } else if (profilePicturePath.contains('profile_pic4.png')) {
      _primaryColor = const Color(0xFF3EBDCE);
    } else if (profilePicturePath.contains('profile_pic5.png')) {
      _primaryColor = const Color(0xFF7EC560);
    } else if (profilePicturePath.contains('profile_pic6.png')) {
      _primaryColor = const Color(0xFF51C5BF);
    } else if (profilePicturePath.contains('profile_pic7.png')) {
      _primaryColor = const Color.fromARGB(255, 179, 179, 179);
    } else if (profilePicturePath.contains('profile_pic8.png')) {
      _primaryColor = const Color(0xFF9460B0);
    } else {
      _primaryColor = Colors.pink; // Default color
    }

    // Save the color preference to Firestore
    saveUserPrimaryColorPreference();
    notifyListeners();
  }

  // Reset primary color to default
  void resetToDefaultColor() {
    _primaryColor = Colors.pink; // Set to default pink
    saveUserPrimaryColorPreference(); // Save the default color preference
    notifyListeners(); // Notify listeners to rebuild UI
  }

  // Load the user's theme preference from Firestore
  Future<void> loadUserThemePreference() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseFirestore.instance.collection('Users');
        final query = userRef.where('email', isEqualTo: currentUser.email);

        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          final userDoc = snapshot.docs.single;
          final isDarkMode = userDoc.data()['darkMode'] ?? false;

          // Load primary color if available
          if (userDoc.data().containsKey('primaryColor')) {
            final colorValue = userDoc.data()['primaryColor'] as int?;
            if (colorValue != null) {
              _primaryColor = Color(colorValue);
            }
          }

          // Update theme mode based on stored preference
          themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  // Save the user's primary color preference to Firestore
  Future<void> saveUserPrimaryColorPreference() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseFirestore.instance.collection('Users');
        final query = userRef.where('email', isEqualTo: currentUser.email);

        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          final userDoc = snapshot.docs.single;
          await userRef.doc(userDoc.id).update({
            'primaryColor': _primaryColor.value,
          });
        }
      }
    } catch (e) {
      print('Error saving primary color preference: $e');
    }
  }
}
