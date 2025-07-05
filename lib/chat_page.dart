// lib/chat_page.dart
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String recipientId; // The ID of the user being chatted with

  const ChatPage({super.key, required this.recipientId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = []; // Mock messages: {'sender': 'user_id', 'text': 'message'}

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'You', // In a real app, this would be the current user's ID
          'text': _messageController.text.trim(),
        });
      });
      print('Message sent to ${widget.recipientId}: ${_messageController.text.trim()}');
      _messageController.clear(); // Clear the input field after sending
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
          // Message List Area
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Start the conversation. Deconstruct their offer.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message['sender'] == 'You'; // Determine if the message is from the current user

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueGrey[700] : Colors.grey[800], // Different colors for sender/receiver
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12.0),
                              topRight: const Radius.circular(12.0),
                              bottomLeft: isMe ? const Radius.circular(12.0) : const Radius.circular(4.0),
                              bottomRight: isMe ? const Radius.circular(4.0) : const Radius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            message['text']!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Message Input Area
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
                    onSubmitted: (value) => _sendMessage(), // Send on Enter key
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
