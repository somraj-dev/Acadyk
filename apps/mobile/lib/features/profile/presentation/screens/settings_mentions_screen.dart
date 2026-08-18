import 'package:flutter/material.dart';

class SettingsMentionsScreen extends StatefulWidget {
  final String initialSelection;

  const SettingsMentionsScreen({
    super.key,
    this.initialSelection = 'Anyone on Acadyk',
  });

  @override
  State<SettingsMentionsScreen> createState() => _SettingsMentionsScreenState();
}

class _SettingsMentionsScreenState extends State<SettingsMentionsScreen> {
  late String _selectedOption;

  final List<String> _options = [
    'Anyone on Acadyk',
    'Only people you follow',
    'Turn off',
  ];

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const selectedBlue = Color(0xFF355CEC);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: titleColor, size: 20),
          onPressed: () => Navigator.of(context).pop(_selectedOption),
        ),
        title: const Text(
          '@Mentions',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Choose who can mention you in a comment',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.4,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 28),
                ..._options.map((option) {
                  final isSelected = _selectedOption == option;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedOption = option;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Row(
                        children: [
                          _buildCustomRadio(isSelected, selectedBlue),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: titleColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRadio(bool isSelected, Color activeColor) {
    if (isSelected) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: activeColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF94A3B8),
          width: 1.8,
        ),
      ),
    );
  }
}
