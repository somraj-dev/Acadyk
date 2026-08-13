import 'package:flutter/material.dart';

class SettingsNotificationsScreen extends StatelessWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tileTextColor = Color(0xFF262626);
    const subtextColor = Color(0xFF737373);

    final List<String> notificationItems = [
      'Searching for a job',
      'Hiring someone',
      'Connecting with others',
      'Network catch-up updates',
      'Posting and commenting',
      'Messaging',
      'Groups',
      'Pages',
      'Attending events',
      'News and reports',
      'Updating your profile',
      'Verifications',
      'Games',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tileTextColor, size: 26),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: tileTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: tileTextColor, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
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
            color: Colors.white,
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
                  child: Text(
                    'Notifications you receive',
                    style: TextStyle(
                      color: tileTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ...notificationItems.expand((item) => [
                  _buildNotificationTile(item, tileTextColor, subtextColor),
                  _buildDivider(),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(String title, Color textCol, Color iconCol) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w400,
                  color: textCol,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, size: 18, color: iconCol),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: const Color(0xFFEFEFEF),
    );
  }
}
