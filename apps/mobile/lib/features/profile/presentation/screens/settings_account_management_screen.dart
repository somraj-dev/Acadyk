import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../common/widgets/acadyk_toggle_switch.dart';
import '../../../../common/providers/theme_provider.dart';
import '../../../../common/providers/auth_provider.dart';
import 'settings_edit_profile_screen.dart';
import 'appearance_screen.dart';
import 'settings_deactivate_account_screen.dart';
import 'settings_delete_account_screen.dart';
import 'settings_change_password_screen.dart';

class SettingsAccountManagementScreen extends StatefulWidget {
  const SettingsAccountManagementScreen({super.key});

  @override
  State<SettingsAccountManagementScreen> createState() => _SettingsAccountManagementScreenState();
}

class _SettingsAccountManagementScreenState extends State<SettingsAccountManagementScreen> {
  bool _appSoundsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1117) : Colors.white;
    final tileTextColor = isDark ? const Color(0xFFF3F4F6) : Colors.black;
    final descColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF737373);
    final headerColor = isDark ? Colors.white : const Color(0xFF191919);
    final chevronColor = isDark ? const Color(0xFF6E7681) : Colors.black45;

    ThemeProvider? themeProvider;
    try {
      themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    } catch (_) {
      themeProvider = null;
    }

    String themeModeLabel = 'System default';
    if (themeProvider != null) {
      if (themeProvider.themeMode == ThemeMode.light) {
        themeModeLabel = 'Light';
      } else if (themeProvider.themeMode == ThemeMode.dark) {
        themeModeLabel = 'Dark';
      }
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rawEmail = authProvider.currentProfile?.email ?? authProvider.currentUser?.email ?? 'developer@mitsgwl.ac.in';
    final currentEmail = rawEmail.endsWith('@acadyk.com')
        ? '${rawEmail.split('@').first}@mitsgwl.ac.in'
        : (rawEmail.isNotEmpty ? rawEmail : 'developer@mitsgwl.ac.in');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: tileTextColor, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Account management',
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                // Top subtitle description
                Text(
                  'Make changes to your personal information or account type',
                  style: TextStyle(
                    color: descColor,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: Your account
                _buildSectionHeader('Your account', headerColor),
                _buildTile(
                  title: 'Personal information',
                  textColor: tileTextColor,
                  chevronColor: chevronColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsEditProfileScreen()),
                    );
                  },
                ),
                _buildEmailTile(
                  title: 'Email address',
                  email: currentEmail,
                  textColor: tileTextColor,
                  descColor: descColor,
                  chevronColor: chevronColor,
                ),
                _buildTile(
                  title: 'Password',
                  trailingText: 'Change password',
                  textColor: tileTextColor,
                  descColor: descColor,
                  chevronColor: chevronColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsChangePasswordScreen()),
                    );
                  },
                ),
                _buildTile(
                  title: 'App theme',
                  trailingText: themeModeLabel,
                  textColor: tileTextColor,
                  descColor: descColor,
                  chevronColor: chevronColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AppearanceScreen()),
                    );
                  },
                ),
                _buildSoundsTile(tileTextColor, descColor),

                const SizedBox(height: 16),

                // Section 2: Deactivation and deletion
                _buildSectionHeader('Deactivation and deletion', headerColor),
                _buildTileWithDesc(
                  title: 'Deactivate account',
                  description: 'Deactivate to temporarily hide your posts and profile',
                  textColor: tileTextColor,
                  descColor: descColor,
                  chevronColor: chevronColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsDeactivateAccountScreen()),
                    );
                  },
                ),
                _buildTileWithDesc(
                  title: 'Delete your data and account',
                  description: 'Permanently delete your data and everything associated with your account',
                  textColor: tileTextColor,
                  descColor: descColor,
                  chevronColor: chevronColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsDeleteAccountScreen()),
                    );
                  },
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color headerColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: headerColor,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    String? trailingText,
    required Color textColor,
    Color? descColor,
    required Color chevronColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 14,
                  color: descColor ?? const Color(0xFF737373),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              CupertinoIcons.right_chevron,
              size: 15,
              color: chevronColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileWithDesc({
    required String title,
    required String description,
    required Color textColor,
    required Color descColor,
    required Color chevronColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: descColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              CupertinoIcons.right_chevron,
              size: 15,
              color: chevronColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTile({
    required String title,
    required String email,
    required Color textColor,
    required Color descColor,
    required Color chevronColor,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: descColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.right_chevron,
              size: 15,
              color: chevronColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundsTile(Color textColor, Color descColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App sounds',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Turn on app sounds from the Acadyk app',
                  style: TextStyle(
                    fontSize: 13,
                    color: descColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AcadykToggleSwitch(
            value: _appSoundsEnabled,
            activeColor: const Color(0xFF0F4C81),
            onChanged: (val) {
              setState(() {
                _appSoundsEnabled = val;
              });
            },
          ),
        ],
      ),
    );
  }
}
