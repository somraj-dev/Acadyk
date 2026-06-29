import 'package:flutter/material.dart';

class SettingsPrivacyScreen extends StatelessWidget {
  const SettingsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tileTextColor = Color(0xFF262626);
    const subtextColor = Color(0xFF737373);
    const separatorColor = Color(0xFFFAFAFA);

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
          'Data privacy',
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
                // SECTION 1: How Acadyk uses your data
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
                  child: Text(
                    'How Acadyk uses your data',
                    style: TextStyle(
                      color: tileTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _buildPrivacyTile('Manage data permissions', tileTextColor, subtextColor),
                _buildDivider(),
                _buildPrivacyTile('Download your data', tileTextColor, subtextColor),
                _buildDivider(),
                _buildPrivacyTile('Clear search history', tileTextColor, subtextColor),
                _buildDivider(),
                _buildPrivacyTile('Personal demographic info', tileTextColor, subtextColor),
                _buildDivider(),
                _buildPrivacyTile('Policy and academic research', tileTextColor, subtextColor, trailingText: 'On'),
                _buildDivider(),
                _buildPrivacyTile('Data for Generative AI Improvement', tileTextColor, subtextColor, trailingText: 'On'),
                
                // Section separator
                _buildSeparator(separatorColor),

                // SECTION 2: Who can reach you
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
                  child: Text(
                    'Who can reach you',
                    style: TextStyle(
                      color: tileTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _buildPrivacyTile('Invitations to connect', tileTextColor, subtextColor),
                _buildDivider(),
                _buildPrivacyTile('Invitations from your network', tileTextColor, subtextColor),
                _buildDivider(),
                _buildPrivacyTile('Messages you receive', tileTextColor, subtextColor),
                _buildDivider(),
                _buildPrivacyTile('Research invitations', tileTextColor, subtextColor, trailingText: 'On'),
                _buildDivider(),
                _buildPrivacyTile('Acadyk marketing emails and promotions', tileTextColor, subtextColor),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyTile(
    String title,
    Color textCol,
    Color subtextCol, {
    String? trailingText,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
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
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 14,
                  color: subtextCol,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.arrow_forward, size: 18, color: subtextCol),
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

  Widget _buildSeparator(Color color) {
    return Container(
      height: 10,
      color: const Color(0xFFF3F2EF),
    );
  }
}
