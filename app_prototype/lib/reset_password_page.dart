import 'package:flutter/material.dart';
import 'package:vendi_app/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backend/message_helper.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final usernameController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  //Checks username in database
  Future<void> passReset() async {
    try {
      backgroundColor: Colors.pinkAccent;
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: usernameController.text.trim());
      showDialog(context: context,
          builder: (context) {
            return AlertDialog(
//Display Password Reset sent to email message
                content: Text(
                    'Email was found with this account! Password reset '
                        'link has been sent to email.')
            );
          }
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showMessage(context, 'Warning', e.code);
    }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[200],

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Display message
            SizedBox(height: 70),

            //Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                'Enter the email address associated with your account.',
                textAlign: TextAlign.center,
                //style: TextStyle(fontSize: 11),
                style: GoogleFonts.bebasNeue(
                  fontWeight: FontWeight.bold,
                  fontSize: 31,
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                'We will email you a link to reset your password.',
                textAlign: TextAlign.center,
                //style: TextStyle(fontSize: 11),
                style: GoogleFonts.oswald(
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 30),
            //Enter Email Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(15),
                ),
                
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            //Reset Password Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    passReset();
                  });
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<
                        EdgeInsetsGeometry>(
                        const EdgeInsets.all(25)),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.pink),
                    shape: MaterialStateProperty.all<
                        RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Colors.pink[900]!,
                                width: 3)
                        )
                    )
                ),
                child: const Center(
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),

                  ),
                ),
              ),
            ),
            SizedBox(height: 5),

            //Login Navigation Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Remember Your Account?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const LoginPage();
                        },
                      ),
                    );
                  },
                  child: const Text(
                    ' Login Now!',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 35),

            //machine image
            Image.asset(
              'assets/images/BlueMachine.png',
              scale: 4,
            ),
          ],
        ),
      ),

    );
  }
}
