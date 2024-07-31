import 'dart:convert';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ChatUser mySelf = ChatUser(id: '1', firstName: 'Abdulla');
  ChatUser bot = ChatUser(id: '2', firstName: 'Gemini');
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];
  // final TextEditingController _textController = TextEditingController();
  // final ImagePicker _picker = ImagePicker();

  bool isProcessing = false;

  final url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyDVM-eYq7isnRiVznImO3IqnWXy6uIYSDo';

  final header = {'Content-Type': 'application/json'};
  Future<void> getData(ChatMessage m) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
      typing.add(bot);
      allMessages.insert(0, m);
    });

    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };
    try {
      var response = await http.post(Uri.parse(url),
          headers: header, body: json.encode(data));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        ChatMessage gemini = ChatMessage(
          text: result['candidates'][0]['content']['parts'][0]['text'],
          user: bot,
          createdAt: DateTime.now(),
        );

        setState(() {
          allMessages.insert(0, gemini);
          typing.remove(bot);
        });
      } else {
        print("Error Occurred: ${response.body}");
        setState(() {
          typing.remove(bot);
        });
      }
    } catch (e) {
      print("An error occurred: $e");
      setState(() {
        typing.remove(bot);
      });
    } finally {
      setState(() {
        isProcessing = false;
        typing.remove(bot);
      });
    }
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     final image = File(pickedFile.path);
  //     _sendFile(image);
  //   } else {
  //     print('No Image Selected');
  //   }
  // }

  // void _sendFile(File image) {
  //   ChatMessage imageMessage = ChatMessage(
  //       text: '',
  //       user: mySelf,
  //       createdAt: DateTime.now(),
  //       customProperties: {
  //         'imageUrl': image.path,
  //       });

  //   setState(() {
  //     allMessages.insert(0, imageMessage);
  //   });

  //   //I need to write image request code here
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gemini Chat'), centerTitle: true),
      body: DashChat(
        typingUsers: typing,
        messages: allMessages,
        currentUser: mySelf,
        onSend: (ChatMessage m) {
          getData(m);
        },
      ),
    );
  }
}
