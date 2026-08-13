import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'settings_edit_profile_screen.dart';

class SettingsAccountManagementScreen extends StatefulWidget {
  const SettingsAccountManagementScreen({super.key});

  @override
  State<SettingsAccountManagementScreen> createState() => _SettingsAccountManagementScreenState();
}

class _SettingsAccountManagementScreenState extends State<SettingsAccountManagementScreen> {
  bool _appSoundsEnabled = true;

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const tileTextColor = Colors.black;
    const descColor = Color(0xFF737373);
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
                const Text(
                  'Make changes to your personal information or account type',
                  style: TextStyle(
                    color: descColor,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: Your account
                _buildSectionHeader('Your account'),
                _buildPinterestTile(
                  title: 'Personal information',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsEditProfileScreen()),
                    );
                  },
                ),
                _buildEmailTile(
                  title: 'Email address',
                  email: 'iitainsomraj701@gmail.com',
                ),
                _buildPinterestTile(
                  title: 'Password',
                  trailingText: 'Change password',
                ),
                _buildPinterestTileWithDesc(
                  title: 'Convert to a business account',
                  description: 'Grow your business or brand with tools such as ads and analytics. Your content, profile and followers will stay the same.',
                ),
                _buildPinterestTile(
                  title: 'App theme',
                  trailingText: 'System default',
                ),
                _buildSoundsTile(),

                const SizedBox(height: 16),

                // Section 2: Deactivation and deletion
                _buildSectionHeader('Deactivation and deletion'),
                _buildPinterestTileWithDesc(
                  title: 'Deactivate account',
                  description: 'Deactivate to temporarily hide your Pins and profile',
                ),
                _buildPinterestTileWithDesc(
                  title: 'Delete your data and account',
                  description: 'Permanently delete your data and everything associated with your account',
                ),

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
      padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPinterestTile({required String title, String? trailingText, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF737373),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              CupertinoIcons.right_chevron,
              size: 15,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinterestTileWithDesc({required String title, required String description, VoidCallback? onTap}) {
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
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF737373),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              CupertinoIcons.right_chevron,
              size: 15,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTile({required String title, required String email}) {
    return InkWell(
      onTap: () {},
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
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F0D9), // Light green background
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, size: 14, color: Color(0xFF385723)),
                        SizedBox(width: 4),
                        Text(
                          'Confirmed',
                          style: TextStyle(
                            color: Color(0xFF385723),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF737373),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.right_chevron,
                  size: 15,
                  color: Colors.black45,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundsTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'App sounds',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Turn on app sounds from the Pinterest app',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF737373),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: _appSoundsEnabled,
            activeTrackColor: const Color(0xFF0F4C81),
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
