import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/bottom_bar.dart';
import 'package:vendi_app/login_page.dart';


// All code on this page was developed by the team using the flutter framework

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Image.asset(
                     // 'assets/images/YellowMachine.png',
                     // scale: 5,
                    //),
                    const SizedBox(height: 10),
                    Text(
                      'Vendi',
                      style: GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.bold,
                        fontSize: 100,
                      ),
                    ),
                    const SizedBox(height: 10), //Creates space between text
                    Text(
                        'Sign up to keep track of your favorite machine!',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 19,
                        )
                    ),
                    const SizedBox(height: 40),
                    //email text field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left:20.0),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10), //Create Space between both boxes
                    //Password text field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left:20.0),
                          child: TextField(
                            obscureText: true, //Hides password
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    //email text field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left:20.0),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Phone Number',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    //sign in button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                            return const LoginPage();
                          }));
                        },
                        style: ButtonStyle (
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.all(25)
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.deepPurple
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Colors.deepPurple)
                                )
                            )
                        ),
                        child: const Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height:25),
                  ],
                )
            )
        )
    );
  }
}