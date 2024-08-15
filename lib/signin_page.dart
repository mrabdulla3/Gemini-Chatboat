import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'forgotpassword.dart';
import 'home.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = "", password = "";
  bool rememberMe = false;
  bool _paaswordVisible = false;

  final Logger _logger = Logger();

  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  Future<String?> _getChatId(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('chats').doc(uid).get();

      if (doc.exists) {
        return doc.get('chatId') as String?;
      } else {
        return null;
      }
    } catch (e) {
      _logger.e('Error retrieving chatId: $e');
      return null;
    }
  }

  userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Fetch chatId from Firestore
      String chatId = await _getChatId(userCredential.user!.uid) ?? "";
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Home(
                      user: userCredential.user!,
                      chatId: chatId,
                    )));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "No User Found for that Email",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      } else if (e.code == 'wrong-password') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Wrong Password Provided by User",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
    }
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        return userCredential.user;
      } on FirebaseAuthException catch (e) {
        _logger.e(e.message);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Form(
      key: _formkey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sign In',
              style:
                  GoogleFonts.acme(fontSize: 30, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: screenWidth * 0.9,
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
                        hintText: 'email',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person)),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.9,
              height: screenHeight * 0.08,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the password';
                      }
                      return null;
                    },
                    controller: passwordController,
                    obscureText: !_paaswordVisible,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(_paaswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _paaswordVisible = !_paaswordVisible;
                            });
                          },
                        ),
                        prefixIcon: const Icon(Icons.key)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    Text(
                      'Remember me',
                      style: GoogleFonts.abyssinicaSil(),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPassword(),
                        ));
                  },
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.abyssinicaSil(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.06,
              decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  borderRadius: BorderRadius.circular(10)),
              child: TextButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent),
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    setState(() {
                      email = mailController.text;
                      password = passwordController.text;
                    });
                    userLogin();
                  }
                },
                child: Text(
                  'Sign In',
                  style:
                      GoogleFonts.aclonica(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Or', style: GoogleFonts.abrilFatface(color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10)),
              child: TextButton.icon(
                onPressed: () {
                  signInWithGoogle();
                },
                icon: const Icon(Icons.login),
                label: const Text('Continue With Google'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
