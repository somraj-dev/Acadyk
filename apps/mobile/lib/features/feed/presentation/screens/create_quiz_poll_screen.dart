import 'package:flutter/material.dart';

class CreateQuizPollScreen extends StatefulWidget {
  const CreateQuizPollScreen({super.key});

  @override
  State<CreateQuizPollScreen> createState() => _CreateQuizPollScreenState();
}

class _CreateQuizPollScreenState extends State<CreateQuizPollScreen> {
  final TextEditingController _questionController = TextEditingController();
  int _selectedPollType = 1; // 0: Select list, 1: Emojis, 2: Numerical
  int _selectedDurationTab = 1; // 0: Set end date, 1: Set length

  // Options list
  final List<Map<String, String>> _options = [
    {'emoji': '🥺', 'text': "I'm touched"},
    {'emoji': '😊', 'text': ''},
  ];

  // Dropdown variables
  String _selectedDays = '1 days';
  String _selectedHours = '0 hours';
  String _selectedMinutes = '0 minutes';

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _options.add({'emoji': '💡', 'text': ''});
    });
  }

  void _removeOption(int index) {
    if (_options.length > 1) {
      setState(() {
        _options.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF111827);
    const Color textSecondary = Color(0xFF6B7280);
    const Color borderCol = Color(0xFFE5E7EB);
    const Color lightBg = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(), // No leading arrow as per mock (has close button on right)
        titleSpacing: 16,
        title: const Text(
          'Question & answers',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: textColor, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 1. Ask a question
                  const Text(
                    'Ask a question',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol, width: 1.2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _questionController,
                      style: const TextStyle(color: textColor, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: "Type your question...",
                        hintStyle: TextStyle(color: textSecondary),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Poll type
                  const Text(
                    'Poll type',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        _buildPollTypeTab(0, Icons.list, 'Select list'),
                        _buildPollTypeTab(1, Icons.emoji_emotions_outlined, 'Emojis'),
                        _buildPollTypeTab(2, Icons.looks_one_outlined, 'Numerical'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Options Gray Box
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Options',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // List of dynamic options
                        ...List.generate(_options.length, (index) {
                          final opt = _options[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                const Icon(Icons.drag_indicator, color: textSecondary, size: 20),
                                const SizedBox(width: 8),
                                // Emoji container box
                                GestureDetector(
                                  onTap: () {
                                    // Cycle emoji for fun prototype effect
                                    final emojis = ['🥺', '😊', '💡', '🔥', '🎉', '💬', '👀'];
                                    final currentIdx = emojis.indexOf(opt['emoji']!);
                                    final nextIdx = (currentIdx + 1) % emojis.length;
                                    setState(() {
                                      opt['emoji'] = emojis[nextIdx];
                                    });
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: borderCol),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      opt['emoji']!,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Option Text Input field
                                Expanded(
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: borderCol),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    alignment: Alignment.centerLeft,
                                    child: TextField(
                                      onChanged: (val) {
                                        opt['text'] = val;
                                      },
                                      controller: TextEditingController(text: opt['text'])
                                        ..selection = TextSelection.fromPosition(
                                          TextPosition(offset: opt['text']!.length),
                                        ),
                                      style: const TextStyle(color: textColor, fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: index == 0 ? "Option text" : "Type optional description...",
                                        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Delete icon
                                IconButton(
                                  icon: const Icon(Icons.close, color: textSecondary, size: 20),
                                  onPressed: () => _removeOption(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        // Add option button
                        GestureDetector(
                          onTap: _addOption,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: textColor, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Add option',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Duration
                  const Text(
                    'Duration',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Duration segmented selector
                  Container(
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        _buildDurationTab(0, 'Set end date'),
                        _buildDurationTab(1, 'Set length'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dropdown selectors row
                  Row(
                    children: [
                      Expanded(child: _buildDropdownSelector('days', _selectedDays, ['1 days', '2 days', '3 days', '5 days'], (val) => setState(() => _selectedDays = val!))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildDropdownSelector('hours', _selectedHours, ['0 hours', '1 hours', '2 hours', '6 hours', '12 hours'], (val) => setState(() => _selectedHours = val!))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildDropdownSelector('minutes', _selectedMinutes, ['0 minutes', '15 minutes', '30 minutes', '45 minutes'], (val) => setState(() => _selectedMinutes = val!))),
                    ],
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),

            // Bottom action row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: borderCol)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_questionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please ask a question first.')),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quiz / Poll created successfully! 🎉'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1F22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollTypeTab(int index, IconData icon, String text) {
    final bool isSelected = _selectedPollType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPollType = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationTab(int index, String text) {
    final bool isSelected = _selectedDurationTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDurationTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSelector(
    String label,
    String currentValue,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280), size: 20),
          style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
          onChanged: onChanged,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}
