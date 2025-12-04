import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openrouter_api/openrouter_api.dart';
import 'package:openrouter_api/src/models/llm_response.dart';
import 'package:openrouter_api/src/enums/message_role.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatbotPage extends StatefulWidget {
  final String workoutId;

  const ChatbotPage({super.key, required this.workoutId});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();

  String chatId = '';
  final List<LlmMessage> messages = [];
  LlmMessage _getMessage = LlmMessage.assistant('');
  late ChatService _chatService;
  late StreamSubscription<LlmResponse> _responseSubscription;
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _fetchChatData();
  }

  // Function to fetch workout data from Supabase
  Future<void> _fetchChatData() async {
    final response = await Supabase.instance.client
        .from('chat_sessions')
        .select()
        .eq('workout_id', widget.workoutId);

    if (response.isNotEmpty) {
      // Assuming the first row contains the user's current workout data
      setState(() {
        chatId = response.single['id'];

        List<LlmMessage> fetchedMessages = decodeData(
          response.single['messages'],
        );
        messages.clear(); // Clear previous messages
        messages.addAll(fetchedMessages);
      });
    } else {
      _insertNewChatSession();
      setState(() {
        messages.add(
          LlmMessage.system(
            'You are a helpful fitness coach, specifically track & field. Reject anything that is not related to said topic.',
          ),
        );
        messages.add(
          LlmMessage.assistant(
            'Hello, I am your personal AI couch. How can I help you today?',
          ),
        );
        _updateChatSession(messages);
        _isLoading = false;
      });
    }
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
        setState(() {
          messages.add(_getMessage);
          _updateChatSession(messages);

          _getMessage = LlmMessage.assistant('');
        });
      },
    );
  }

  Future<void> _insertNewChatSession() async {
    final newSession = {
      'workout_id': widget.workoutId,
      'messages': {'data': []},
    };

    final PostgrestList response = await Supabase.instance.client
        .from('chat_sessions')
        .insert(newSession)
        .select();

    if (response.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
    } else {
      // Handle error
      // debugPrint(
      //   'Error inserting new chat session: ${response.error?.message}',
      // );
    }
  }

  Future<void> _updateChatSession(List<LlmMessage> updatedMessages) async {
    final Map<String, dynamic> updatedSession = encodeData(updatedMessages);

    final response = await Supabase.instance.client
        .from('chat_sessions')
        .update({'messages': updatedSession})
        .eq('workout_id', widget.workoutId)
        .select();

    if (response.isNotEmpty) {
      debugPrint('Chat session updated successfully.');
    } else {
      debugPrint(
        'Error updating chat session: ${response.toList().toString()}',
      );
    }
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
        "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",
  );

  Stream<LlmResponse> getChatbotResponseStream(List<LlmMessage> messages) {
    try {
      final Stream<LlmResponse> responseStream = client.streamCompletion(
        modelId: "openai/gpt-3.5-turbo",
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

Map<String, dynamic> encodeData(List<LlmMessage> data) {
  List<Map<String, dynamic>> messages = data.map((message) {
    return {
      'role': message.role.toString().split('.').last,
      'content': message.messageContent.text,
    };
  }).toList();

  return {'data': messages};
}

List<LlmMessage> decodeData(Map<String, dynamic> data) {
  List<LlmMessage> messages = data['data'].map<LlmMessage>((message) {
    // Extract role and content from the map
    String roleStr = message['role'];
    String content = message['content'];

    switch (roleStr) {
      case 'user':
        return LlmMessage.user(LlmMessageContent.text(content));

      case 'assistant':
        return LlmMessage.assistant(content);

      case 'system':
        return LlmMessage.system(content);
      default:
        return LlmMessage.user(LlmMessageContent.text(content));
    }
  }).toList();

  return messages;
}
