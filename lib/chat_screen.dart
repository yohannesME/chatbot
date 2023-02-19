// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:chatbot/ChatMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_libs.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration:
                const InputDecoration.collapsed(hintText: "ask me anything."),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return _messages[index];
                },
                itemCount: _messages.length,
                reverse: true,
                padding: EdgeInsets.all(16),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: kcCardColor,
              ),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }
}
