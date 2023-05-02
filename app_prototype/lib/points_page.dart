import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/point_redemption_page.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'backend/user_helper.dart';

// All code on this page was developed by the team using the flutter framework

class PointsPage extends StatefulWidget {
  const PointsPage({Key? key}) : super(key: key);

  @override
  _PointsPageState createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[50],
        body: SafeArea(
            child: Center(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/3MachinesStacked.png',
              scale: 2,
            ),
            FutureBuilder<String>(
              future: getUserName(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    '${snapshot.data ?? ""}, you have',
                    style: GoogleFonts.bebasNeue(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            IgnorePointer(
              ignoring: true,
              child: SleekCircularSlider(
              min: 0,
              max: 500,
              appearance: CircularSliderAppearance(
                size: 250,
                startAngle: 180,
                angleRange: 180,
                customColors: CustomSliderColors(
                  // trackColor: Colors.red,
                  trackColor: Colors.pink,
                  progressBarColors: [
                    Colors.pinkAccent,
                    Colors.yellow,
                    Colors.lightBlueAccent
                  ],
                  //progressBarColor: Colors.lightBlueAccent,
                  dotColor: Colors.white,
                  shadowColor: Colors.pink[900],
                ),
                infoProperties: InfoProperties(
                  mainLabelStyle: GoogleFonts.chicle(
                      fontSize: 50, fontWeight: FontWeight.bold),
                  bottomLabelText: 'Vendi Points',
                  bottomLabelStyle: GoogleFonts.bebasNeue(
                      fontSize: 40, fontWeight: FontWeight.bold),
                  modifier: (double value) {
                    final roundedValue = value.toStringAsFixed(1);
                    return roundedValue;
                  },
                ),
              ),
              initialValue: currentPoints.toDouble(),
              onChange: (double value) {
                print(value);
              },
              onChangeStart: (double value) {
                print('Start $value');
              },
              onChangeEnd: (double value) {
                print('End $value');
              },
            ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return const PointsRedemptionPage();
                  }));
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.all(20)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pinkAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.pinkAccent)))),
                child: const Center(
                  child: Text(
                    'Redeem',
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
        ))));
  }
}
