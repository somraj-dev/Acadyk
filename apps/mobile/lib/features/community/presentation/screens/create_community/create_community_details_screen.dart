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
    const bgColor = Color(0xFF0B141A);
    const textColor = Colors.white;
    const secondaryTextColor = Color(0xFF8696A0);
    final bool isNameValid = _nameLength > 0 && _nameLength <= 21;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: textColor),
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2931), // Slightly darker
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            '3 of 3',
            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
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
                          ),
                        ),
                        (route) => route.isFirst,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isNameValid ? const Color(0xFF1955CC) : const Color(0xFF1E2931),
                disabledBackgroundColor: const Color(0xFF1E2931),
                foregroundColor: isNameValid ? Colors.white : const Color(0xFF3B4A54),
                disabledForegroundColor: const Color(0xFF3B4A54),
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
              const Text(
                'Tell us about your community',
                style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'A name and description help people understand what your community is all about',
                style: TextStyle(color: secondaryTextColor, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 24),
              
              // Community Name Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2931), // Input background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLength: 21,
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(text: 'Community Name ', style: TextStyle(color: Color(0xFF8696A0), fontSize: 16)),
                          TextSpan(text: '*', style: TextStyle(color: Color(0xFFFF4500), fontSize: 16)),
                        ],
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    counterText: '', // We use custom counter below
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_nameLength/21',
                  style: const TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Description Field
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2931),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _descController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLength: 500,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(text: 'Description ', style: TextStyle(color: Color(0xFF8696A0), fontSize: 16)),
                          TextSpan(text: '*', style: TextStyle(color: Color(0xFFFF4500), fontSize: 16)),
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
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_descLength/500',
                  style: const TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
