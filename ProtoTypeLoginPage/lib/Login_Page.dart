// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
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
            SizedBox(height: 10), //Creates space between text
            Text(
                'Welcome back to Vendi, you\'ve been missed',
                style: GoogleFonts.bebasNeue(
                  fontSize: 19,
                )
              ),
           SizedBox(height: 40),

              //email text field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left:20.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Email',
                    ),
                  ),
                ),
              ),
            ),

              SizedBox(height: 10), //Create Space between both boxes

            //Password text field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left:20.0),
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
              SizedBox(height: 10),

            //sign in button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
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
              SizedBox(height:25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'Not a member?', style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                  Text(
                      ' Register Now!', style: TextStyle(
                      color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
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
