import 'package:flutter/material.dart';

class StartupGalleryScreen extends StatelessWidget {
  const StartupGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> fields = [
      {'title': 'Graphic Design', 'image': 'assets/images/arogya_dashboard.jpg'},
      {'title': 'Fine Arts', 'image': 'assets/images/backblaze_agreement.jpg'},
      {'title': 'Photography', 'image': 'assets/images/young_entrepreneur.jpg'},
      {'title': 'Interior Design', 'image': 'assets/images/time_handshake.jpg'},
      {'title': 'Icon Design', 'image': 'assets/images/valuation_sentence.jpg'},
      {'title': 'Street Art', 'image': 'assets/images/warp_team.jpg'},
      {'title': 'UI/UX', 'image': 'assets/images/alina_avatar.jpg'},
      {'title': 'Typography', 'image': 'assets/images/dharmik_avatar.jpg'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header mimicking the Behance logo
            Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Startup Galary',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'What creative fields would\nyou like to see work from?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemCount: fields.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        Image.asset(
                          fields[index]['image']!,
                          fit: BoxFit.cover,
                        ),
                        // Subtle gradient at the top to ensure text is readable
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Top-left text
                        Positioned(
                          top: 10,
                          left: 12,
                          child: Text(
                            fields[index]['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
