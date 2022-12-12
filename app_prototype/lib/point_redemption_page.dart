import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/bottom_bar.dart';
import 'package:vendi_app/register_page.dart';

class PointsRedemptionPage extends StatelessWidget {
  const PointsRedemptionPage({super.key});


    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(title: const Text("Redeem Points")),
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.grey[50],
          body: SafeArea(
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Redeem \$1 reward', style: GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.bold, fontSize: 50,)
                      ),
                      const SizedBox(height: 10),
                      //sign in button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (
                                    BuildContext context) {
                                  return const PointsRedemptionPage();
                                  return const BottomBar();
                                }));
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<
                                  EdgeInsetsGeometry>(
                                  const EdgeInsets.all(25)
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.pinkAccent
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                          color: Colors.pinkAccent)
                                  )
                              )
                          ),
                          child: const Center(
                            child: Text(
                              'Swap 25 points',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text('Redeem \$2 reward', style: GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.bold, fontSize: 50,)
                      ),
                      const SizedBox(height: 10),
                      //sign in button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (
                                    BuildContext context) {
                                  return const PointsRedemptionPage();
                                  return const BottomBar();
                                }));
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<
                                  EdgeInsetsGeometry>(
                                  const EdgeInsets.all(25)
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.lightBlue
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                          color: Colors.lightBlue)
                                  )
                              )
                          ),
                          child: const Center(
                            child: Text(
                              'Swap 50 points',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text('Redeem \$4 reward', style: GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.bold, fontSize: 50,)
                      ),
                      const SizedBox(height: 10),
                      //sign in button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (
                                    BuildContext context) {
                                  return const PointsRedemptionPage();
                                  return const BottomBar();
                                }));
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<
                                  EdgeInsetsGeometry>(
                                  const EdgeInsets.all(25)
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.deepPurple
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                          color: Colors.deepPurple)
                                  )
                              )
                          ),
                          child: const Center(
                            child: Text(
                              'Swap 100 points',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              )
          )
      );
    }
  }