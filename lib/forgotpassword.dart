import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController mailController = TextEditingController();

  resetPassword() async {
    if (mailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please enter your email",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
      return;
    }
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: mailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Password Reset Email Sent",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.message ?? "An error occurred",
            style: const TextStyle(fontSize: 18.0),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Card(
          child: SizedBox(
            height: screenHeight * 0.5,
            width: screenWidth * 0.85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Reset Password Via Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.08,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the email';
                          }
                          return null;
                        },
                        controller: mailController,
                        decoration: const InputDecoration(
                            hintText: 'enter your email',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.email)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                      color: Colors.purpleAccent,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent),
                    onPressed: () {
                      resetPassword();
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
