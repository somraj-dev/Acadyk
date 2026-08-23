import 'package:flutter/material.dart';
import '../../../../../common/widgets/acadyk_toggle_switch.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B141A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);
    final badgeBg = isDark ? const Color(0xFF1E2931) : const Color(0xFFF1F5F9);
    final badgeText = isDark ? Colors.white : const Color(0xFF0F172A);
    final activeColor = const Color(0xFF09122C);

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
            '2 of 3',
            style: TextStyle(color: badgeText, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
                backgroundColor: const Color(0xFF09122C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                elevation: 0,
              ),
              child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                'Select community type',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: secondaryTextColor, fontSize: 15, height: 1.4),
                  children: [
                    const TextSpan(text: 'Decide who can view and contribute in your community. Only public communities show up in search. '),
                    TextSpan(
                      text: 'Important: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFB0BEC5) : const Color(0xFF0F172A),
                      ),
                    ),
                    const TextSpan(text: 'Once set, you will need to submit a request to change your community type.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildRadioTile('Public', 'Anyone can search for, view, and contribute', Icons.language, activeColor, isDark),
              _buildRadioTile('Restricted', 'Anyone can view, but restrict who can contribute', Icons.visibility_outlined, activeColor, isDark),
              _buildRadioTile('Private', 'Only approved members can view and contribute', Icons.lock_outline, activeColor, isDark),
              const SizedBox(height: 16),
              Divider(color: isDark ? const Color(0xFF2A3942) : const Color(0xFFE2E8F0), thickness: 1),
              const SizedBox(height: 8),
              _buildSwitchTile('Mature (18+)', 'Users must be over 18 to view and contribute', Icons.eighteen_up_rating_outlined, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioTile(String title, String subtitle, IconData icon, Color activeColor, bool isDark) {
    final bool isSelected = _selectedType == title;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = title;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF09122C)) : secondaryTextColor, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 13.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 22,
              height: 22,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF09122C))
                      : (isDark ? const Color(0xFF8696A0) : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
                color: Colors.transparent,
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF09122C),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF8696A0) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: secondaryTextColor, size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AcadykToggleSwitch(
            value: _isMature,
            activeColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F4C81),
            onChanged: (val) {
              setState(() {
                _isMature = val;
              });
            },
          ),
        ],
      ),
    );
  }
}
