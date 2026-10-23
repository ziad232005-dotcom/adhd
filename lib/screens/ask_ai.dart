import 'package:flutter/material.dart';

class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends State<AskAIScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _messages = [];

  void _sendMessage() {
    final message = _controller.text.trim();

    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'text': message,
        'sender': 'parent',
      });
      _messages.add({
        'text':
            'Thanks for sharing. Try breaking the activity into small, '
            'clear steps, giving one instruction at a time, and praising '
            'your child for their effort. This is general guidance, not '
            'a clinical assessment.',
        'sender': 'ai',
      });
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7566D9);
    const darkPurple = Color(0xFF30285E);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkPurple,
          ),
        ),

      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 58,
                            color: purple,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'How can we support you?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: darkPurple,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ask for general strategies for routines, '
                            'focus, and positive behavior.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isParent = message['sender'] == 'parent';

                      return Align(
                        alignment: isParent
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.sizeOf(context).width * 0.78,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isParent ? purple : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            message['text']!,
                            style: TextStyle(
                              color: isParent ? Colors.white : darkPurple,
                              height: 1.45,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFEFEAFB)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        filled: true,
                        fillColor: const Color(0xFFFAF8FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
