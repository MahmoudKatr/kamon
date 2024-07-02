import 'package:flutter/material.dart';
import 'package:kamon/constant.dart';

class ChatBubble extends StatelessWidget {
  final String message; // Stores the incoming message

  const ChatBubble({
    super.key,
    required this.message, // Make 'message' a required parameter
  });
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16.0), // Consistent padding
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(32.0),
            bottomRight: Radius.circular(32.0),
          ),
          color: kPrimaryColor, // Use your defined primary color
        ),
        child: Text(
          message, // Display the passed 'message'
          style: const TextStyle(color: Colors.white), // Consistent style
        ),
      ),
    );
  }
}

class ChatBot extends StatelessWidget {
  final String message; // Stores the incoming message

  const ChatBot({
    super.key,
    required this.message, // Make 'message' a required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32.0),
            topRight: Radius.circular(32.0),
            bottomLeft: Radius.circular(32.0),
          ),
          color: Colors.blueGrey, // Adjust color to fit the theme
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
