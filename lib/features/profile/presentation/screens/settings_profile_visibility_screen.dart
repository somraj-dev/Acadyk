import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SettingsProfileVisibilityScreen extends StatelessWidget {
  const SettingsProfileVisibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const tileTextColor = Colors.black;
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
          'Profile visibility',
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              children: [
                _buildVisibilitySection(
                  title: 'Skills',
                  description: 'Spotlight your unique skills and catch the eye of recruiters looking for your exact talents!',
                  actionLabel: 'Add Skills',
                  painter: const SkillsPainter(),
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Work Experience',
                  description: 'Narrate your professional journey and fast-track your way to new career heights!',
                  actionLabel: 'Add Work Experience',
                  painter: const WorkExperiencePainter(),
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Education',
                  description: 'Showcase your academic journey and open doors to your dream career opportunities!',
                  actionLabel: 'Add Education',
                  painter: const EducationPainter(),
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Responsibilities',
                  description: "Highlight the responsibilities you've mastered to demonstrate your leadership and expertise!",
                  actionLabel: 'Add Responsibility',
                  painter: const ResponsibilitiesPainter(),
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Certificate',
                  description: "Flaunt your certifications and show recruiters that you're a step ahead in your field!",
                  actionLabel: 'Add Certificate',
                  painter: const CertificatePainter(),
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Projects',
                  description: 'Unveil your projects to the world and pave your path to professional greatness!',
                  actionLabel: 'Add Project',
                  painter: const ProjectsPainter(),
                  onActionTap: () {},
                ),
                _buildDivider(),
                _buildVisibilitySection(
                  title: 'Achievements',
                  description: 'Broadcast your triumphs and make a remarkable impression on industry leaders!',
                  actionLabel: 'Add Achievement',
                  painter: const AchievementsPainter(),
                  onActionTap: () {},
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilitySection({
    required String title,
    required String description,
    required String actionLabel,
    required CustomPainter painter,
    required VoidCallback onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF737373),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: onActionTap,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFF0095F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right sketch illustration
          CustomPaint(
            size: const Size(80, 80),
            painter: painter,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Color(0xFFEFEFEF),
    );
  }
}

// -------------------------------------------------------------
// LINE-ART DRAWING CUSTOM PAINTERS (Matching the images exactly)
// -------------------------------------------------------------

class SkillsPainter extends CustomPainter {
  const SkillsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Draw Board/Screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.6, size.height * 0.5),
        const Radius.circular(4),
      ),
      paint,
    );

    // Draw Board content lines
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.25), Offset(size.width * 0.5, size.height * 0.25), paint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.4), Offset(size.width * 0.4, size.height * 0.4), paint);

    // Draw Stand
    canvas.drawLine(Offset(size.width * 0.4, size.height * 0.6), Offset(size.width * 0.4, size.height * 0.75), paint);
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.75), Offset(size.width * 0.55, size.height * 0.75), paint);

    // Draw simple line-art figure pointing
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.35), 6, paint); // Head
    // Body & Arm pointing to board
    final path = Path()
      ..moveTo(size.width * 0.75, size.height * 0.43)
      ..lineTo(size.width * 0.75, size.height * 0.75) // spine
      ..moveTo(size.width * 0.75, size.height * 0.48)
      ..lineTo(size.width * 0.55, size.height * 0.38) // arm pointing
      ..moveTo(size.width * 0.75, size.height * 0.48)
      ..lineTo(size.width * 0.88, size.height * 0.55); // other arm
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WorkExperiencePainter extends CustomPainter {
  const WorkExperiencePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Draw Briefcase outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.25, size.width * 0.8, size.height * 0.5),
        const Radius.circular(6),
      ),
      paint,
    );

    // Briefcase handle
    final path = Path()
      ..moveTo(size.width * 0.38, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.38, size.height * 0.13, size.width * 0.5, size.height * 0.13)
      ..quadraticBezierTo(size.width * 0.62, size.height * 0.13, size.width * 0.62, size.height * 0.25);
    canvas.drawPath(path, paint);

    // Clasp details & strap lines
    canvas.drawRect(Rect.fromLTWH(size.width * 0.44, size.height * 0.45, size.width * 0.12, size.height * 0.1), paint);
    canvas.drawLine(Offset(size.width * 0.28, size.height * 0.25), Offset(size.width * 0.28, size.height * 0.75), paint);
    canvas.drawLine(Offset(size.width * 0.72, size.height * 0.25), Offset(size.width * 0.72, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EducationPainter extends CustomPainter {
  const EducationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Stack of Books
    // Top Book
    canvas.drawRect(Rect.fromLTWH(size.width * 0.15, size.height * 0.22, size.width * 0.65, size.height * 0.12), paint);
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.28), Offset(size.width * 0.1, size.height * 0.28), paint);

    // Middle Book
    canvas.drawRect(Rect.fromLTWH(size.width * 0.2, size.height * 0.38, size.width * 0.65, size.height * 0.12), paint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.44), Offset(size.width * 0.15, size.height * 0.44), paint);

    // Bottom Book
    canvas.drawRect(Rect.fromLTWH(size.width * 0.12, size.height * 0.54, size.width * 0.72, size.height * 0.13), paint);
    canvas.drawLine(Offset(size.width * 0.12, size.height * 0.60), Offset(size.width * 0.06, size.height * 0.60), paint);

    // Bookmark/Ribbon hanging down
    final ribbon = Path()
      ..moveTo(size.width * 0.65, size.height * 0.34)
      ..lineTo(size.width * 0.65, size.height * 0.78)
      ..lineTo(size.width * 0.7, size.height * 0.73)
      ..lineTo(size.width * 0.75, size.height * 0.78)
      ..lineTo(size.width * 0.75, size.height * 0.34);
    canvas.drawPath(ribbon, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ResponsibilitiesPainter extends CustomPainter {
  const ResponsibilitiesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Head 1
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 6, paint);
    // Body 1
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.3, size.height * 0.38)
        ..lineTo(size.width * 0.3, size.height * 0.75)
        ..moveTo(size.width * 0.3, size.height * 0.45)
        ..lineTo(size.width * 0.48, size.height * 0.52),
      paint,
    );

    // Head 2
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.38), 6, paint);
    // Body 2
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.65, size.height * 0.46)
        ..lineTo(size.width * 0.65, size.height * 0.8)
        ..moveTo(size.width * 0.65, size.height * 0.52)
        ..lineTo(size.width * 0.48, size.height * 0.52),
      paint,
    );

    // Checkmark/Approval star badge next to figures
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.28), 5, paint);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.82, size.height * 0.28)
        ..lineTo(size.width * 0.85, size.height * 0.31)
        ..lineTo(size.width * 0.89, size.height * 0.24),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CertificatePainter extends CustomPainter {
  const CertificatePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Certificate Frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.15, size.width * 0.7, size.height * 0.68),
        const Radius.circular(6),
      ),
      paint,
    );

    // Header line inside
    canvas.drawLine(Offset(size.width * 0.28, size.height * 0.28), Offset(size.width * 0.72, size.height * 0.28), paint);

    // Content lines
    canvas.drawLine(Offset(size.width * 0.22, size.height * 0.42), Offset(size.width * 0.78, size.height * 0.42), paint);
    canvas.drawLine(Offset(size.width * 0.22, size.height * 0.52), Offset(size.width * 0.78, size.height * 0.52), paint);

    // Ribbon / Wax Seal badge in bottom right corner
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.68), 5, paint);
    final ribbons = Path()
      ..moveTo(size.width * 0.65, size.height * 0.72)
      ..lineTo(size.width * 0.63, size.height * 0.81)
      ..lineTo(size.width * 0.68, size.height * 0.78)
      ..lineTo(size.width * 0.73, size.height * 0.81)
      ..lineTo(size.width * 0.71, size.height * 0.72);
    canvas.drawPath(ribbons, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProjectsPainter extends CustomPainter {
  const ProjectsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Head
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.25), 6, paint);

    // Figure body
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.33)
        ..lineTo(size.width * 0.5, size.height * 0.68)
        ..moveTo(size.width * 0.5, size.height * 0.43)
        ..lineTo(size.width * 0.32, size.height * 0.55)
        ..moveTo(size.width * 0.5, size.height * 0.43)
        ..lineTo(size.width * 0.68, size.height * 0.55),
      paint,
    );

    // Blueprint/Drawing Plan outline held by hands
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.22, size.height * 0.52, size.width * 0.56, size.height * 0.3),
        const Radius.circular(3),
      ),
      paint,
    );

    // Blueprint grid/content indicator
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.6), Offset(size.width * 0.5, size.height * 0.72), paint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.72), Offset(size.width * 0.7, size.height * 0.6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AchievementsPainter extends CustomPainter {
  const AchievementsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Big central Star path
    final path = Path();

    // Direct manual path for precise clean 5-point star
    path.moveTo(40, 20);
    path.lineTo(46, 33);
    path.lineTo(60, 35);
    path.lineTo(50, 45);
    path.lineTo(52, 59);
    path.lineTo(40, 52);
    path.lineTo(28, 59);
    path.lineTo(30, 45);
    path.lineTo(20, 35);
    path.lineTo(34, 33);
    path.close();
    canvas.drawPath(path, paint);

    // Sparkles / Small stars around
    canvas.drawPath(
      Path()
        ..moveTo(22, 18)..lineTo(24, 22)..lineTo(28, 22)..lineTo(25, 24)..lineTo(26, 28)..lineTo(22, 25)..lineTo(18, 28)..lineTo(19, 24)..lineTo(16, 22)..lineTo(20, 22)..close(),
      paint,
    );

    // Small sparkle dots/lines
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.55), Offset(size.width * 0.20, size.height * 0.55), paint);
    canvas.drawLine(Offset(size.width * 0.8, size.height * 0.35), Offset(size.width * 0.85, size.height * 0.35), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
