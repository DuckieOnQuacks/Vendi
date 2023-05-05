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

  void signUserIn() async {
    if (!mounted) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
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
    // The login page scaffold
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[200],
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
              Image.asset(
                'assets/images/YellowMachine.png',
                scale: 5,
              ),
              const SizedBox(height: 10),
              Text(
                'Hello Again!',
                style: GoogleFonts.bebasNeue(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              const SizedBox(height: 10),
              //Creates space between text
              Text('Welcome back to Vendi, you\'ve been missed',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 19,
                  )),
              const SizedBox(height: 30),
              //email text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //Create Space between both boxes
              //Password text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true, //Hides password
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ResetPasswordPage();
                        }));
                      },
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              //sign in button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      signUserIn();
                    });
                  },
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.all(25)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.pink),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.pink[900]!, width: 3)))),
                  child: const Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not a member?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return const RegisterPage();
                      }));
                    },
                    child: const Text(
                      ' Register Now!',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ])))));
  }
}
