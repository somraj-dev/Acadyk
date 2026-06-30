import 'package:flutter/material.dart';
import 'story_view_screen.dart';

class UserStatusState {
  static String? emoji;
  static String? text;
  static bool isBusy = false;
  static String expiration = 'Never';
  static String visibleTo = 'Everyone';
  static bool hasStatus = false;

  static final ValueNotifier<bool> statusNotifier = ValueNotifier<bool>(false);

  static void setStatus({
    required String emojiVal,
    required String textVal,
    required bool busyVal,
    required String expirationVal,
    required String visibleToVal,
  }) {
    emoji = emojiVal;
    text = textVal;
    isBusy = busyVal;
    expiration = expirationVal;
    visibleTo = visibleToVal;
    hasStatus = textVal.trim().isNotEmpty;
    statusNotifier.value = !statusNotifier.value;
  }

  static void clear() {
    emoji = null;
    text = null;
    isBusy = false;
    expiration = 'Never';
    visibleTo = 'Everyone';
    hasStatus = false;
    statusNotifier.value = !statusNotifier.value;
  }
}

class EditStatusScreen extends StatefulWidget {
  const EditStatusScreen({super.key});

  @override
  State<EditStatusScreen> createState() => _EditStatusScreenState();
}

class _EditStatusScreenState extends State<EditStatusScreen> {
  late TextEditingController _statusController;
  late String _selectedEmoji;
  late bool _isBusy;
  late String _expiration;
  late String _visibleTo;

  final List<Map<String, String>> _presets = [
    {'emoji': '🌴', 'text': 'On vacation'},
    {'emoji': '🤕', 'text': 'Out sick'},
    {'emoji': '🏠', 'text': 'Working from home'},
    {'emoji': '🎯', 'text': 'Focusing'},
  ];

  final List<String> _emojiPool = [
    '🤕', '🌴', '🏠', '🎯', '😊', '🚀', '💬', '🎉',
    '💻', '💡', '🔥', '🔋', '☕', '📚', '🏃', '🍕'
  ];

  @override
  void initState() {
    super.initState();
    _selectedEmoji = UserStatusState.emoji ?? '🤕';
    _statusController = TextEditingController(text: UserStatusState.text ?? '');
    _isBusy = UserStatusState.isBusy;
    _expiration = UserStatusState.expiration;
    _visibleTo = UserStatusState.visibleTo;
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select an emoji',
                style: TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _emojiPool.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final e = _emojiPool[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = e;
                      });
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color lightBg = Colors.white;
    const Color cardBg = Color(0xFFF3F4F6);
    const Color borderCol = Color(0xFFE5E7EB);
    const Color textPrimary = Color(0xFF1F2937);
    const Color textMuted = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        title: const Text(
          'Edit status',
          style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.transparent),
            onPressed: null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  const Text(
                    "What's happening",
                    style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  // Input box with Emoji and TextField
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderCol),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showEmojiPicker,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: borderCol),
                            ),
                            child: Text(
                              _selectedEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _statusController,
                            onChanged: (val) => setState(() {}),
                            style: const TextStyle(color: textPrimary, fontSize: 15),
                            decoration: const InputDecoration(
                              hintText: "What's happening",
                              hintStyle: TextStyle(color: textMuted),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${80 - _statusController.text.length} characters remaining',
                      style: const TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Suggestion Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presets.map((p) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedEmoji = p['emoji']!;
                            _statusController.text = p['text']!;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p['emoji']!, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                p['text']!,
                                style: const TextStyle(color: textPrimary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Busy Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isBusy,
                        onChanged: (val) {
                          setState(() {
                            _isBusy = val ?? false;
                          });
                        },
                        activeColor: const Color(0xFF238636),
                        checkColor: Colors.white,
                        side: const BorderSide(color: borderCol),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Busy',
                                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'When others mention you, assign you, or request your review, Acadyk will let them know that you have limited availability.',
                                style: TextStyle(color: textMuted, fontSize: 12, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: borderCol),
                  const SizedBox(height: 16),

                  // Expiration Dropdown selector
                  const Text(
                    'Expiration',
                    style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownButton(
                    value: _expiration,
                    items: ['Never', '1 hour', '4 hours', 'Today', 'This week'],
                    onChanged: (val) {
                      if (val != null) setState(() => _expiration = val);
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your status will be cleared after the selected time.',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 24),

                  // Visible to Dropdown selector
                  const Text(
                    'Visible to',
                    style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownButton(
                    value: _visibleTo,
                    items: ['Everyone', 'My connections', 'Only me'],
                    onChanged: (val) {
                      if (val != null) setState(() => _visibleTo = val);
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Limit status visibility to a single organization.',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: borderCol)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      UserStatusState.clear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: const BorderSide(color: borderCol),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Clear status'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      UserStatusState.setStatus(
                        emojiVal: _selectedEmoji,
                        textVal: _statusController.text,
                        busyVal: _isBusy,
                        expirationVal: _expiration,
                        visibleToVal: _visibleTo,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF238636),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Set status'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    const Color cardBg = Color(0xFFF3F4F6);
    const Color borderCol = Color(0xFFE5E7EB);
    const Color textPrimary = Color(0xFF1F2937);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderCol),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: textPrimary),
          style: const TextStyle(color: textPrimary, fontSize: 14),
          onChanged: onChanged,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: textPrimary)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class StatusAvatar extends StatelessWidget {
  final String avatarAsset;
  final double radius;
  final bool isProfilePageAccountHolder;
  final bool enableTapToViewStory;
  final VoidCallback? onDefaultTap;

  const StatusAvatar({
    super.key,
    required this.avatarAsset,
    required this.radius,
    this.isProfilePageAccountHolder = false,
    this.enableTapToViewStory = true,
    this.onDefaultTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: UserStatusState.statusNotifier,
      builder: (context, statusValue, child) {
        final bool showRing = UserStatusState.hasStatus &&
            !isProfilePageAccountHolder &&
            avatarAsset.contains('somraj_avatar.jpg');

        Widget avatarWidget = CircleAvatar(
          radius: radius,
          backgroundImage: AssetImage(avatarAsset),
        );

        if (showRing) {
          avatarWidget = Container(
            padding: const EdgeInsets.all(2.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEF4444), // Solid red ring background
            ),
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Inner white border to stand out
              ),
              child: avatarWidget,
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            if (showRing && enableTapToViewStory) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StoryViewScreen()),
              );
            } else {
              if (onDefaultTap != null) {
                onDefaultTap!();
              }
            }
          },
          child: avatarWidget,
        );
      },
    );
  }
}
