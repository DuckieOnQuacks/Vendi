import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget{
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Enter Your Email and we will send you a password reset link'),
      ),
    );
  }
}
