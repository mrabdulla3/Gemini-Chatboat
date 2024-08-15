import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_chat/home.dart';
import 'firestore_services.dart';
import 'main.dart';

class AppDrawer extends StatelessWidget {
  final User user;
  final FirestoreService firestoreService =
      FirestoreService(); // Instantiate FirestoreService

  AppDrawer({super.key, required this.user});

  void _showEditDialog(
      BuildContext context, String chatId, String currentTitle) {
    final TextEditingController titleController =
        TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Chat Title'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Enter new title'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  await firestoreService.updateChatTitle(chatId, newTitle);
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.purple.shade300),
            accountName: Text(user.displayName ?? ""),
            accountEmail: Text(user.email ?? "",
                style: GoogleFonts.robotoSlab(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                )),
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
          StreamBuilder<List<Map<String, dynamic>>>(
            stream:
                firestoreService.getChatList(), // Use the updated getChatList
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const ListTile(
                  title: Text("No chats available"),
                );
              }
              return Column(
                children: snapshot.data!.map((chat) {
                  return ListTile(
                    title: Text(chat['title'],
                        style: GoogleFonts.merriweather(
                            textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black, // Adjust the color as needed
                        ))), // Display the chat title
                    trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_outlined),
                        onSelected: (value) async {
                          // Handle the selected option
                          if (value == 'Delete') {
                            firestoreService.deleteChatDocument(chat['id']);
                          } else if (value == 'Edit') {
                            // Data to update
                            _showEditDialog(context, chat['id'], chat['title']);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: 'Delete',
                              child: Text('Delete'),
                            ),
                            const PopupMenuItem(
                              value: 'Edit',
                              child: Text('Edit'),
                            ),
                          ];
                        }),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Home(
                            user: user,
                            chatId: chat['id'], // Pass the chatId to Home
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
