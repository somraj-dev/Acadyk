import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SettingsProfileVisibilityScreen extends StatelessWidget {
  const SettingsProfileVisibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const tileTextColor = Colors.black;
    const headerColor = Color(0xFF191919);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.left_chevron, color: tileTextColor, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile visibility',
          style: TextStyle(
            color: headerColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: bgColor,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                _buildVisibilitySection(
                  title: 'Skills',
                  description: 'Spotlight your unique skills and catch the eye of recruiters looking for your exact talents!',
                  actionLabel: 'Add Skills',
                  icon: Icons.psychology_outlined,
                  color: Colors.blue.shade100,
                  iconColor: Colors.blue.shade800,
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Work Experience',
                  description: 'Narrate your professional journey and fast-track your way to new career heights!',
                  actionLabel: 'Add Work Experience',
                  icon: Icons.business_center_outlined,
                  color: Colors.orange.shade100,
                  iconColor: Colors.orange.shade800,
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Education',
                  description: 'Showcase your academic journey and open doors to your dream career opportunities!',
                  actionLabel: 'Add Education',
                  icon: Icons.school_outlined,
                  color: Colors.green.shade100,
                  iconColor: Colors.green.shade800,
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Responsibilities',
                  description: "Highlight the responsibilities you've mastered to demonstrate your leadership and expertise!",
                  actionLabel: 'Add Responsibility',
                  icon: Icons.groups_outlined,
                  color: Colors.purple.shade100,
                  iconColor: Colors.purple.shade800,
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Certificate',
                  description: "Flaunt your certifications and show recruiters that you're a step ahead in your field!",
                  actionLabel: 'Add Certificate',
                  icon: Icons.card_membership_outlined,
                  color: Colors.teal.shade100,
                  iconColor: Colors.teal.shade800,
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Projects',
                  description: 'Unveil your projects to the world and pave your path to professional greatness!',
                  actionLabel: 'Add Project',
                  icon: Icons.account_tree_outlined,
                  color: Colors.indigo.shade100,
                  iconColor: Colors.indigo.shade800,
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Achievements',
                  description: 'Broadcast your triumphs and make a remarkable impression on industry leaders!',
                  actionLabel: 'Add Achievement',
                  icon: Icons.emoji_events_outlined,
                  color: Colors.amber.shade100,
                  iconColor: Colors.amber.shade800,
                  onActionTap: () {},
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilitySection({
    required String title,
    required String description,
    required String actionLabel,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF737373),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onActionTap,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF0095F6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right illustration/icon container
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 36,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Color(0xFFEFEFEF),
    );
  }
}
