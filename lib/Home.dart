import 'dart:convert';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_services.dart';
import 'package:logger/logger.dart';

class Home extends StatefulWidget {
  final User user;
  final String chatId;
  const Home({super.key, required this.user, required this.chatId});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirestoreService _firestoreService = FirestoreService();
  late User user;
  String chatTitle = "Gemini Chat"; // Default title
  late String chatId; // Local mutable chatId variable

  @override
  void initState() {
    super.initState();
    user = widget.user;
    chatId = widget
        .chatId; // Initialize the local chatId variable with the provided chatId
    // Fetch chat messages for the provided chatId
    _firestoreService.getMessages(widget.chatId).listen((messages) {
      setState(() {
        allMessages = messages;
      });
    });
    // Fetch chat title for the provided chatId
    _firestoreService.getChatTitle(widget.chatId).then((title) {
      setState(() {
        if (title != null && title.isNotEmpty) {
          chatTitle = title; // Update chat title if available
        }
      });
    });
  }

  final Logger _logger = Logger();

  ChatUser mySelf = ChatUser(id: '1', firstName: 'Abdulla');
  ChatUser bot = ChatUser(id: '2', firstName: 'Gemini');
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  ChatMessage? selectedImageMessage; // To store the image message

  bool _isDarkMode = false;
  bool isProcessing = false;
  ChatMessage? lastSentMessage; // To store the last sent message

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyCU_Su_IN7jAgbvj1Pfc2fBQIqDV2V5F2Y';

  final header = {'Content-Type': 'application/json'};

  void _showChatError(String error) {
    // Regular expression to match the API key pattern
    final apiKeyPattern = RegExp(r'AIza[0-9A-Za-z\-_]{35}');

    // Replace the API key with a masked version or remove it completely
    final safeError = error.replaceAll(apiKeyPattern, '[API_KEY_REDACTED]');
    ChatMessage errorMessage = ChatMessage(
      text: "An error occurred: $safeError",
      user: bot,
      createdAt: DateTime.now(),
    );
    setState(() {
      allMessages.insert(0, errorMessage);
      typing.remove(bot);
    });
  }

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

    try {
      var response = await http.post(Uri.parse(_url),
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
        _onSend(gemini);
      } else {
        _showChatError("Error Occurred: ${response.body}");
        setState(() {
          typing.remove(bot);
        });
      }
    } catch (e) {
      _showChatError("An error occurred: $e");
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
      });
    }
  }

  void _sendMessage(ChatMessage message) {
    if (_textController.text.isNotEmpty || selectedImageMessage != null) {
      message = ChatMessage(
        text: _textController.text,
        user: mySelf,
        createdAt: DateTime.now(),
        medias: selectedImageMessage?.medias ?? [],
      );

      setState(() {
        lastSentMessage = message; // Store the last sent message
        selectedImageMessage = null;
        _textController.clear();
      });
      _onSend(message); // Send the message
      getData(message);
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
      content: Text('Text copied'),
    ));
  }

  void regenerateResponse() {
    if (lastSentMessage != null) {
      getData(lastSentMessage!);
    }
  }

  Widget customMessageBuilder(ChatMessage message, ChatMessage? previousMessage,
      ChatMessage? nextMessage) {
    bool isError = message.text.startsWith("Error:") ||
        message.text.startsWith("An error occurred:");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.text,
          style: TextStyle(
            color: isError
                ? Colors.red
                : (_isDarkMode ? Colors.white : Colors.black),
          ),
        ),
        if (isError)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  copyToClipboard(allMessages.first.text);
                },
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                ),
              ),
              IconButton(
                  onPressed: () {
                    regenerateResponse();
                  },
                  icon: const Icon(
                    Icons.autorenew_outlined,
                    size: 19,
                  ))
            ],
          ),
        if (message.user.id == bot.id && !isError)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  copyToClipboard(allMessages.first.text);
                },
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                ),
              ),
              IconButton(
                  onPressed: () {
                    regenerateResponse();
                  },
                  icon: const Icon(
                    Icons.autorenew_outlined,
                    size: 19,
                  ))
            ],
          )
      ],
    );
  }

  void _onSend(ChatMessage message) async {
    try {
      // Check if the chatId is null or empty
      if (chatId == 'default_chat_id' || chatId.isEmpty) {
        // Create a new chat document and get the new chatId
        chatId = await _firestoreService.createNewChatDocument();
      }
      // Extract the first word from the message text
      String firstWord = message.text.split(' ').take(6).join(' ');
      // Check if the chat title is still null or empty
      if (chatTitle == "Gemini Chat") {
        // Update the chat title with the first word of the first message
        await _firestoreService.updateChatTitle(chatId, firstWord);

        // Update the local state
        setState(() {
          chatTitle = firstWord;
        });
      }
      // Save the message to Firestore
      await _firestoreService.saveMessageToList(message, chatId);
      // Handle any additional UI updates or state changes here
    } catch (e) {
      _logger.e("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 91, 85, 85),
                    borderRadius: BorderRadius.circular(20)),
                child: const Padding(
                  padding:
                      EdgeInsets.only(top: 3, bottom: 3, left: 10, right: 10),
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
                  onPressed: () async {
                    // Create a new chat document
                    String newChatId =
                        await _firestoreService.createNewChatDocument();

                    // Navigate to the Home screen with the new chatId
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) =>
                              Home(user: widget.user, chatId: newChatId)),
                    );
                  },
                  icon: const Icon(Icons.messenger_outline_sharp)),
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
          drawer: AppDrawer(user: user),
          body: DashChat(
            inputOptions: InputOptions(
              inputTextStyle: const TextStyle(color: Colors.black),
              textController: _textController,
              trailing: [
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                ),
              ],
              leading: [
                if (selectedImageMessage != null)
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(selectedImageMessage!.medias![0].url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
            typingUsers: typing,
            messages: allMessages.reversed.toList(),
            currentUser: mySelf,
            onSend: (ChatMessage m) {
              _sendMessage(m);
            },
            messageOptions: MessageOptions(
                messageTextBuilder: customMessageBuilder,
                containerColor:
                    _isDarkMode ? Colors.black12 : Colors.grey.shade100),
          ),
        ));
  }
}
