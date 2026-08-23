import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteFriendsDialog extends StatelessWidget {
  final String teamName;
  final String? customLink;

  const InviteFriendsDialog({
    super.key,
    required this.teamName,
    this.customLink,
  });

  static Future<void> show(BuildContext context, {required String teamName, String? customLink}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => InviteFriendsDialog(
        teamName: teamName,
        customLink: customLink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final link = customLink ?? 'https://acadyk.app/join/$teamName';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F5F9),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ),

                // Title & Subtitle centered
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Share with Friends',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Team building is more effective when you connect with friends!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Share your link section
                const Text(
                  'Share your link',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),

                // Copy Link box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          link,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: link));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Link copied to clipboard!'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Share to Section
                const Text(
                  'Share to',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                // Social Media icons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSocialButton(
                      context,
                      name: 'Facebook',
                      color: const Color(0xFF1877F2),
                      customChild: const Icon(Icons.facebook, color: Colors.white, size: 24),
                      onTap: () => _shareToSocial(context, 'Facebook', link),
                    ),
                    _buildSocialButton(
                      context,
                      name: 'X',
                      color: const Color(0xFF000000),
                      customChild: const Text(
                        '𝕏',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      onTap: () => _shareToSocial(context, 'X', link),
                    ),
                    _buildSocialButton(
                      context,
                      name: 'Whatsapp',
                      color: const Color(0xFF25D366),
                      customChild: SizedBox(
                        width: 24,
                        height: 24,
                        child: CustomPaint(
                          painter: _WhatsAppVectorPainter(),
                        ),
                      ),
                      onTap: () => _shareToSocial(context, 'WhatsApp', link),
                    ),
                    _buildSocialButton(
                      context,
                      name: 'Telegram',
                      color: const Color(0xFF229ED9),
                      customChild: SizedBox(
                        width: 22,
                        height: 22,
                        child: CustomPaint(
                          painter: _TelegramVectorPainter(),
                        ),
                      ),
                      onTap: () => _shareToSocial(context, 'Telegram', link),
                    ),
                    _buildSocialButton(
                      context,
                      name: 'Linkedin',
                      color: const Color(0xFF0A66C2),
                      customChild: const Text(
                        'in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'sans-serif',
                          letterSpacing: -0.5,
                        ),
                      ),
                      onTap: () => _shareToSocial(context, 'LinkedIn', link),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _shareToSocial(BuildContext context, String platform, String link) async {
    Clipboard.setData(ClipboardData(text: link));

    Uri? targetUri;
    Uri? fallbackUri;

    final encodedLink = Uri.encodeComponent(link);
    final encodedMsg = Uri.encodeComponent("Hey! Join our team '$teamName' on Acadyk: $link");

    switch (platform.toLowerCase()) {
      case 'facebook':
        targetUri = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=$encodedLink');
        break;
      case 'x':
      case 'x (twitter)':
        targetUri = Uri.parse('https://x.com/intent/post?text=$encodedMsg');
        break;
      case 'whatsapp':
        targetUri = Uri.parse('https://api.whatsapp.com/send?text=$encodedMsg');
        fallbackUri = Uri.parse('whatsapp://send?text=$encodedMsg');
        break;
      case 'telegram':
        targetUri = Uri.parse('https://t.me/share/url?url=$encodedLink&text=${Uri.encodeComponent("Join our team '$teamName' on Acadyk!")}');
        fallbackUri = Uri.parse('tg://msg_url?url=$encodedLink&text=${Uri.encodeComponent("Join our team '$teamName' on Acadyk!")}');
        break;
      case 'linkedin':
        targetUri = Uri.parse('https://www.linkedin.com/sharing/share-offsite/?url=$encodedLink');
        break;
    }

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.open_in_new, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Opening $platform (link copied)'),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (targetUri != null) {
      try {
        final launched = await launchUrl(targetUri, mode: LaunchMode.externalApplication);
        if (!launched && fallbackUri != null) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        if (fallbackUri != null) {
          try {
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          } catch (_) {}
        }
      }
    }
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String name,
    required Color color,
    required Widget customChild,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: customChild,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw speech bubble outline
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    final bubblePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..moveTo(size.width * 0.22, size.height * 0.72)
      ..lineTo(size.width * 0.12, size.height * 0.88)
      ..lineTo(size.width * 0.32, size.height * 0.82);

    canvas.drawPath(bubblePath, strokePaint);

    // Draw phone handset inside
    final phonePath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.40)
      ..cubicTo(size.width * 0.32, size.height * 0.45, size.width * 0.35, size.height * 0.58, size.width * 0.45, size.height * 0.68)
      ..cubicTo(size.width * 0.55, size.height * 0.78, size.width * 0.68, size.height * 0.81, size.width * 0.73, size.height * 0.76)
      ..lineTo(size.width * 0.68, size.height * 0.66)
      ..lineTo(size.width * 0.60, size.height * 0.68)
      ..cubicTo(size.width * 0.55, size.height * 0.65, size.width * 0.48, size.height * 0.58, size.width * 0.45, size.height * 0.53)
      ..lineTo(size.width * 0.47, size.height * 0.45)
      ..close();

    canvas.drawPath(phonePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TelegramVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.86, size.height * 0.18)
      ..lineTo(size.width * 0.12, size.height * 0.48)
      ..lineTo(size.width * 0.36, size.height * 0.62)
      ..lineTo(size.width * 0.44, size.height * 0.85)
      ..lineTo(size.width * 0.54, size.height * 0.72)
      ..lineTo(size.width * 0.75, size.height * 0.86)
      ..close();

    canvas.drawPath(path, paint);

    final innerPaint = Paint()
      ..color = const Color(0xFFD4EAF7)
      ..style = PaintingStyle.fill;

    final innerPath = Path()
      ..moveTo(size.width * 0.36, size.height * 0.62)
      ..lineTo(size.width * 0.86, size.height * 0.18)
      ..lineTo(size.width * 0.54, size.height * 0.72)
      ..close();

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
