import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gemini_chat/main.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch chatId from Firestore
      String? chatId = await _getChatId(user.uid);

      // Check if chatId is null
      if (chatId == null) {
        _logger.w("Chat ID not found. Redirecting to chat creation...");
        // Navigate to a screen where the user can create or select a chat
        if (mounted) {
          // Handle the scenario when the chatId is null
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => Home(
                    user: user,
                    chatId: 'default_chat_id')), // Or handle it as needed
          );
        }
      } else {
        // Navigate to Home screen with chatId
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => Home(user: user, chatId: chatId)),
          );
        }
      }
    } else {
      // If user is not logged in, navigate to Authentication screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }

  Future<String?> _getChatId(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('chats').doc(uid).get();
      if (doc.exists) {
        return doc.get('chatId') as String?;
      } else {
        // Handle case where chatId doesn't exist or has been deleted
        return null;
      }
    } catch (e) {
      // Handle errors
      _logger.e('Error fetching chatId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 52, 136, 205),
        child: Center(
          child: SizedBox(
            height: 250,
            width: 250,
            child: Image.asset('assets/icon.png'),
          ),
        ),
      ),
    );
  }
}
