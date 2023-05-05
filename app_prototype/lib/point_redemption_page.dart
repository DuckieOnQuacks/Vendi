import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/user_helper.dart';

class PointsRedemptionPage extends StatefulWidget {
  const PointsRedemptionPage({Key? key}) : super(key: key);

  @override
  _PointsRedemptionPageState createState() => _PointsRedemptionPageState();
}

class _PointsRedemptionPageState extends State<PointsRedemptionPage> {
  int currentPoints = 0;

  @override
  void initState() {
    super.initState();
    getUserPoints().then((points) {
      setState(() {
        currentPoints = points!;
      });
    });
  }

  //popup window
  createAlertDialog(BuildContext context) {

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            buttonPadding: EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.pink,
                ),
                SizedBox(width: 10),
                Text(
                  'Redeem Vendi Points',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            content: const Text('Are you sure you want to redeem your Vendi Points?'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey[300],
                  onPrimary: Colors.black54,
                ),
                child: const Text('Cancel'),
              ),
              MaterialButton(
                child: Image.asset(
                  'assets/images/GoogleWalletBadge.png',
                  scale: 7,
                ),
                onPressed: () {},
              )
            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.pinkAccent),
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
        body: SafeArea(
            child: Center(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Balance:',
                style: GoogleFonts.bebasNeue(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                )),
            Text('$currentPoints Vendi Points',
                style: GoogleFonts.chicle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                )),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Text('Redeem \$5 reward',
                style: GoogleFonts.bebasNeue(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                )),
            const SizedBox(height: 10),
            //button will go to popup window
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  createAlertDialog(context);
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.all(25)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pinkAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.pink[900]!,
                                width: 2)))),
                child: const Center(
                  child: Text(
                    'Swap 500 points',
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
            Text('Want more information on how Vendi Points work?',
                style: GoogleFonts.bebasNeue(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            const SizedBox(height: 10),
            //button will go to popup window
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        buttonPadding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        title: Row(
                          children: [
                            Text(
                              'Vendi Point Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        content: const Text(
                            '- 100 Vendi points is equal to \$1. \n\n- Points can be redeemed beginning at 500 points. \n\n- Once 500 points is reached, the user can redeem points in \$5 incriminates. For instance, a user can redeem 1500 Vendi Points for \$15. \n\n- Each time a user adds a new machine they will gain 30 points. \n\n- Each time a user updates an existing machine the user will gain 15 points.'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.pinkAccent,
                              onPrimary: Colors.white,
                            ),
                            child: const Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );

                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.all(15)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.pink[900]!,
                                width: 3)))),
                child: const Center(
                  child: Text(
                    'Click here',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ))));
  }
}
