import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gemini_chat/main.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () {
      // Check if the user is logged in
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // If user is logged in, navigate to Home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home(user: user)),
        );
      } else {
        // If user is not logged in, navigate to Authentication screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
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
