import 'package:flutter/material.dart';
import 'settings_notifications_screen.dart';
import 'settings_privacy_screen.dart';
import 'settings_accounts_centre_screen.dart';

class SettingsActivityScreen extends StatelessWidget {
  const SettingsActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFAFAFA);
    const tileTextColor = Color(0xFF262626);
    const subtextColor = Color(0xFF8E8E8E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tileTextColor, size: 26),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings and activity',
          style: TextStyle(
            color: tileTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: const Color(0xFFEFEFEF),
            height: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: bgColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Search Bar with identical Instagram Light mode layout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: subtextColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Search',
                          style: TextStyle(color: subtextColor, fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),

                // SECTION 1: Your Account
                _buildSectionHeader('Your account'),
                _buildSectionGroup([
                  _buildAccountsCentreTile(context),
                ]),

                // SECTION 2: How you use Acadyk
                _buildSectionHeader('How you use Acadyk'),
                _buildSectionGroup([
                  _buildSettingTile(Icons.bookmark_border, 'Saved', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.history, 'Archive', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.insights, 'Your activity', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(
                    Icons.notifications_none,
                    'Notifications',
                    tileTextColor,
                    subtextColor,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsNotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingTile(Icons.timer_outlined, 'Time management', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.tablet_android, 'Acadyk for tablets', tileTextColor, subtextColor),
                ]),

                // SECTION 3: Who can see your content
                _buildSectionHeader('Who can see your content'),
                _buildSectionGroup([
                  _buildSettingTile(Icons.lock_outline, 'Account privacy', tileTextColor, subtextColor, trailingText: 'Private'),
                  _buildDivider(),
                  _buildSettingTile(Icons.star_border, 'Close Friends', tileTextColor, subtextColor, trailingText: '15'),
                  _buildDivider(),
                  _buildSettingTile(Icons.grid_on_outlined, 'Crossposting', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.block_flipped, 'Blocked', tileTextColor, subtextColor, trailingText: '10'),
                  _buildDivider(),
                  _buildSettingTile(Icons.photo_camera_back_outlined, 'Story, live and location', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.people_outline, 'Activity in Friends feed', tileTextColor, subtextColor),
                ]),

                // SECTION 4: How others can interact with you
                _buildSectionHeader('How others can interact with you'),
                _buildSectionGroup([
                  _buildSettingTile(Icons.chat_bubble_outline, 'Messages and story replies', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.alternate_email, 'Tags and mentions', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.mode_comment_outlined, 'Comments', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.repeat, 'Sharing', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.face_retouching_natural, 'Avatar interactions', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.no_accounts_outlined, 'Restricted', tileTextColor, subtextColor, trailingText: '1'),
                  _buildDivider(),
                  _buildSettingTile(Icons.warning_amber_outlined, 'Limit interactions', tileTextColor, subtextColor, trailingText: 'Off'),
                  _buildDivider(),
                  _buildSettingTile(Icons.text_format_outlined, 'Hidden words', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.person_add_alt_1_outlined, 'Follow and invite friends', tileTextColor, subtextColor),
                ]),

                // SECTION 5: What you see
                _buildSectionHeader('What you see'),
                _buildSectionGroup([
                  _buildSettingTile(Icons.star_outline, 'Favourites', tileTextColor, subtextColor, trailingText: '0'),
                  _buildDivider(),
                  _buildSettingTile(Icons.volume_off_outlined, 'Muted accounts', tileTextColor, subtextColor, trailingText: '0'),
                  _buildDivider(),
                  _buildSettingTile(Icons.play_circle_outline, 'Content preferences', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.favorite_border, 'Like and share counts', tileTextColor, subtextColor),
                ]),

                // SECTION 6: Your app and media
                _buildSectionHeader('Your app and media'),
                _buildSectionGroup([
                  _buildSettingTile(Icons.phone_android_outlined, 'Device permissions', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.download_for_offline_outlined, 'Archiving and downloading', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.accessibility_new_outlined, 'Accessibility', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.translate_outlined, 'Language and translations', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.bar_chart_outlined, 'Data usage and media quality', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.web_outlined, 'App website permissions', tileTextColor, subtextColor),
                ]),

                // SECTION 7: More info and support
                _buildSectionHeader('More info and support'),
                _buildSectionGroup([
                  _buildSettingTile(Icons.help_outline, 'Help', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.psychology_outlined, 'Acadyk AI support assistant', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(
                    Icons.security_outlined,
                    'Privacy Centre',
                    tileTextColor,
                    subtextColor,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPrivacyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingTile(Icons.info_outline, 'Account Status', tileTextColor, subtextColor),
                  _buildDivider(),
                  _buildSettingTile(Icons.contact_support_outlined, 'About', tileTextColor, subtextColor),
                ]),

                // SECTION 9: Login / Logout
                const SizedBox(height: 20),
                _buildSectionGroup([
                  _buildLoginButton('Add account', isDanger: false),
                  _buildDivider(),
                  _buildLoginButton('Log out', isDanger: true),
                ]),
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
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 18.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8E8E8E),
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (title == 'Your account')
            Row(
              children: const [
                Icon(Icons.all_inclusive, size: 14, color: Color(0xFF8E8E8E)),
                SizedBox(width: 4),
                Text(
                  'Acadyk',
                  style: TextStyle(
                    color: Color(0xFF8E8E8E),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionGroup(List<Widget> children) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEFEFEF), width: 0.5),
          bottom: BorderSide(color: Color(0xFFEFEFEF), width: 0.5),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildAccountsCentreTile(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SettingsAccountsCentreScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.account_circle_outlined, size: 26, color: Color(0xFF262626)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Accounts Centre',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF262626),
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: Color(0xFFC7C7CC)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Password, security, personal details, connected experiences, ad preferences',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E8E),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    Color textCol,
    Color subtextCol, {
    String? trailingText,
    bool hasBlueDot = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF262626)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: textCol,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 14,
                  color: subtextCol,
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (hasBlueDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF0095F6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(String text, {required bool isDanger}) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Text(
          text,
          style: TextStyle(
            color: isDanger ? const Color(0xFFED4956) : const Color(0xFF0095F6),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 54.0),
      child: Container(
        height: 0.5,
        color: const Color(0xFFEFEFEF),
      ),
    );
  }
}
