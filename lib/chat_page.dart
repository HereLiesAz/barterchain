// lib/chat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:barterchain/main.dart'; // Import main.dart to access global blockchainService and __app_id

class ChatPage extends StatefulWidget {
  final String recipientId; // The ID of the user being chatted with

  const ChatPage({super.key, required this.recipientId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // For auto-scrolling
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = blockchainService.userId; // Get current user's ID
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Firestore collection path for chat messages
  // /artifacts/{appId}/users/{userId}/chats/{recipientId}/messages
  CollectionReference _getChatCollection(String currentUserId, String otherUserId) {
    // To ensure consistent chat history regardless of who initiates,
    // we sort the user IDs to create a canonical chat room ID.
    final List<String> participants = [currentUserId, otherUserId]..sort();
    final String chatRoomId = participants.join('_'); // e.g., user1_user2

    return db.collection('artifacts')
             .doc(__app_id) // Access the global __app_id from main.dart
             .collection('users')
             .doc(currentUserId) // Store chat history under the current user's path
             .collection('chats')
             .doc(chatRoomId)
             .collection('messages');
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final String messageText = _messageController.text.trim();
      _messageController.clear(); // Clear input immediately for better UX

      try {
        await _getChatCollection(_currentUserId, widget.recipientId).add({
          'senderId': _currentUserId,
          'recipientId': widget.recipientId,
          'text': messageText,
          'timestamp': FieldValue.serverTimestamp(), // Use server timestamp for consistency
        });
        // Also add to the recipient's chat collection to ensure both see the history
        await _getChatCollection(widget.recipientId, _currentUserId).add({
          'senderId': _currentUserId,
          'recipientId': widget.recipientId,
          'text': messageText,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Scroll to the bottom after sending a message
        if (mounted && _scrollController.hasClients) { // Guard with mounted check
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        // Log the error, but avoid print in production code
        // print('Error sending message to Firestore: $e');
        if (mounted) { // Guard with mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message: $e'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: const EdgeInsets.all(16.0),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipientId}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getChatCollection(_currentUserId, widget.recipientId)
                  .orderBy('timestamp', descending: true) // Order by timestamp to get latest at bottom
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.redAccent)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Start the conversation. Deconstruct their offer.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Process messages in reverse to display oldest at top, newest at bottom
                final messages = snapshot.data!.docs.reversed.toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Scroll to the bottom after the list view has built
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final String senderId = messageData['senderId'] as String;
                    final String text = messageData['text'] as String;
                    final Timestamp? timestamp = messageData['timestamp'] as Timestamp?;

                    final bool isMe = senderId == _currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueGrey[700] : Colors.grey[800],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12.0),
                            topRight: const Radius.circular(12.0),
                            bottomLeft: isMe ? const Radius.circular(12.0) : const Radius.circular(4.0),
                            bottomRight: isMe ? const Radius.circular(4.0) : const Radius.circular(12.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                            ),
                            if (timestamp != null)
                              Text(
                                '${timestamp.toDate().toLocal().hour}:${timestamp.toDate().toLocal().minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54, fontSize: 10),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your counter-offer or query...',
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.blueGrey[700],
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}