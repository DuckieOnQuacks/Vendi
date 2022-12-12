import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendi_app/bottom_bar.dart';
import 'package:vendi_app/register_page.dart';

class PointsRedemptionPage extends StatelessWidget {
  const PointsRedemptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Point Redemption")),
    resizeToAvoidBottomInset: false,
    backgroundColor: Colors.grey[50],
    body: SafeArea(
    child: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    )
    )
    )
    );
  }
}