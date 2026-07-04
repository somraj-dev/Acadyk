import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'settings_about_me_screen.dart';
import 'settings_resume_screen.dart';
import 'settings_education_screen.dart';
import 'settings_work_experience_screen.dart';
import 'settings_achievements_screen.dart';
import 'settings_responsibilities_screen.dart';
import '../../../feed/presentation/screens/create_startup_screen.dart';

class SettingsProfileVisibilityScreen extends StatefulWidget {
  const SettingsProfileVisibilityScreen({super.key});

  @override
  State<SettingsProfileVisibilityScreen> createState() => _SettingsProfileVisibilityScreenState();
}

class _SettingsProfileVisibilityScreenState extends State<SettingsProfileVisibilityScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<CarouselItemData> _carouselItems = [
    CarouselItemData(
      icon: Icons.menu_book,
      title: 'Add Education',
      subtitle: 'Spill the deets on your education and give recruiters a detailed understanding of your background!',
      buttonText: 'Add Education',
    ),
    CarouselItemData(
      icon: Icons.description,
      title: 'Add your Resume & get your profile filled in a click!',
      subtitle: 'Adding your Resume helps you to tell who you are and what makes you different—to employers and recruiters',
      buttonText: 'Add Resume',
    ),
    CarouselItemData(
      icon: Icons.person,
      title: 'Add About',
      subtitle: "This is your bio for people who don't know you, including recruiters from your favourite brands!",
      buttonText: 'Add About',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentPage < _carouselItems.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
      });
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    _timer?.cancel();
    setState(() {
      if (_currentPage < _carouselItems.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    _startTimer();
  }

  void _prevPage() {
    _timer?.cancel();
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      } else {
        _currentPage = _carouselItems.length - 1;
      }
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

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
                // 1. DYNAMIC AUTO-CHANGING CAROUSEL CARD
                _buildAutoCarouselCard(),
                const SizedBox(height: 24),

                // 2. ABOUT SECTION
                _buildAboutSection(),
                _buildDivider(),

                // 3. RESUME SECTION
                _buildResumeSection(),
                const SizedBox(height: 16),
                _buildDivider(),

                // 4. Skills
                _buildVisibilitySection(
                  title: 'Skills',
                  description: 'Spotlight your unique skills and catch the eye of recruiters looking for your exact talents!',
                  actionLabel: 'Add Skills',
                  painter: const SkillsPainter(),
                  onActionTap: () {},
                ),
                _buildDivider(),

                // 5. Work Experience
                _buildVisibilitySection(
                  title: 'Work Experience',
                  description: 'Narrate your professional journey and fast-track your way to new career heights!',
                  actionLabel: 'Add Work Experience',
                  painter: const WorkExperiencePainter(),
                  onActionTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsWorkExperienceScreen()),
                    );
                  },
                ),
                _buildDivider(),

                // 6. Education (List option)
                _buildVisibilitySection(
                  title: 'Education',
                  description: 'Showcase your academic journey and open doors to your dream career opportunities!',
                  actionLabel: 'Add Education',
                  painter: const EducationPainter(),
                  onActionTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsEducationScreen()),
                    );
                  },
                ),
                _buildDivider(),

                // 7. Responsibilities
                _buildVisibilitySection(
                  title: 'Responsibilities',
                  description: "Highlight the responsibilities you've mastered to demonstrate your leadership and expertise!",
                  actionLabel: 'Add Responsibility',
                  painter: const ResponsibilitiesPainter(),
                  onActionTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsResponsibilitiesScreen()),
                    );
                  },
                ),
                _buildDivider(),

                // 8. Certificate
                _buildVisibilitySection(
                  title: 'Certificate',
                  description: "Flaunt your certifications and show recruiters that you're a step ahead in your field!",
                  actionLabel: 'Add Certificate',
                  painter: const CertificatePainter(),
                  onActionTap: () {},
                ),
                _buildDivider(),

                // 9. Projects
                _buildVisibilitySection(
                  title: 'Projects',
                  description: 'Unveil your projects to the world and pave your path to professional greatness!',
                  actionLabel: 'Add Project',
                  painter: const ProjectsPainter(),
                  onActionTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateStartupScreen()),
                    );
                  },
                ),
                _buildDivider(),

                // 10. Achievements
                _buildVisibilitySection(
                  title: 'Achievements',
                  description: 'Broadcast your triumphs and make a remarkable impression on industry leaders!',
                  actionLabel: 'Add Achievement',
                  painter: const AchievementsPainter(),
                  onActionTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsAchievementsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoCarouselCard() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Card container containing PageView
        Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F8FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: const Color(0xFF0073B1),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF191919),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.subtitle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  color: Color(0xFF5E5E5E),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0073B1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (index == 0) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SettingsEducationScreen()),
                            );
                          } else if (index == 1) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SettingsResumeScreen()),
                            );
                          } else if (index == 2) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SettingsAboutMeScreen()),
                            );
                          }
                        },
                        child: Text(
                          item.buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Carousel arrow button left
        Positioned(
          left: -16,
          child: GestureDetector(
            onTap: _prevPage,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.left_chevron,
                size: 14,
                color: Color(0xFF5E5E5E),
              ),
            ),
          ),
        ),

        // Carousel arrow button right
        Positioned(
          right: -16,
          child: GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.right_chevron,
                size: 14,
                color: Color(0xFF5E5E5E),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
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
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Craft an engaging story in your bio and make meaningful connections with peers and recruiters alike!',
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF737373),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsAboutMeScreen()),
                    );
                  },
                  child: const Text(
                    'Add About',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF0095F6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right illustration
          CustomPaint(
            size: const Size(80, 80),
            painter: const AboutPainter(),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resume',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191919),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF6FAFD),
            border: Border.all(
              color: const Color(0xFFE2EFF9),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add your Resume & get your profile filled in a click!',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191919),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Adding your Resume helps you to tell who you are and what makes you different—to employers and recruiters',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF5E5E5E),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsResumeScreen()),
                        );
                      },
                      child: const Text(
                        'Upload Resume',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFF0095F6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right Drawing
              CustomPaint(
                size: const Size(80, 80),
                painter: const ResumePainter(),
              ),
            ],
          ),
        ),
      ],
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
// DATA MODEL FOR AUTO CAROUSEL
// -------------------------------------------------------------

class CarouselItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;

  CarouselItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });
}

// -------------------------------------------------------------
// LINE-ART DRAWING CUSTOM PAINTERS (Matching the images exactly)
// -------------------------------------------------------------

class AboutPainter extends CustomPainter {
  const AboutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Table/Desk line
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.75), Offset(size.width * 0.9, size.height * 0.75), paint);

    // Laptop outline
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.45, size.height * 0.75)
        ..lineTo(size.width * 0.48, size.height * 0.58) // open lid side
        ..lineTo(size.width * 0.65, size.height * 0.58)
        ..lineTo(size.width * 0.63, size.height * 0.75) // open lid other side
        ..close(),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.35), 6, paint);

    // Sitting figure
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.32, size.height * 0.43)
        ..lineTo(size.width * 0.28, size.height * 0.65) // spine
        ..lineTo(size.width * 0.18, size.height * 0.75) // seat
        ..moveTo(size.width * 0.3, size.height * 0.48)
        ..lineTo(size.width * 0.44, size.height * 0.65) // arms typing
        ..moveTo(size.width * 0.18, size.height * 0.75)
        ..lineTo(size.width * 0.35, size.height * 0.90), // leg
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ResumePainter extends CustomPainter {
  const ResumePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Document/Resume sheet
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.28, size.height * 0.2, size.width * 0.48, size.height * 0.65),
        const Radius.circular(3),
      ),
      paint,
    );

    // Text lines inside resume
    canvas.drawLine(Offset(size.width * 0.34, size.height * 0.32), Offset(size.width * 0.7, size.height * 0.32), paint);
    canvas.drawLine(Offset(size.width * 0.34, size.height * 0.45), Offset(size.width * 0.62, size.height * 0.45), paint);
    canvas.drawLine(Offset(size.width * 0.34, size.height * 0.58), Offset(size.width * 0.68, size.height * 0.58), paint);

    // Connection avatars/circles
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.3), 5, paint);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.42), 5, paint);

    // Connection lines
    canvas.drawLine(Offset(size.width * 0.22, size.height * 0.32), Offset(size.width * 0.28, size.height * 0.36), paint);
    canvas.drawLine(Offset(size.width * 0.76, size.height * 0.45), Offset(size.width * 0.82, size.height * 0.48), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
