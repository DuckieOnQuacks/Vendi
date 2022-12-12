import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';


  createAlertDialog(BuildContext context) {
    TextEditingController customController = TextEditingController();

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        //Will Add if statement to check if updated fields
        //meet all requriements and not currently
        //equal to current fields
        title: Text("Profile Update Successful!"),

        actions: <Widget>[
          MaterialButton(

            child: Image.asset(
              'assets/images/YellowMachine.png',
              scale: 6,
            ),
            onPressed: () {},
          )
        ],
      );
    });
  }

  Widget build(BuildContext context) {
    bool isValid;
    return Scaffold(
        appBar: AppBar(title: const Text("Edit Profile")),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/KermitProfile.jpg',
                        scale: 4,
                      ),

                      const SizedBox(height: 50),

                      //Uploading New Profile Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: ElevatedButton(onPressed: () {

                        },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<
                                  EdgeInsetsGeometry>(
                                  const EdgeInsets.all(25)
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.pink
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                          color: Colors.yellow)
                                  )
                              )
                          ),
                          child: Text(
                              'Upload New Profile Picture', style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)
                          ),


                          //const SizedBox(height: 10),

                        ),
                      ),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.pink[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Name',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Create Space between both boxes
                      //Password text field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.pink[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: TextField(
                              obscureText: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Phone Number Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.pink[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: TextField(
                              obscureText: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Phone Number',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      //Password Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.pink[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: TextField(
                              obscureText: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                //color: Colors.white,
                                hintText: 'Password',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      //Update Profile Button
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),

                          child: ElevatedButton(onPressed: () {
                            createAlertDialog(context);
                          },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(
                                      const EdgeInsets.all(25)
                                  ),
                                  backgroundColor: MaterialStateProperty.all<
                                      Color>(
                                      Colors.yellow
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12),
                                          side: const BorderSide(
                                              color: Colors.yellow)
                                      )
                                  )
                              ),
                              child: Text('Update Profile', style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)
                              )


                            //const SizedBox(height: 10),

                          )
                      )

                    ]
                )
            )
        )
    );
  }








