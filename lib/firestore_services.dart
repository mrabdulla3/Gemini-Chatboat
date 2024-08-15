import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  Future<String?> getChatTitle(String chatId) async {
    if (chatId.isEmpty) {
      return null;
    }
    try {
      DocumentSnapshot doc = await _db.collection('chats').doc(chatId).get();

      // Cast the data to Map<String, dynamic>
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      return data?['title']; // Get the title from Firestore
    } catch (e) {
      _logger.e("Error fetching chat title: $e");
      return null;
    }
  }

  // Create a new chat document
  Future<String> createNewChatDocument() async {
    final newChatDoc = await _db.collection('chats').add({
      'title': null,
      'messages': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newChatDoc.id;
  }

  // Save a chat message to a list in Firestore
  Future<void> saveMessageToList(ChatMessage message, String chatId) async {
    try {
      // If no chatId is provided, create a new chat document
      if (chatId.isEmpty) {
        chatId = await createNewChatDocument();
      }

      // Reference to the chat document
      final chatDocRef = _db.collection('chats').doc(chatId);

      // Get the chat document to check if the title is already set
      DocumentSnapshot docSnapshot = await chatDocRef.get();

      // Cast the data to Map<String, dynamic>
      Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

      // Extract the first word from the message text
      String firstWord = message.text.split(' ').first;

      // Check if the title is not set or if it's the default "new chat"
      if (data == null ||
          data['title'] == null ||
          data['title'] == 'new chat') {
        await chatDocRef.update({
          'title': firstWord,
        });
      }

      // Create the new message object without an 'id' field
      final newMessage = {
        'text': message.text,
        'userId': message.user.id,
        'userName': message.user.firstName,
        'createdAt': message.createdAt,
        'mediaUrls': message.medias?.map((e) => e.url).toList(),
      };

      // Append the new message to the list using an arrayUnion to avoid overwriting
      await chatDocRef.update({
        'messages': FieldValue.arrayUnion([newMessage])
      });
    } catch (e) {
      _logger.e("Error saving message to list: $e");
    }
  }

  // Retrieve chat messages from Firestore
  Stream<List<ChatMessage>> getMessages(String chatId) {
    if (chatId.isEmpty) {
      return Stream.value(<ChatMessage>[]);
    }

    return _db.collection('chats').doc(chatId).snapshots().map((docSnapshot) {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        List<dynamic> messages = docSnapshot.data()?['messages'] ?? [];
        return messages.map((msg) {
          return ChatMessage(
            text: msg['text'] ?? '', // Ensure text is non-null
            user: ChatUser(
              id: msg['userId'] ?? 'unknown_user', // Handle missing userId
              firstName:
                  msg['userName'] ?? 'Unknown', // Handle missing userName
            ),
            createdAt: (msg['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now(), // Handle missing createdAt
            medias: (msg['mediaUrls'] != null)
                ? (msg['mediaUrls'] as List).map((url) {
                    return ChatMedia(
                      fileName: "", // Handle missing filename
                      url: url ?? '', // Handle missing url
                      type: MediaType.image, // Adjust as needed
                    );
                  }).toList()
                : [], // Return an empty list if mediaUrls is null
          );
        }).toList();
      } else {
        return <ChatMessage>[]; // Return an empty list if document doesn't exist
      }
    });
  }

  // Retrieve the list of chat documents
  Stream<List<Map<String, dynamic>>> getChatList() {
    return _db.collection('chats').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc.data()['title'] ?? 'Untitled' // Retrieve the title
        };
      }).toList();
    });
  }

  // Delete a chat document by its ID
  Future<void> deleteChatDocument(String chatId) async {
    if (chatId.isEmpty) {
      return;
    }
    try {
      await _db.collection('chats').doc(chatId).delete();
    } catch (e) {
      _logger.e("Error deleting chat document: $e");
    }
  }

  // Update the chat title
  Future<void> updateChatTitle(String chatId, String newTitle) async {
    try {
      await _db.collection('chats').doc(chatId).update({
        'title': newTitle,
      });
    } catch (e) {
      _logger.e("Error updating chat title: $e");
    }
  }
}
