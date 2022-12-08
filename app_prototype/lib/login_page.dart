import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/bottom_bar.dart';
import 'package:vendi_app/register_page.dart';

class LoginPage extends StatefulWidget
{
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
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
              const Icon(
                  Icons.android,
                  size: 100,
              ),
            Text(
                'Hello Again!',
                style: GoogleFonts.bebasNeue(
                fontWeight: FontWeight.bold,
                fontSize: 50,
                ),
            ),
            const SizedBox(height: 10), //Creates space between text
            Text(
                'Welcome back to Vendi, you\'ve been missed',
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
            //sign in button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                      return const BottomBar();
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
              const SizedBox(height:25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                      'Not a member?', style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                        return const RegisterPage();
                      }));
                    },
                    child: const Text(
                        ' Register Now!', style: TextStyle(
                        color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ],
              ),
          ],
        )
      )
    )
    );
  }
}
