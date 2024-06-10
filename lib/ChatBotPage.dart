import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';


const apiKey = 'Your Api Key';


class ChatBotPage extends StatefulWidget {
  const ChatBotPage({Key? key}) : super(key: key);


  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}


class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  GenerativeModel? _model;


  @override
  void initState() {
    super.initState();
    _initializeModel();
  }


  void _initializeModel() async {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
  }


  void _sendMessage() async {
    if (_controller.text.isEmpty) return;


    setState(() {
      _messages.add({"sender": "user", "text": _controller.text});
    });


    final prompt = _controller.text;
    _controller.clear();


    if (_model != null) {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      setState(() {
        _messages.add({"sender": "bot", "text": response.text!});
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isUser) const CircleAvatar(child: Icon(Icons.android)),
                        if (!isUser) const SizedBox(width: 5.0),
                        Flexible(
                          child: Text(message["text"] ?? ''),
                        ),
                        if (isUser) const SizedBox(width: 5.0),
                        if (isUser) const CircleAvatar(child: Icon(Icons.person)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


void main() {
  runApp(const MaterialApp(
    home: ChatBotPage(),
  ));
}

