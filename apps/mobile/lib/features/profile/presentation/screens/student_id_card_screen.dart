import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:acadyk/features/profile/presentation/services/profile_manager.dart';
import 'face_verification_screen.dart';

class StudentIdCardScreen extends StatefulWidget {
  const StudentIdCardScreen({super.key});

  @override
  State<StudentIdCardScreen> createState() => _StudentIdCardScreenState();
}

class _StudentIdCardScreenState extends State<StudentIdCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    HapticFeedback.lightImpact();
    if (_controller.isAnimating) return;

    if (_isFlipped) {
      _controller.reverse().then((_) {
        setState(() => _isFlipped = false);
      });
    } else {
      _controller.forward().then((_) {
        setState(() => _isFlipped = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = ProfileManager.name.isNotEmpty ? ProfileManager.name : 'Somraj Lodhi';
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : 'Somraj';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Lodhi';

    final studentId = ProfileManager.enrollmentNumber.isNotEmpty ? ProfileManager.enrollmentNumber : 'BTAM25O1080';
    final avatarPath = ProfileManager.avatarUrl.isNotEmpty ? ProfileManager.avatarUrl : 'assets/images/somraj_avatar.jpg';
    final studentBranch = ProfileManager.branch.isNotEmpty ? ProfileManager.branch : 'AIML';

    return Scaffold(
      backgroundColor: const Color(0xFFC8CBD0),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Studio Vignette Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.1),
                radius: 1.15,
                colors: [
                  Color(0xFFDCE0E5),
                  Color(0xFFC7CBD1),
                  Color(0xFFB0B5BC),
                ],
              ),
            ),
          ),

          // Lanyard Ribbon Strap & Metal Hardware hanging from top
          Positioned(
            top: 0,
            child: _buildLanyardStrapAndClip(),
          ),

          // Hanging Cards Area
          Positioned(
            top: 158,
            child: GestureDetector(
              onTap: _toggleCard,
              child: SizedBox(
                width: 360,
                height: 500,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final t = _animation.value;

                    // Front White Card transforms
                    // Swings out to the right, rotates slightly, and moves to the back layer
                    final whiteAngle = math.sin(t * math.pi) * 0.18 - (t * 0.38);
                    final whiteOffsetX = math.sin(t * math.pi) * 110.0 - (t * 70.0);
                    final whiteScale = 1.0 - (t * 0.08);

                    // Back Dark Card transforms
                    // Starts tilted left (-0.38 rad) and glides forward to center (0 rad)
                    final darkAngle = -0.38 + (t * 0.38) + (math.sin(t * math.pi) * -0.12);
                    final darkOffsetX = -70.0 + (t * 70.0) + (math.sin(t * math.pi) * -60.0);
                    final darkScale = 0.92 + (t * 0.08);

                    final showWhiteOnTop = t < 0.5;

                    return Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // Underneath Card
                        if (showWhiteOnTop)
                          _buildCardTransform(
                            child: _buildDarkCard(fullName, studentId, studentBranch),
                            angle: darkAngle,
                            offsetX: darkOffsetX,
                            scale: darkScale,
                            elevation: 8,
                          )
                        else
                          _buildCardTransform(
                            child: _buildWhiteCard(firstName, lastName, studentId, avatarPath, studentBranch),
                            angle: whiteAngle,
                            offsetX: whiteOffsetX,
                            scale: whiteScale,
                            elevation: 8,
                          ),

                        // Top Card
                        if (showWhiteOnTop)
                          _buildCardTransform(
                            child: _buildWhiteCard(firstName, lastName, studentId, avatarPath, studentBranch),
                            angle: whiteAngle,
                            offsetX: whiteOffsetX,
                            scale: whiteScale,
                            elevation: 20,
                          )
                        else
                          _buildCardTransform(
                            child: _buildDarkCard(fullName, studentId, studentBranch),
                            angle: darkAngle,
                            offsetX: darkOffsetX,
                            scale: darkScale,
                            elevation: 20,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottom Identity Verification Button
          Positioned(
            bottom: 24,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.65),
                    builder: (ctx) => FaceVerificationScreen(
                      avatarUrl: avatarPath,
                      studentName: fullName,
                    ),
                  );
                  if (result == true && mounted) {
                    setState(() {});
                  }
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: ProfileManager.isVerified ? const Color(0xFF064E3B) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: ProfileManager.isVerified
                        ? Border.all(color: const Color(0xFF10B981), width: 1)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: ProfileManager.isVerified
                            ? const Color(0xFF10B981).withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ProfileManager.isVerified ? Icons.verified_rounded : Icons.verified_user_rounded,
                        color: ProfileManager.isVerified ? const Color(0xFF34D399) : const Color(0xFF38BDF8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ProfileManager.isVerified ? 'Identity Verified' : 'Identity Verification',
                        style: TextStyle(
                          color: ProfileManager.isVerified ? const Color(0xFFECFDF5) : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTransform({
    required Widget child,
    required double angle,
    required double offsetX,
    required double scale,
    required double elevation,
  }) {
    return Transform(
      alignment: Alignment.topCenter,
      // ignore: deprecated_member_use
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        // ignore: deprecated_member_use
        ..translate(offsetX, 0.0, 0.0)
        ..rotateZ(angle)
        // ignore: deprecated_member_use
        ..scale(scale, scale, 1.0),
      child: Material(
        color: Colors.transparent,
        elevation: elevation,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  // ===========================================================================
  // 1:1 REPLICA: LANYARD STRAP & METAL CARABINER SWIVEL CLASP
  // ===========================================================================
  Widget _buildLanyardStrapAndClip() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Black Fabric Lanyard Strap
        Container(
          width: 32,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF18181A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Fine strap edge borders
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 1, color: Colors.white.withValues(alpha: 0.08)),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 1, color: Colors.white.withValues(alpha: 0.08)),
              ),
              // Metallic Rivet Grommet Eyelet
              Positioned(
                bottom: 12,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.2, -0.2),
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFD1D5DB),
                        Color(0xFF6B7280),
                        Color(0xFF374151),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Realistic Metal D-Ring, Swivel Joint & Lobster Clasp
        SizedBox(
          width: 44,
          height: 48,
          child: CustomPaint(
            painter: _RealisticMetalClaspPainter(),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 1:1 REPLICA: WHITE FRONT CARD
  // ===========================================================================
  Widget _buildWhiteCard(String firstName, String lastName, String studentId, String avatarPath, String studentBranch) {
    const cardWidth = 280.0;
    const cardHeight = 440.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // 1. Edge-to-Edge Portrait Photo
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: cardHeight * 0.72,
              child: Container(
                color: const Color(0xFFD6D9DE),
                child: Image.asset(
                  avatarPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.person, size: 100, color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),

            // 2. White Curved Cutout Section (Exact S-Curve)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: cardHeight * 0.46,
              child: ClipPath(
                clipper: _BadgeWaveClipper(),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Student Name (Stacked 2 Lines)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E2024),
                              height: 1.15,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            lastName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E2024),
                              height: 1.15,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),

                      // Bottom Metadata (Role and ID)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            studentBranch,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'ID #$studentId',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Top Punch Slot Hole for Lanyard Clip
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                width: 22,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFBFC4CA),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF9CA3AF), width: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1:1 REPLICA: BLACK BACK CARD (Vertical Acadyk Branding & Credentials)
  // ===========================================================================
  Widget _buildDarkCard(String fullName, String studentId, String studentBranch) {
    const cardWidth = 280.0;
    const cardHeight = 440.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF27272A), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Details Info Column on the Dark Card
            Positioned(
              top: 40,
              right: 24,
              left: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INSTITUTION',
                    style: TextStyle(
                      color: Color(0xFF71717A),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Madhav Institute of Technology & Science',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const Text(
                    'Gwalior • Est. 1957',
                    style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'STUDENT NAME',
                    style: TextStyle(
                      color: Color(0xFF71717A),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'ENROLLMENT',
                    style: TextStyle(
                      color: Color(0xFF71717A),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    studentId,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'PROGRAM',
                    style: TextStyle(
                      color: Color(0xFF71717A),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${ProfileManager.degree} $studentBranch (UG)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Batch 2025 - 2029',
                    style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10),
                  ),
                ],
              ),
            ),

            // Top Punch Slot Hole for Lanyard Clip
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                width: 22,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF27272A),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF3F3F46), width: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EXACT S-CURVE BADGE CUTOUT CLIPPER
// =============================================================================
class _BadgeWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Starts on the left at y = 0
    path.moveTo(0, 0);

    // Left flat portion extends to 60% width
    path.lineTo(size.width * 0.60, 0);

    // Smooth organic S-curve transitioning down to y = 28 on the right
    path.cubicTo(
      size.width * 0.76, 0,
      size.width * 0.80, 26,
      size.width, 26,
    );

    // Down to bottom right
    path.lineTo(size.width, size.height);
    // Across to bottom left
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// =============================================================================
// 1:1 REALISTIC METAL LOBSTER CLASP & D-RING PAINTER
// =============================================================================
class _RealisticMetalClaspPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Metal Chrome Shader
    final chromeShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFE2E8F0),
        Color(0xFF94A3B8),
        Color(0xFF475569),
        Color(0xFFCBD5E1),
      ],
      stops: [0.0, 0.25, 0.55, 0.8, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final metalStroke = Paint()
      ..shader = chromeShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final metalFill = Paint()..shader = chromeShader;

    // 1. Top Metal D-Ring / Wire Loop
    final dRingRect = Rect.fromCenter(center: Offset(cx, 6), width: 22, height: 9);
    canvas.drawOval(dRingRect, metalStroke);

    // 2. Swivel Collar Joint (Small cylinder)
    final collarRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, 13), width: 8, height: 6),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(collarRect, metalFill);

    // 3. Lobster Snap Hook Body
    final hookPath = Path()
      // Top neck
      ..moveTo(cx, 16)
      ..lineTo(cx, 22)
      // Curved outer hook
      ..cubicTo(cx + 6, 24, cx + 7, 34, cx, 38)
      ..cubicTo(cx - 7, 38, cx - 7, 30, cx - 3, 26)
      // Inner latch
      ..lineTo(cx, 26)
      ..lineTo(cx, 34);

    canvas.drawPath(hookPath, metalStroke);

    // 4. Spring Lever Trigger Pin
    final triggerPath = Path()
      ..moveTo(cx + 2, 23)
      ..lineTo(cx + 6, 26);
    canvas.drawPath(
      triggerPath,
      Paint()
        ..shader = chromeShader
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
