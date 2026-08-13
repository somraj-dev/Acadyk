import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AboutAccountScreen extends StatelessWidget {
  final Map<String, dynamic> accountData;

  const AboutAccountScreen({super.key, required this.accountData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Bright theme background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About this account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accountData['avatarColor'] ?? Colors.grey[200],
                image: accountData['avatarUrl'] != null
                    ? DecorationImage(
                        image: AssetImage(accountData['avatarUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: accountData['avatarUrl'] == null && accountData['avatarText'] != null
                  ? Text(
                      accountData['avatarText'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            // Handle / Name
            Text(
              accountData['name'] ?? 'Unknown User',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Informational Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(color: Color(0xFF737373), fontSize: 13, height: 1.4),
                  children: [
                    TextSpan(
                      text: "To help keep our community authentic, we're showing information about profiles on Instagram. ",
                    ),
                    TextSpan(
                      text: 'See why this information is important.',
                      style: TextStyle(color: Color(0xFF0095F6)), // Instagram blue link
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Date Joined
            _buildInfoRow(
              icon: CupertinoIcons.calendar,
              title: 'Date joined',
              subtitle: accountData['dateJoined'] ?? 'Unknown',
            ),
            const SizedBox(height: 24),
            // Location
            _buildInfoRow(
              icon: CupertinoIcons.location,
              title: 'Account based in',
              subtitle: accountData['location'] ?? 'Unknown',
            ),
            const SizedBox(height: 24),
            // Shared followers
            Row(
              children: [
                const Icon(CupertinoIcons.person_2, color: Colors.black, size: 28),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Accounts with shared followers',
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '${accountData['sharedFollowers'] ?? 0}',
                  style: const TextStyle(color: Color(0xFF737373), fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(CupertinoIcons.chevron_right, color: Color(0xFF737373), size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.black, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF737373), fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
