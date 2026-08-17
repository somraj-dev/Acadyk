import 'package:flutter/material.dart';
import 'create_community_success_screen.dart';

class CreateCommunityDetailsScreen extends StatefulWidget {
  final String selectedTopic;
  final String communityType;
  final bool isMature;

  const CreateCommunityDetailsScreen({
    super.key,
    required this.selectedTopic,
    required this.communityType,
    required this.isMature,
  });

  @override
  State<CreateCommunityDetailsScreen> createState() => _CreateCommunityDetailsScreenState();
}

class _CreateCommunityDetailsScreenState extends State<CreateCommunityDetailsScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  int _nameLength = 0;
  int _descLength = 0;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() => _nameLength = _nameController.text.length);
    });
    _descController.addListener(() {
      setState(() => _descLength = _descController.text.length);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B141A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);
    final badgeBg = isDark ? const Color(0xFF1E2931) : const Color(0xFFF1F5F9);
    final badgeText = isDark ? Colors.white : const Color(0xFF0F172A);
    final inputBg = isDark ? const Color(0xFF1E2931) : const Color(0xFFF8FAFC);
    final inputBorderColor = isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0);
    final bool isNameValid = _nameLength > 0 && _nameLength <= 21;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '3 of 3',
            style: TextStyle(color: badgeText, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: isNameValid
                  ? () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateCommunitySuccessScreen(
                            communityName: _nameController.text.trim(),
                            description: _descController.text.trim(),
                            categoryTag: widget.selectedTopic,
                          ),
                        ),
                        (route) => route.isFirst,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isNameValid
                    ? const Color(0xFF09122C)
                    : (isDark ? const Color(0xFF1E2931) : const Color(0xFFF1F5F9)),
                disabledBackgroundColor: isDark ? const Color(0xFF1E2931) : const Color(0xFFF1F5F9),
                foregroundColor: isNameValid ? Colors.white : (isDark ? const Color(0xFF3B4A54) : const Color(0xFF94A3B8)),
                disabledForegroundColor: isDark ? const Color(0xFF3B4A54) : const Color(0xFF94A3B8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
              ),
              child: const Text('Create Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about your community',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A name and description help people understand what your community is all about',
                style: TextStyle(color: secondaryTextColor, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Community Name Field
              Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: inputBorderColor, width: 1.2),
                ),
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(color: textColor, fontSize: 16),
                  maxLength: 21,
                  decoration: InputDecoration(
                    label: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Community Name ',
                            style: TextStyle(color: secondaryTextColor, fontSize: 15),
                          ),
                          const TextSpan(text: '*', style: TextStyle(color: Color(0xFFEA580C), fontSize: 15)),
                        ],
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_nameLength/21',
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Description Field
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: inputBorderColor, width: 1.2),
                ),
                child: TextField(
                  controller: _descController,
                  style: TextStyle(color: textColor, fontSize: 15),
                  maxLength: 500,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    label: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Description ',
                            style: TextStyle(color: secondaryTextColor, fontSize: 15),
                          ),
                          const TextSpan(text: '*', style: TextStyle(color: Color(0xFFEA580C), fontSize: 15)),
                        ],
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_descLength/500',
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
