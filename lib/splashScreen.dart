import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gemini_chat/Home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Home()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: const Color.fromARGB(255, 52, 136, 205),
      child: Center(
        child: SizedBox(
            height: 250, width: 250, child: Image.asset('assets/icon.webp')),
      ),
    ));
  }
}
