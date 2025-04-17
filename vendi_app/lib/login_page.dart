import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/register_page.dart';
import 'package:vendi_app/reset_password_page.dart';
import 'backend/message_helper.dart';
import 'bottom_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // All code on this page was developed by the team using the flutter framework
  late final TextEditingController usernameController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  String? emailErrorMessage;
  String? passwordErrorMessage;
  bool _obscurePassword = true;

  void signUserIn() async {
    if (!mounted) {
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
      if (validateFields()) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: usernameController.text, password: passwordController.text);
        if (mounted) {
          setState(() {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return const BottomBar();
            }));
          });
        }
      } else {
        Navigator.pop(context);
        showMessage(context, 'Error', 'Please insert log in credentials');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        if (e.code == 'invalid-email') {
          showMessage(context, 'Error', 'Please enter a valid email');
        } else if (e.code == 'wrong-password') {
          showMessage(context, 'Error', 'Wrong password');
        } else if (e.code == 'user-not-found') {
          showMessage(context, 'Error',
              'This email address entered is not registered.');
        } else {
          showMessage(context, 'Error', 'An unexpected error occurred');
        }
      }
    }
  }

  bool validateFields() {
    bool valid = true;
    setState(() {
      emailErrorMessage = null;
      passwordErrorMessage = null;

      if (usernameController.text.isEmpty ||
          !usernameController.text.contains('@')) {
        emailErrorMessage = 'Please enter a valid email';
        valid = false;
      }
      if (passwordController.text.isEmpty ||
          passwordController.text.length < 6) {
        passwordErrorMessage =
            'Please enter a password with at least 6 characters';
        valid = false;
      }
    });
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    // The login page scaffold
    return Scaffold(
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
                                  'assets/images/YellowMachine.png',
                                  scale: 5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Hello Again!',
                                style: GoogleFonts.bebasNeue(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
                                  letterSpacing: 1.5,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              //Creates space between text
                              Text('Welcome back to Vendi, you\'ve been missed',
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 20,
                                    color: secondaryTextColor,
                                  )),
                              const SizedBox(height: 40),
                              //email text field
                              _buildTextField(
                                controller: usernameController,
                                hintText: 'Email',
                                prefixIcon: Icons.email_outlined,
                                errorText: emailErrorMessage,
                              ),
                              const SizedBox(height: 16),
                              //Password text field
                              _buildTextField(
                                controller: passwordController,
                                hintText: 'Password',
                                prefixIcon: Icons.lock_outline,
                                errorText: passwordErrorMessage,
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
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return ResetPasswordPage();
                                        }));
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              //sign in button
                              ElevatedButton(
                                onPressed: signUserIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  elevation: 4,
                                  shadowColor: Color.fromRGBO(
                                      primaryColor.red,
                                      primaryColor.green,
                                      primaryColor.blue,
                                      0.5),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Not a member?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return const RegisterPage();
                                      }));
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: primaryColor,
                                    ),
                                    child: const Text(
                                      'Register now',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]))))));
  }

  // Method to build text fields consistently
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    String? errorText,
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
        errorText: errorText,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.grey,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
