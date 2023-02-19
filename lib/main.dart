import 'package:chatbot/chat_screen.dart';
import 'package:flutter/material.dart';
import 'app_libs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot',
      theme: lightTheme,
      home: const ChatScreen(),
    );
  }
}
