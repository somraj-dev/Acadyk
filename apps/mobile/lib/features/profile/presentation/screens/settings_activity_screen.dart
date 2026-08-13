import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'settings_notifications_screen.dart';
import 'settings_privacy_screen.dart';
import 'settings_account_management_screen.dart';
import 'settings_profile_visibility_screen.dart';

class SettingsActivityScreen extends StatelessWidget {
  const SettingsActivityScreen({super.key});

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
          'Your account',
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                _buildPinterestTile('Account management', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsAccountManagementScreen()),
                  );
                }),
                _buildPinterestTile('Profile visibility', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsProfileVisibilityScreen()),
                  );
                }),
                _buildPinterestTile('Refine your recommendations'),
                _buildPinterestTile('Claimed external accounts'),
                _buildPinterestTile('Social permissions'),
                _buildPinterestTile('Notifications', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsNotificationsScreen()),
                  );
                }),
                _buildPinterestTile('Privacy and data', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsPrivacyScreen()),
                  );
                }),
                _buildPinterestTile('Reports and violations centre'),
                _buildPinterestTile('Labs'),

                // Login Section
                _buildSectionHeader('Login'),
                _buildPinterestTile('Add account'),
                _buildPinterestTile('Security'),
                _buildPinterestTile('Log out', isDanger: true),

                // Support Section
                _buildSectionHeader('Support'),
                _buildPinterestTile('Help Centre'),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPinterestTile(String title, {bool isDanger = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDanger ? const Color(0xFFED4956) : Colors.black,
              ),
            ),
            const Icon(
              CupertinoIcons.right_chevron,
              size: 16,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}
