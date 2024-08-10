import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class AppDrawer extends StatelessWidget {
  final User user;
  const AppDrawer({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.displayName ?? ""),
            accountEmail: Text(user.email ?? ""),
            currentAccountPicture: CircleAvatar(
              child: Image.asset('assets/person.png'),
            ),
            otherAccountsPictures: [
              IconButton(
                icon: const Icon(Icons.logout),
                color: Colors.white,
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
