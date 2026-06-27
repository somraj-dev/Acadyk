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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Startup Galary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text(
                'What creative fields would you like to see work from?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: fields.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(fields[index]['image']!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        fields[index]['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
