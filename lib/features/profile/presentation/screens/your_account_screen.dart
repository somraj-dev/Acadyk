import 'package:flutter/material.dart';
import 'package:acadyk/common/services/supabase_service.dart';
import 'settings_account_management_screen.dart';
import 'settings_profile_visibility_screen.dart';
import 'settings_accounts_centre_screen.dart';
import 'app_permissions_screen.dart';
import 'settings_notifications_screen.dart';
import 'settings_privacy_screen.dart';

class YourAccountScreen extends StatelessWidget {
  const YourAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const dangerColor = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: titleColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Your account',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                // 1. Account management
                _buildSettingsItem(
                  context,
                  title: 'Account management',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsAccountManagementScreen()),
                    );
                  },
                ),

                // 2. Profile visibility
                _buildSettingsItem(
                  context,
                  title: 'Profile visibility',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsProfileVisibilityScreen()),
                    );
                  },
                ),

                // 3. Refine your recommendations
                _buildSettingsItem(
                  context,
                  title: 'Refine your recommendations',
                  onTap: () => _showSnackBar(context, 'Refine recommendations opened!'),
                ),

                // 4. Claimed external accounts
                _buildSettingsItem(
                  context,
                  title: 'Claimed external accounts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsAccountsCentreScreen()),
                    );
                  },
                ),

                // 5. Social permissions
                _buildSettingsItem(
                  context,
                  title: 'Social permissions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppPermissionsScreen()),
                    );
                  },
                ),

                // 6. Notifications
                _buildSettingsItem(
                  context,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsNotificationsScreen()),
                    );
                  },
                ),

                // 7. Privacy and data
                _buildSettingsItem(
                  context,
                  title: 'Privacy and data',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPrivacyScreen()),
                    );
                  },
                ),

                // 8. Reports and violations centre
                _buildSettingsItem(
                  context,
                  title: 'Reports and violations centre',
                  onTap: () => _showSnackBar(context, 'Reports and violations centre opened!'),
                ),

                // 9. Labs
                _buildSettingsItem(
                  context,
                  title: 'Labs',
                  onTap: () => _showSnackBar(context, 'Acadyk Experimental Labs!'),
                ),

                const SizedBox(height: 24),

                // Section Header: Login
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ),

                // 10. Add account
                _buildSettingsItem(
                  context,
                  title: 'Add account',
                  onTap: () => _showSnackBar(context, 'Add another account option selected'),
                ),

                // 11. Security
                _buildSettingsItem(
                  context,
                  title: 'Security',
                  onTap: () => _showSnackBar(context, 'Security & Authentication settings'),
                ),

                // 12. Log out
                _buildSettingsItem(
                  context,
                  title: 'Log out',
                  textColor: dangerColor,
                  onTap: () => _showLogoutDialog(context),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF0F172A),
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 22,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5),
        ),
        behavior: SnackBarBehavior.floating,
        width: 280,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of your Acadyk account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await SupabaseService.client.auth.signOut();
              } catch (_) {}
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
