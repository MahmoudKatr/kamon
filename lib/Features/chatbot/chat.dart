import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamon/Features/chatbot/chat_buble.dart';
import 'package:kamon/Features/chatbot/chatbot_clip.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<String> chatHistory = []; // Store chat history
  List<String> chatInputHistory = []; // Store chat history
  String url = '';
  String input_message = '';
  final TextEditingController _textEditingController = TextEditingController();
  final _controller = ScrollController();

  final SpeechToText _speechToText = SpeechToText();
  bool isListening = false; // Variable to track the listening state
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    bool available = await _speechToText.initialize(
      onError: (val) => debugPrint('onError: $val'),
      onStatus: (val) => debugPrint('onStatus: $val'),
    );
    setState(() {
      _speechEnabled = available;
    });
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
      isListening = true; // Ensure the state is updated to show listening
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false; // Ensure the state is updated to stop listening
    });
    _sendMessage();
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
    });
  }

  void _sendMessage() async {
    if (input_message.isEmpty) {
      input_message = _wordsSpoken;
    }
    url = 'http://192.168.1.6:5000/predict?message=$input_message';
    if (input_message.isNotEmpty) {
      chatInputHistory.add(input_message.toString());
      _textEditingController.clear();
      final data = await fetchData(url);
      final decoded = jsonDecode(data);
      input_message = '';
      _wordsSpoken = '';
      setState(() {
        chatHistory.add(decoded['answer']); // Use only the first element
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      });
    } else {
      debugPrint("Input message is empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kBeigeColor,
        child: Column(
          children: [
            ClipPath(
              clipper: BaseClipper(),
              child: const ChatbotClip(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  final inputMessage = chatInputHistory[index];
                  final chatMessage = chatHistory[index];
                  return Column(
                    children: [
                      ChatBubble(message: inputMessage),
                      ChatBot(message: chatMessage),
                    ],
                  );
                },
                controller: _controller,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          onChanged: (value) {
                            setState(() {
                              input_message = value;
                              url =
                                  'http://192.168.1.6:5000/predict?message=$input_message';
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          if (isListening) {
                            _stopListening();
                          } else {
                            _startListening();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: isListening
                              ? Colors.green
                              : Colors.red, // Change color based on listening state
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: Icon(
                          isListening
                              ? Icons.mic
                              : Icons
                                  .mic_off, // Change icon based on listening state
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Add padding below the buttons
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }
}