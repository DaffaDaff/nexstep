import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openrouter_api/openrouter_api.dart';
import 'package:openrouter_api/src/models/llm_response.dart';
import 'package:openrouter_api/src/enums/message_role.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<LlmMessage> messages = [];
  LlmMessage _getMessage = LlmMessage.assistant('');
  late ChatService _chatService;
  late StreamSubscription<LlmResponse> _responseSubscription;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    messages.add(
      LlmMessage.system(
        'You are a helpful fitness coach, specifically track & field.',
      ),
    );
    messages.add(LlmMessage.assistant('Hello, How can I help you today?'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _responseSubscription
        .cancel(); // Cancel the stream subscription to avoid memory leaks
    super.dispose();
  }

  void _sendMessage() {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    // Add the user message to the list
    setState(() {
      messages.add(LlmMessage.user(LlmMessageContent.text(userMessage)));
    });

    _controller.clear();
    _focusNode.requestFocus(); // Focus the text field back after sending

    // Use the chat service to get the bot's response stream
    final responseStream = _chatService.getChatbotResponseStream(messages);

    _responseSubscription = responseStream.listen(
      (chunk) {
        debugPrint(chunk.choices.first.content);
        setState(() {
          _getMessage = LlmMessage.assistant(
            '${_getMessage.messageContent.text}${chunk.choices.first.content}',
          );
        });
      },
      onError: (error) {},
      onDone: () {
        messages.add(_getMessage);
        _getMessage = LlmMessage.assistant('');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Coach')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  final message = _getMessage;
                  return MessageBubble(message: message);
                } else {
                  final message = messages[index];
                  return MessageBubble(message: message);
                }
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
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatService {
  final client = OpenRouter.inference(
    key:
        "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", // Remember to securely manage your API key
  );

  Stream<LlmResponse> getChatbotResponseStream(List<LlmMessage> messages) {
    try {
      final Stream<LlmResponse> responseStream = client.streamCompletion(
        modelId: "qwen/qwen2.5-vl-32b-instruct",
        messages: messages,
      );

      return responseStream;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

class Message {
  final String content;
  final bool isBot;

  Message({required this.content, required this.isBot});
}

class MessageBubble extends StatelessWidget {
  final LlmMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.messageContent.text == '' ||
        message.role == MessageRole.system) {
      return Container();
    }

    return Align(
      alignment: message.role == MessageRole.assistant
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: message.role == MessageRole.assistant
              ? Colors.lightBlue
              : Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.messageContent.text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
