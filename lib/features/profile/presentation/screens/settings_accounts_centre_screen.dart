import 'package:flutter/material.dart';

class SettingsAccountsCentreScreen extends StatelessWidget {
  const SettingsAccountsCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFAFAFA);
    const tileTextColor = Color(0xFF262626);
    const subtextColor = Color(0xFF737373);
    const blueColor = Color(0xFF0095F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: tileTextColor, size: 26),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.all_inclusive, color: Color(0xFF262626), size: 22),
            SizedBox(width: 6),
            Text(
              'Acadyk',
              style: TextStyle(
                color: Color(0xFF262626),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48), // Spacer to balance leading X button
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
            color: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Accounts Centre',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: tileTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: subtextColor,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Manage your connected experiences and account settings across Acadyk technologies. ',
                      ),
                      TextSpan(
                        text: 'Learn more',
                        style: TextStyle(
                          color: blueColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Card 1: Profiles and personal details
                _buildCardWrapper(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: const AssetImage('assets/images/somraj_avatar.jpg'),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1.5),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: const Color(0xFF004B87),
                                child: const Icon(Icons.all_inclusive, size: 10, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      'Profiles and personal details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        color: tileTextColor,
                      ),
                    ),
                    subtitle: const Text(
                      '4 profiles',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: subtextColor,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: subtextColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Main Settings Group Card
                _buildCardWrapper(
                  child: Column(
                    children: [
                      _buildSettingRow(Icons.security, 'Password and security', tileTextColor, subtextColor),
                      _buildDivider(),
                      _buildSettingRow(Icons.share_outlined, 'Connected experiences', tileTextColor, subtextColor),
                      _buildDivider(),
                      _buildSettingRow(Icons.badge_outlined, 'Your information and permissions', tileTextColor, subtextColor),
                      _buildDivider(),
                      _buildSettingRow(Icons.campaign_outlined, 'Ad preferences', tileTextColor, subtextColor),
                      _buildDivider(),
                      _buildSettingRow(Icons.payment_outlined, 'Acadyk Pay', tileTextColor, subtextColor),
                      _buildDivider(),
                      _buildSettingRow(Icons.repeat_on_outlined, 'Subscriptions', tileTextColor, subtextColor),
                      _buildDivider(),
                      _buildSettingRow(Icons.photo_outlined, 'Your media gallery', tileTextColor, subtextColor),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card 3: Manage accounts
                _buildCardWrapper(
                  child: _buildSettingRow(Icons.manage_accounts_outlined, 'Manage accounts', tileTextColor, subtextColor),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSettingRow(IconData icon, String title, Color textCol, Color subtextCol) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: textCol),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: textCol,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: subtextCol),
          ],
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
