import 'package:flutter/material.dart';
import 'exhibition_screen.dart';
import '../services/startup_manager.dart';
import 'startup_details_screen.dart';

class StartupGalleryScreen extends StatelessWidget {
  const StartupGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header mimicking the Behance logo
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Startup Galary',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance back button width
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
                  color: Color(0xFF1F2937),
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
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: StartupManager.startups,
                builder: (context, startupsList, child) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: startupsList.length,
                    itemBuilder: (context, index) {
                      final item = startupsList[index];
                      final isFineArts = item['title'] == 'Fine Arts';
                      final isCustom = item['isCustom'] == true;

                      return GestureDetector(
                        onTap: () {
                          if (isCustom) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => StartupDetailsScreen(
                                  customData: item['customData'],
                                ),
                              ),
                            );
                          } else if (isFineArts) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ExhibitionScreen(
                                  title: 'Fine Arts Exhibition',
                                  isFineArts: true,
                                  items: [
                                    {
                                      'title': 'Oil on Canvas: Whispering Woods',
                                      'image': 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=500&auto=format&fit=crop&q=80',
                                      'avatar': 'assets/images/alina_avatar.jpg',
                                      'height': 220.0,
                                      'event': {
                                        'title': 'National Fine Arts Exhibition 2026',
                                        'organizer': 'Royal Academy of Arts',
                                        'bannerUrl': 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=800&auto=format&fit=crop',
                                        'logoUrl': 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=80&auto=format&fit=crop',
                                        'teamSize': 'Individual Participation',
                                        'registered': 890,
                                        'prizes': 'Prizes worth ₹ 2,00,000',
                                        'eligibility': 'Open to all fine artists.',
                                        'description': 'Celebrating contemporary oil painting and classical sculpture. Showcasing selected artists from across the nation.',
                                        'timeline': [
                                          {
                                            'day': '15',
                                            'month': 'JUL',
                                            'title': 'Submissions Phase',
                                            'startDate': '15 Jul 26, 12:00 PM IST',
                                            'endDate': '25 Aug 26, 11:59 PM IST',
                                            'isLive': true,
                                            'desc': 'Submit high resolution photos of your physical canvas or sculpture work.'
                                          }
                                        ]
                                      }
                                    },
                                    {
                                      'title': 'Modern Abstract Sculpture',
                                      'image': 'https://images.unsplash.com/photo-1582559868776-d9333be282f1?w=500&auto=format&fit=crop&q=80',
                                      'avatar': 'assets/images/dharmik_avatar.jpg',
                                      'height': 180.0,
                                      'event': {
                                        'title': 'Sculpture & Spatial Forms Challenge',
                                        'organizer': 'Society of Sculptors',
                                        'bannerUrl': 'https://images.unsplash.com/photo-1582559868776-d9333be282f1?w=800&auto=format&fit=crop',
                                        'logoUrl': 'https://images.unsplash.com/photo-1582559868776-d9333be282f1?w=80&auto=format&fit=crop',
                                        'teamSize': 'Individual or Team (Up to 2)',
                                        'registered': 430,
                                        'prizes': 'Prizes worth ₹ 1,20,000',
                                        'eligibility': 'Fine arts students and professional sculptors.',
                                        'description': 'Highlighting innovative sculpture techniques and installation art.',
                                        'timeline': [
                                          {
                                            'day': '10',
                                            'month': 'AUG',
                                            'title': 'Design Submission',
                                            'startDate': '10 Aug 26, 10:00 AM IST',
                                            'endDate': '20 Sep 26, 06:00 PM IST',
                                            'isLive': true,
                                            'desc': 'Upload design drafts and descriptions of material choices.'
                                          }
                                        ]
                                      }
                                    },
                                    {
                                      'title': 'Watercolor Plein Air Study',
                                      'image': 'https://images.unsplash.com/photo-1579783928621-7a13d66a6211?w=500&auto=format&fit=crop&q=80',
                                      'avatar': 'assets/images/somraj_avatar.jpg',
                                      'height': 240.0,
                                      'event': {
                                        'title': 'Watercolor Open Landscapes',
                                        'organizer': 'Plein Air Society',
                                        'bannerUrl': 'https://images.unsplash.com/photo-1579783928621-7a13d66a6211?w=800&auto=format&fit=crop',
                                        'logoUrl': 'https://images.unsplash.com/photo-1579783928621-7a13d66a6211?w=80&auto=format&fit=crop',
                                        'teamSize': 'Individual',
                                        'registered': 670,
                                        'prizes': 'Prizes worth ₹ 75,000',
                                        'eligibility': 'All watercolor artists.',
                                        'description': 'On-site watercolor landscape painting contest capturing natural lighting and architecture.',
                                        'timeline': [
                                          {
                                            'day': '05',
                                            'month': 'SEP',
                                            'title': 'Live Plein Air Painting',
                                            'startDate': '05 Sep 26, 09:00 AM IST',
                                            'endDate': '06 Sep 26, 06:00 PM IST',
                                            'isLive': true,
                                            'desc': 'Create on-site watercolor paintings of landscapes specified in the brief.'
                                          }
                                        ]
                                      }
                                    },
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background image
                              item['image']!.startsWith('assets/')
                                  ? Image.asset(
                                      item['image']!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      item['image']!,
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
                                  item['title']!,
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
                        ),
                      );
                    },
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
