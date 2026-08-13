import 'package:flutter/material.dart';
import 'create_community_details_screen.dart';

class CreateCommunityTypeScreen extends StatefulWidget {
  final String selectedTopic;

  const CreateCommunityTypeScreen({super.key, required this.selectedTopic});

  @override
  State<CreateCommunityTypeScreen> createState() => _CreateCommunityTypeScreenState();
}

class _CreateCommunityTypeScreenState extends State<CreateCommunityTypeScreen> {
  String _selectedType = 'Public';
  bool _isMature = false;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0B141A);
    const textColor = Colors.white;
    const secondaryTextColor = Color(0xFF8696A0);
    const primaryColor = Color(0xFF2463D0); // Blue for active radio

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
            '2 of 3',
            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCommunityDetailsScreen(
                      selectedTopic: widget.selectedTopic,
                      communityType: _selectedType,
                      isMature: _isMature,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1955CC), // Distinct blue next button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                elevation: 0,
              ),
              child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
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
                'Select community type',
                style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: secondaryTextColor, fontSize: 15, height: 1.4),
                  children: [
                    TextSpan(text: 'Decide who can view and contribute in your community. Only public communities show up in search. '),
                    TextSpan(text: 'Important: ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB0BEC5))),
                    TextSpan(text: 'Once set, you will need to submit a request to change your community type.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildRadioTile('Public', 'Anyone can search for, view, and contribute', Icons.language, primaryColor),
              _buildRadioTile('Restricted', 'Anyone can view, but restrict who can contribute', Icons.visibility_outlined, primaryColor),
              _buildRadioTile('Private', 'Only approved members can view and contribute', Icons.lock_outline, primaryColor),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF2A3942), thickness: 1),
              const SizedBox(height: 8),
              _buildSwitchTile('Mature (18+)', 'Users must be over 18 to view and contribute', Icons.eighteen_up_rating_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioTile(String title, String subtitle, IconData icon, Color activeColor) {
    final bool isSelected = _selectedType == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : const Color(0xFF8696A0),
                  width: 2,
                ),
                color: Colors.transparent,
              ),
              child: isSelected 
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: _isMature,
            onChanged: (val) {
              setState(() {
                _isMature = val;
              });
            },
            activeColor: const Color(0xFFB0BEC5), // Light blueish/greyish
            activeTrackColor: const Color(0xFF37474F),
            inactiveThumbColor: const Color(0xFF8696A0),
            inactiveTrackColor: const Color(0xFF2A3942),
          ),
        ],
      ),
    );
  }
}
