import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/profile_manager.dart';

class AboutAccountScreen extends StatelessWidget {
  final Map<String, dynamic> accountData;

  const AboutAccountScreen({super.key, required this.accountData});

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const textColor = Color(0xFF1E293B);
    const subtextColor = Color(0xFF64748B);

    final String name = (accountData['name'] ?? 'User Profile').toString();
    final String email = (accountData['email'] ?? '').toString();
    final String username = (accountData['username'] ?? '').toString();

    // Check if this account is an official institutional / organization handle
    final bool isOfficial = accountData['isOfficial'] == true ||
        accountData['role'] == 'official' ||
        accountData['accountType'] == 'official' ||
        (email.toLowerCase().endsWith('@mits.ac.in') && !email.toLowerCase().contains('student')) ||
        name.toLowerCase().contains('mits gwalior') ||
        name.toLowerCase().contains('madhav institute') ||
        name.toLowerCase().contains('y combinator');

    // Dynamic data attributes
    final String estYear = accountData['estYear']?.toString() ??
        accountData['dateJoined']?.toString() ??
        (name.toLowerCase().contains('mits') ? '1957' : '2005');

    final String academicSession = accountData['academicSession']?.toString() ??
        accountData['session']?.toString() ??
        (ProfileManager.academicSession.isNotEmpty ? ProfileManager.academicSession : '2022 – 2026');

    final String branch = accountData['branch']?.toString() ??
        (ProfileManager.branch.isNotEmpty ? ProfileManager.branch : 'Computer Science & Engineering');

    final String department = accountData['department']?.toString() ??
        (isOfficial
            ? (accountData['department']?.toString() ?? 'Madhav Institute of Technology & Science, Gwalior')
            : (ProfileManager.degree.isNotEmpty ? ProfileManager.degree : 'Engineering & Technology'));

    final String mentorFaculty = accountData['mentorName']?.toString() ??
        accountData['mentorFaculty']?.toString() ??
        (ProfileManager.mentorFaculty.isNotEmpty ? ProfileManager.mentorFaculty : 'Dr. R. K. Shrivastava (Faculty Mentor)');

    final dynamic avatarUrl = accountData['avatarUrl'] ?? accountData['avatar'];
    final Uint8List? avatarBytes = accountData['avatarBytes'] as Uint8List?;
    final String? avatarText = accountData['avatarText']?.toString();
    final Color avatarColor = accountData['avatarColor'] as Color? ?? const Color(0xFF0F4C81);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About this account',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 28),

              // Avatar Container
              _buildAvatarWidget(
                avatarUrl: avatarUrl,
                avatarBytes: avatarBytes,
                avatarText: avatarText,
                avatarColor: avatarColor,
                name: name,
              ),
              const SizedBox(height: 14),

              // Name with verified badge if official
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (username.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  '@$username',
                  style: const TextStyle(
                    color: subtextColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Information Disclaimer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(
                        text: "To help keep our campus community authentic and verified, we're showing academic and institutional information about profiles on Acadyk. ",
                      ),
                      TextSpan(
                        text: 'See why this information is important.',
                        style: TextStyle(
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Dynamic Info Rows
              if (isOfficial) ...[
                // Official Handle Rows:
                // 1. Est. year
                _buildInfoRow(
                  icon: CupertinoIcons.calendar,
                  title: 'Est. year',
                  subtitle: estYear,
                ),
                const SizedBox(height: 24),

                // 2. Department / Headquarters
                _buildInfoRow(
                  icon: CupertinoIcons.building_2_fill,
                  title: 'Department',
                  subtitle: department,
                ),
              ] else ...[
                // Student / Member Rows:
                // 1. Academic session
                _buildInfoRow(
                  icon: CupertinoIcons.calendar,
                  title: 'Academic session',
                  subtitle: academicSession,
                ),
                const SizedBox(height: 24),

                // 2. Branch and department
                _buildInfoRow(
                  icon: CupertinoIcons.compass,
                  title: 'Branch and department',
                  subtitle: branch.isNotEmpty && department.isNotEmpty && branch != department
                      ? '$branch • $department'
                      : (branch.isNotEmpty ? branch : department),
                ),
                const SizedBox(height: 24),

                // 3. Mentor Faculty Name
                _buildInfoRow(
                  icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                  title: 'Mentor Faculty Name',
                  subtitle: mentorFaculty,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWidget({
    required dynamic avatarUrl,
    required Uint8List? avatarBytes,
    required String? avatarText,
    required Color avatarColor,
    required String name,
  }) {
    if (avatarBytes != null) {
      return Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        ),
        child: ClipOval(
          child: Image.memory(avatarBytes, fit: BoxFit.cover),
        ),
      );
    }

    if (avatarUrl != null && avatarUrl.toString().isNotEmpty) {
      final str = avatarUrl.toString();
      if (str.startsWith('http')) {
        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          ),
          child: ClipOval(
            child: Image.network(
              str,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallbackInitial(name, avatarColor),
            ),
          ),
        );
      } else if (str.startsWith('assets/')) {
        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          ),
          child: ClipOval(
            child: Image.asset(str, fit: BoxFit.cover),
          ),
        );
      }
    }

    if (avatarText != null && avatarText.isNotEmpty) {
      return Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: avatarColor,
        ),
        alignment: Alignment.center,
        child: Text(
          avatarText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return _buildFallbackInitial(name, avatarColor);
  }

  Widget _buildFallbackInitial(String name, Color avatarColor) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'A';

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarColor,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1E293B), size: 26),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
