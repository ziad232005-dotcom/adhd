import 'package:flutter/material.dart';

class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends State<AskAIScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _messages = [];

  static const List<String> _suggestions = [
    'Homework is hard to start',
    'Morning routine tips',
    'My child loses focus',
    'Handling big emotions',
  ];

  // Keyword-based general guidance (no clinical advice).
  static const List<(List<String>, String)> _tips = [
    (
      ['homework', 'study', 'school', 'exam'],
      'Split homework into short blocks of 10–15 minutes with a small '
          'break between them. Start with the easiest task, keep the desk '
          'clear of distractions, and praise the effort after each block.',
    ),
    (
      ['morning', 'routine', 'wake', 'late'],
      'Use a short visual checklist (3–5 steps) and prepare clothes and '
          'the school bag the night before. Give one instruction at a '
          'time and celebrate each finished step.',
    ),
    (
      ['focus', 'attention', 'distract', 'concentrat'],
      'Try a focus timer with short sessions, remove screens and noise '
          'from the area, and give a quick movement break afterwards. '
          'Start with 10 minutes and increase slowly.',
    ),
    (
      ['angry', 'anger', 'emotion', 'tantrum', 'cry', 'upset', 'meltdown'],
      'Stay calm and name the feeling together ("You seem upset"). Offer '
          'a calm-down space and deep breaths, and talk about what '
          'happened only after your child feels settled.',
    ),
    (
      ['sleep', 'bed', 'night'],
      'Keep a fixed bedtime routine, dim lights and stop screens an hour '
          'before bed. A quiet activity such as reading helps the body '
          'wind down.',
    ),
    (
      ['reward', 'points', 'motivat'],
      'Set small, clear goals and reward effort quickly. Use the Rewards '
          'section to create point goals your child can see and reach.',
    ),
  ];

  static const String _fallback =
      'Thanks for sharing. Try breaking the activity into small, clear '
      'steps, giving one instruction at a time, and praising your '
      'child for their effort.';

  String _replyFor(String message) {
    final text = message.toLowerCase();

    for (final tip in _tips) {
      if (tip.$1.any(text.contains)) return '${tip.$2}\n\n$_disclaimer';
    }
    return '$_fallback\n\n$_disclaimer';
  }

  static const String _disclaimer =
      'This is general guidance, not a clinical assessment. Talk to your '
      'child’s specialist for personal advice.';

  void _send(String message) {
    final text = message.trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'sender': 'parent'});
      _messages.add({'text': _replyFor(text), 'sender': 'ai'});
    });

    _controller.clear();
  }

  void _sendMessage() => _send(_controller.text);

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
        title: const Text(
          'Ask AI',
          style: TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              tooltip: 'Clear chat',
              onPressed: () => setState(_messages.clear),
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: darkPurple,
              ),
            ),
        ],
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
                            Icons.chat_bubble_outline_rounded,
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
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final suggestion in _suggestions)
                                ActionChip(
                                  label: Text(suggestion),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFEFEAFB),
                                  ),
                                  labelStyle: const TextStyle(
                                    color: darkPurple,
                                    fontSize: 12,
                                  ),
                                  onPressed: () => _send(suggestion),
                                ),
                            ],
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
