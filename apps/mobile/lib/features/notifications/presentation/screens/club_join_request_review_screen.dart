import 'package:flutter/material.dart';
import 'package:acadyk/common/services/notification_service.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class ClubJoinRequestReviewScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final VoidCallback? onStatusChanged;

  const ClubJoinRequestReviewScreen({
    super.key,
    required this.requestData,
    this.onStatusChanged,
  });

  @override
  State<ClubJoinRequestReviewScreen> createState() => _ClubJoinRequestReviewScreenState();
}

class _ClubJoinRequestReviewScreenState extends State<ClubJoinRequestReviewScreen> {
  late String _status;
  bool _isProcessing = false;

  // Acadyk Bright Theme Tokens
  static const Color bgPrimary = Colors.white;
  static const Color bgSecondary = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFCBD5E1);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);
  static const Color brandBlue = Color(0xFF0284C7);
  static const Color brandBlueLight = Color(0xFFE0F2FE);
  static const Color acceptGreen = Color(0xFF16A34A);
  static const Color acceptGreenBorder = Color(0xFF15803D);
  static const Color declineBg = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _status = widget.requestData['requestStatus']?.toString() ?? 'pending';
  }

  Future<void> _approve() async {
    if (_isProcessing) return;
    setState(() {
      _status = 'approved';
      _isProcessing = true;
    });

    final id = widget.requestData['id']?.toString() ?? '';
    final clubTitle = widget.requestData['clubTitle']?.toString() ?? 'the Club';
    final sender = widget.requestData['sender'] as Map<String, dynamic>? ?? {};
    final senderName = sender['full_name'] ?? sender['name'] ?? 'Applicant';

    await NotificationService.approveClubJoinRequest(id);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      widget.onStatusChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accepted joining request for $senderName to $clubTitle!'),
          backgroundColor: acceptGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _decline() async {
    if (_isProcessing) return;
    setState(() {
      _status = 'declined';
      _isProcessing = true;
    });

    final id = widget.requestData['id']?.toString() ?? '';
    final sender = widget.requestData['sender'] as Map<String, dynamic>? ?? {};
    final senderName = sender['full_name'] ?? sender['name'] ?? 'Applicant';

    await NotificationService.declineClubJoinRequest(id);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      widget.onStatusChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Declined joining request from $senderName'),
          backgroundColor: const Color(0xFF334155),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openApplicantProfile() {
    final sender = widget.requestData['sender'] as Map<String, dynamic>? ?? {};
    final senderName = sender['full_name'] ?? sender['name'] ?? 'Applicant';
    final senderHandle = sender['username'] ?? 'applicant';
    final senderAvatar = sender['profile_photo_url'] ?? sender['avatar'] ?? '';
    final senderHeadline = sender['headline'] ?? sender['bio'] ?? 'Student Member';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          isOwnProfile: false,
          userData: {
            'id': sender['id'] ?? 'applicant',
            'name': senderName,
            'username': senderHandle,
            'avatar': senderAvatar,
            'headline': senderHeadline,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sender = widget.requestData['sender'] as Map<String, dynamic>? ?? {};
    final senderName = sender['full_name'] ?? sender['name'] ?? 'Kavya Singhania';
    final senderHandle = sender['username'] ?? 'kavya_s';
    final senderAvatar = sender['profile_photo_url'] ?? sender['avatar'] ?? 'assets/images/alina_avatar.jpg';
    final senderHeadline = sender['headline'] ?? sender['bio'] ?? '2nd Year B.Tech CSE · AIML Enthusiast';
    final clubTitle = widget.requestData['clubTitle']?.toString() ?? 'GDSC MITS Chapter';
    final role = widget.requestData['role']?.toString() ?? 'Core Member';
    final orgTitle = clubTitle.contains('/') ? clubTitle.split('/')[1] : clubTitle;

    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: AppBar(
        backgroundColor: bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Join Request Review',
          style: TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: borderLight),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dual Avatar Row: [Applicant Avatar] + [Club Icon / Logo]
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left User Avatar
                  GestureDetector(
                    onTap: _openApplicantProfile,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderSubtle, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: senderAvatar.isNotEmpty
                            ? (senderAvatar.startsWith('http')
                                ? Image.network(
                                    senderAvatar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildFallbackAvatar(senderName),
                                  )
                                : Image.asset(
                                    senderAvatar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildFallbackAvatar(senderName),
                                  ))
                            : _buildFallbackAvatar(senderName),
                      ),
                    ),
                  ),

                  // Plus sign separator
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      '+',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  // Right Club / Chapter Logo
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: brandBlueLight,
                      border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: brandBlueLight,
                        child: const Icon(
                          Icons.groups_rounded,
                          color: brandBlue,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Main Headline matching Acadyk requests
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _openApplicantProfile,
                      child: Text(
                        senderHandle.startsWith('@') ? senderHandle : '@$senderHandle',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: brandBlue,
                          decoration: TextDecoration.underline,
                          decorationColor: brandBlue,
                        ),
                      ),
                    ),
                    const Text(
                      ' requested to join',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Club / Chapter Title in bold
              Text(
                clubTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons: [Accept request] [Decline request]
              if (_status == 'pending') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Accept request button
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _approve,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: acceptGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(color: acceptGreenBorder),
                          ),
                        ),
                        child: const Text(
                          'Accept request',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Decline request button
                    SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: _decline,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: declineBg,
                          foregroundColor: textSecondary,
                          side: const BorderSide(color: borderSubtle),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Decline request',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (_status == 'approved') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: acceptGreen, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You accepted this request. $senderName is now an active member of $clubTitle.',
                          style: const TextStyle(
                            color: Color(0xFF166534),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_status == 'declined') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_outlined, color: textMuted, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'You declined this joining request.',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Permissions & Disclosure Section
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lock icon + Leads of ...
                      Row(
                        children: [
                          const Icon(Icons.lock_outline, size: 17, color: textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Leads & Mentors',
                                    style: TextStyle(color: brandBlue, fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(text: ' of $orgTitle will be able to see:'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 5 Bullet Points matching Acadyk domain
                      _buildBulletItem('Your public profile & academic credentials'),
                      _buildBulletItemWithLink('Certain activity', ' within this club / student chapter'),
                      _buildBulletItem('Branch, department, and academic session records'),
                      _buildBulletItem('Your assigned role & chapter privileges'),
                      _buildBulletItem('College enrollment & verified student email'),

                      const SizedBox(height: 20),
                      const Divider(color: borderLight, height: 1),
                      const SizedBox(height: 16),

                      // Moderation & Abuse Section
                      const Text(
                        'Is this student sending spam or unauthorized requests?',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Blocked @$senderHandle'),
                                  backgroundColor: const Color(0xFF0F172A),
                                ),
                              );
                            },
                            child: Text(
                              'Block @$senderHandle',
                              style: const TextStyle(
                                color: brandBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Text('  ·  ', style: TextStyle(color: textMuted, fontSize: 13)),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Thank you for reporting. Our moderation team will review.'),
                                  backgroundColor: Color(0xFF0F172A),
                                ),
                              );
                            },
                            child: const Text(
                              'Report abuse',
                              style: TextStyle(
                                color: brandBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: brandBlue, fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 13.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItemWithLink(String linkText, String trailingText) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: brandBlue, fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 13.5,
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: linkText,
                    style: const TextStyle(
                      color: brandBlue,
                      decoration: TextDecoration.underline,
                      decorationColor: brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: trailingText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'S';
    return Container(
      color: brandBlue,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
