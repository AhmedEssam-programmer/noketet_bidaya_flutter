import 'package:flutter/material.dart';
import '../../services/chat_ai_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  static const routeName = 'Chat';
  static const routePath = '/chat';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();

  List<String> messages = [];
  bool _sending = false;
  late stt.SpeechToText _speech;
 bool _isListening = false;
 @override
 void initState() {
  super.initState();
  _speech = stt.SpeechToText();
}
Future<void> _toggleListening() async {
  if (!_isListening) {
    bool available = await _speech.initialize();

    if (available) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        },
      );
    }
  } else {
    setState(() {
      _isListening = false;
    });

    _speech.stop();
  }
}
  Future<void> sendMessage(String text) async {
    if (_sending) return;
    final safeText = text.trim();
    if (safeText.isEmpty) return;
    if (safeText.length > 1000) {
      setState(() {
        messages.add("Bot: الرسالة طويلة جداً");
      });
      return;
    }

    setState(() {
      messages.add("You: $safeText");
      _sending = true;
    });

    controller.clear();
    try {
      final reply = await chatAiService.sendMessage(safeText);
      if (!mounted) return;
      setState(() {
        messages.add("Bot: $reply");
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.add("Bot: ${e.toString()}");
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Chatbot")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'اكتب رسالة واضغط إرسال',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return ListTile(title: Text(messages[index]));
                      },
                    ),
            ),
            Material(
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomInset),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "اكتب رسالة",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                    icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : null,
                   ),
                    onPressed: _toggleListening,
                    ),

                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sending
                          ? null
                          : () {
                              final t = controller.text.trim();
                              if (t.isEmpty) return;
                              sendMessage(t);
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
