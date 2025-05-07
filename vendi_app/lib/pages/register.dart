import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/pages/login.dart';
import 'dart:core';
import '../backend/message_helper.dart';

//Object Cleanup, removes from tree permanently
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

//Register
class _RegisterPageState extends State<RegisterPage> {
  // All code on this page was developed by the team using the flutter framework
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  int points = 0;
  int cap = 0;
  List<String> machinesEntered = [];
  List<String> machinesFavorited = [];
  List<String> machinesRated = [];
  Color primaryColor = Colors.pink.shade400;
  String ProfilePicture = 'assets/images/profile_pic4.png';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isEmailValid(String email) {
    // Check if email is valid using regex pattern
    final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  void createAccount() async {
    // Check if fields are not empty
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPassword.text.isEmpty ||
        usernameController.text.isEmpty) {
      showMessage(context, 'Notice', 'Please complete all fields.');
      return;
    }

    // Check if email is valid
    if (!_isEmailValid(emailController.text)) {
      showMessage(context, 'Notice', 'Please enter a valid email.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );

    try {
      // Check if password is confirmed
      if (passwordController.text == confirmPassword.text) {
        // Check if length of passwords entered are greater than 6
        if (passwordController.text.length > 6 &&
            confirmPassword.text.length > 6) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          addUserDetails();
          Navigator.pop(context); // Close loading dialog
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return const LoginPage();
          }));
        } else {
          // Show error message if password length is not greater than 6
          Navigator.pop(context); // Close loading dialog
          showMessage(
              context, 'Notice', 'Password must be at least 7 characters.');
        }
      } else {
        // Show error message if passwords don't match
        Navigator.pop(context); // Close loading dialog
        showMessage(context, 'Notice', 'Passwords do not match!');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog
      if (e.code == 'email-already-in-use') {
        showMessage(context, 'Notice', 'Email already in use.');
      } else {
        await showErrorMessage(e.code);
      }
    }
  }

  Future<void> addUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user signed in.');
      return;
    }
    final userDocRef =
        FirebaseFirestore.instance.collection('Users').doc(user.uid);
    await userDocRef.set({
      'username': usernameController.text.trim(),
      'email': emailController.text.trim(),
      'points': points,
      'cap': cap,
      'machinesEntered': machinesEntered,
      'timeAfter24Hours': Timestamp.fromMillisecondsSinceEpoch(
          0), // creates a default value for the timestamp which is December 31st, 1969, 4:00:00PM UTC because of timezones
      'machinesFavorited': machinesFavorited,
      'profilePicture': ProfilePicture,
      'rank': 0,
      'darkMode': false,
      'machinesRated': machinesRated,
      'primaryColor': 4294198412,
      'lastLoginDate': Timestamp.fromDate(DateTime.now()),
      'loginStreak': 0,
      'totalLoginDays': 0,
      'unlockedAchievements': [],
    });
  }

  //error message box
  //Show error message if password or email is invalid
  Future<void> showErrorMessage(String message) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the AlertDialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassword.dispose();
    usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    // The registration page scaffold
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo with shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/PinkMachine.png',
                        scale: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to Vendi!',
                      style: GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.bold,
                        fontSize: 42,
                        letterSpacing: 1.5,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: usernameController,
                            hintText: 'Username',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: confirmPassword,
                      hintText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Register button
                    ElevatedButton(
                      onPressed: createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        elevation: 4,
                        shadowColor: Color.fromRGBO(primaryColor.red,
                            primaryColor.green, primaryColor.blue, 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const LoginPage();
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
