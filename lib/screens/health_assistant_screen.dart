import 'package:flutter/material.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class HealthAssistantScreen extends StatefulWidget {
  const HealthAssistantScreen({super.key});

  @override
  State<HealthAssistantScreen> createState() => _HealthAssistantScreenState();
}

class _HealthAssistantScreenState extends State<HealthAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isTyping = false;

  final List<String> _suggestedQuestions = [
    'What is PMS?',
    'How to manage cramps?',
    'When should I see a doctor?',
    'What causes irregular cycles?',
    'How does stress affect my cycle?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Witchy Health Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.psychology, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.psychology, size: 32, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Hi! I\'m your Witchy Health Assistant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Ask me anything about your cycle, PMS, pregnancy, or reproductive health',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Try asking:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ..._suggestedQuestions.map((question) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: () => _sendQuestion(question),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(question),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 60 : 16,
          right: isUser ? 16 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.deepPurple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _sendMessage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  void _sendQuestion(String question) {
    setState(() {
      _messages.add(Message(text: question, isUser: true));
      _isTyping = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _isTyping = false;
        _messages.add(Message(text: _getAiResponse(question), isUser: false));
      });
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _controller.clear();
      _isTyping = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _isTyping = false;
        _messages.add(Message(text: _getAiResponse(text), isUser: false));
      });
    });
  }

  String _getAiResponse(String question) {
    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('pms') || lowerQuestion.contains('premenstrual')) {
      return 'PMS (Premenstrual Syndrome) refers to physical and emotional symptoms that occur one to two weeks before your period. Common symptoms include mood swings, bloating, breast tenderness, and fatigue. Managing PMS includes regular exercise, adequate sleep, reducing salt and caffeine intake, and stress management techniques.';
    }
    if (lowerQuestion.contains('cramp') || lowerQuestion.contains('pain')) {
      return 'To manage period cramps: apply a heating pad to your lower abdomen, take over-the-counter pain relievers like ibuprofen, gentle exercise like walking or yoga, and stay hydrated. If cramps are severe or interfering with daily activities, consult your healthcare provider.';
    }
    if (lowerQuestion.contains('doctor') || lowerQuestion.contains('see a doctor') || lowerQuestion.contains('warning')) {
      return 'You should see a doctor if: your periods are extremely heavy, you miss three or more periods, you have severe pain that doesn\'t respond to medication, your cycles are consistently shorter than 21 days or longer than 35 days, or you experience bleeding between periods.';
    }
    if (lowerQuestion.contains('irregular') || lowerQuestion.contains('cycle length')) {
      return 'Irregular cycles can be caused by stress, significant weight changes, polycystic ovary syndrome (PCOS), thyroid issues, or perimenopause. Tracking your cycles consistently for a few months can help identify patterns. If irregularities persist, consider consulting a healthcare provider.';
    }
    if (lowerQuestion.contains('stress')) {
      return 'Stress can significantly affect your menstrual cycle by disrupting the hormones that regulate ovulation. High cortisol levels can delay or prevent ovulation, leading to irregular or missed periods. Managing stress through meditation, exercise, adequate sleep, and relaxation techniques can help regulate your cycle.';
    }

    return 'Thank you for your question. Based on general health information: $question. For personalized medical advice, please consult with a qualified healthcare professional. Remember, Witchy provides educational information only and is not a diagnostic tool.';
  }
}
