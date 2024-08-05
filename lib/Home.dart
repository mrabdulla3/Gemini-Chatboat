import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'sidebar.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ChatUser mySelf = ChatUser(id: '1', firstName: 'Abdulla');
  ChatUser bot = ChatUser(id: '2', firstName: 'Gemini');
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  ChatMessage? selectedImageMessage; // To store the image message

  double _value = 0;
  Color _color = Colors.blue;
  bool _isDarkMode = false;

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
            {"text": m.text},
            if (m.medias?.isNotEmpty ?? false)
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data":
                      base64Encode(File(m.medias!.first.url).readAsBytesSync()),
                }
              }
          ]
        }
      ]
    };

    //print(data);

    try {
      var response = await http.post(Uri.parse(url),
          headers: header, body: json.encode(data));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        // print('result:' + result);

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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImageMessage = ChatMessage(
          text: _textController.text,
          user: mySelf,
          createdAt: DateTime.now(),
          medias: [
            ChatMedia(
              url: pickedFile.path,
              fileName: "",
              type: MediaType.image,
            ),
          ],
        );
        //print(selectedImageMessage!.medias);
      });
    }
  }

  void _sendMessage(ChatMessage message) {
    if (_textController.text.isNotEmpty || selectedImageMessage != null) {
      //print(_textController.text);
      message = ChatMessage(
        text: _textController.text,
        user: mySelf,
        createdAt: DateTime.now(),
        medias: selectedImageMessage?.medias ?? [],
      );

      setState(() {
        selectedImageMessage = null;
        _textController.clear();
      });
      getData(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 91, 85, 85),
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 3, bottom: 3, left: 10, right: 10),
                  child: Text(
                    'Gemini Chat',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                )),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                  });
                },
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              )
            ],
          ),
          drawer: AppDrawer(),
          body: DashChat(
            inputOptions: InputOptions(
              textController: _textController,
              trailing: [
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                ),
              ],
              leading: [
                if (selectedImageMessage != null)
                  Container(
                    height: 50,
                    width: 50,
                    child: Image.file(
                      File(selectedImageMessage!.medias![0].url),
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            typingUsers: typing,
            messages: allMessages,
            currentUser: mySelf,
            onSend: (ChatMessage m) {
              _sendMessage(m);
            },
          ),
        ));
  }
}
