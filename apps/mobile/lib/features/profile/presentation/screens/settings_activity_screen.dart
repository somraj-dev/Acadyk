import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'settings_notifications_screen.dart';
import 'settings_privacy_screen.dart';
import 'settings_account_management_screen.dart';
import 'settings_profile_visibility_screen.dart';
import 'settings_social_permissions_screen.dart';
import 'profile_pins_screen.dart';
import 'in_app_web_view_screen.dart';

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
                _buildSettingsTile('Account management', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsAccountManagementScreen()),
                  );
                }),
                _buildSettingsTile('Profile visibility', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsProfileVisibilityScreen()),
                  );
                }),
                _buildSettingsTile('Profile Pins', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProfilePinsScreen()),
                  );
                }),
                _buildSettingsTile('Social permissions', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsSocialPermissionsScreen()),
                  );
                }),
                _buildSettingsTile('Notifications', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsNotificationsScreen()),
                  );
                }),
                _buildSettingsTile('Privacy and data', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsPrivacyScreen()),
                  );
                }),
                _buildSettingsTile('Reports and violations centre'),

                // Login Section
                _buildSectionHeader('Login'),
                _buildSettingsTile('Security'),
                _buildSettingsTile('Log out', isDanger: true),

                // Support Section
                _buildSectionHeader('Support'),
                _buildSettingsTile('Help center', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InAppWebViewScreen(
                        title: 'Help center',
                        url: 'https://acadyk.quantaforze.com/help',
                      ),
                    ),
                  );
                }),
                _buildSettingsTile('Terms of service', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InAppWebViewScreen(
                        title: 'Terms of service',
                        url: 'https://acadyk.quantaforze.com/terms',
                      ),
                    ),
                  );
                }),
                _buildSettingsTile('Privacy policy', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InAppWebViewScreen(
                        title: 'Privacy policy',
                        url: 'https://acadyk.quantaforze.com/policy',
                      ),
                    ),
                  );
                }),
                
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

  Widget _buildSettingsTile(String title, {bool isDanger = false, VoidCallback? onTap}) {
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
