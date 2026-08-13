import 'package:flutter/material.dart';
import 'event_detail_screen.dart';

class CelebrationSuccessScreen extends StatelessWidget {
  final String eventTitle;
  final String logoUrl;
  final String organizer;

  const CelebrationSuccessScreen({
    super.key,
    required this.eventTitle,
    required this.logoUrl,
    required this.organizer,
  });

  @override
  Widget build(BuildContext context) {
    const cardBgColor = Color(0xFF1A1A1C);

    // Mock high fidelity opportunities using the main Event Card UI
    final List<Map<String, dynamic>> opportunities = [
      {
        'title': 'Authors & Writers Tarot Fest',
        'image': 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/dharmik_avatar.jpg',
        'height': 150.0,
        'event': {
          'title': 'Authors & Writers Tarot Fest',
          'organizer': 'Literary Craft Association',
          'bannerUrl': 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=800&auto=format&fit=crop',
          'logoUrl': 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=80&auto=format&fit=crop',
          'teamSize': 'Individual Participation',
          'registered': 1120,
          'prizes': 'Prizes worth ₹ 95,000',
          'eligibility': 'Writers, authors, occult fans, and literature students.',
          'description': 'Explore storytelling through symbolic visual narratives. Submit short stories or creative essays that build on occult symbols and traditional deck interpretations. Winners receive writing stipends and publication.',
          'timeline': [
            {
              'day': '25',
              'month': 'MAY',
              'title': 'Essay Submissions',
              'startDate': '25 May 26, 10:00 AM IST',
              'endDate': '10 Jul 26, 11:59 PM IST',
              'isLive': true,
              'desc': 'Upload your narrative essays (up to 2000 words) using standard PDF templates.'
            },
            {
              'day': '18',
              'month': 'JUL',
              'title': 'Review Stage',
              'startDate': '18 Jul 26, 09:00 AM IST',
              'endDate': '22 Jul 26, 06:00 PM IST',
              'desc': 'Jury panel reviews creative essays for structure, depth, and symbolism.'
            }
          ]
        }
      },
      {
        'title': 'Lord of the Rings Art Showcase',
        'image': 'https://images.unsplash.com/photo-1519074069444-1ba4e6664104?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/user_avatar.jpg',
        'height': 190.0,
        'event': {
          'title': 'Gandalf the White Cosplay & Art Meet',
          'organizer': 'Middle-earth Fan Club India',
          'bannerUrl': 'https://images.unsplash.com/photo-1514894780887-121968d00567?w=800&auto=format&fit=crop',
          'logoUrl': 'https://images.unsplash.com/photo-1514894780887-121968d00567?w=80&auto=format&fit=crop',
          'teamSize': 'Individual',
          'registered': 890,
          'prizes': 'Prizes worth ₹ 75,000',
          'eligibility': 'Tolkien fans, digital painters, sculptors, and cosplayers of all ages.',
          'description': 'A massive national meetup and cosplay showcase for Lord of the Rings fans. Showcase your handcrafted Gandalf or Middle-earth characters or display illustrations in the fantasy arena. Winners receive exclusive merchandise, trophies, and cash prizes.',
          'timeline': [
            {
              'day': '10',
              'month': 'JUN',
              'title': 'Ticket Bookings',
              'startDate': '10 Jun 26, 12:00 PM IST',
              'endDate': '10 Jul 26, 11:59 PM IST',
              'isLive': true,
              'desc': 'Book your passes for the live Cosplay arena show and art exhibition.'
            },
            {
              'day': '12',
              'month': 'JUL',
              'title': 'Cosplay Showcase',
              'startDate': '12 Jul 26, 04:00 PM IST',
              'endDate': '12 Jul 26, 09:00 PM IST',
              'desc': 'Live cosplay walks, acting, and lore presentation before panels of judges.'
            },
            {
              'day': '13',
              'month': 'JUL',
              'title': 'Art Exhibition & Awards',
              'startDate': '13 Jul 26, 10:00 AM IST',
              'endDate': '13 Jul 26, 04:00 PM IST',
              'desc': 'Gala exhibition of the fantasy art gallery and awarding of cash prizes.'
            }
          ]
        }
      },
      {
        'title': 'Parks Europe Trekking Design',
        'image': 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/alina_avatar.jpg',
        'height': 160.0,
        'event': {
          'title': 'Parks Europe Trekking & Map Design Contest',
          'organizer': 'Keymaster Games & National Parks Club',
          'bannerUrl': 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=800&auto=format&fit=crop',
          'logoUrl': 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=80&auto=format&fit=crop',
          'teamSize': 'Individual or Pairs (Up to 2)',
          'registered': 1750,
          'prizes': 'Prizes worth ₹ 1,20,000',
          'eligibility': 'Map designers, landscape illustrators, and outdoor travel enthusiasts.',
          'description': 'Design the next expansion map card layouts for the award-winning Parks board game, featuring iconic European National Parks and trails. Winners will have their artwork published in the next edition.',
          'timeline': [
            {
              'day': '01',
              'month': 'JUN',
              'title': 'Submissions Open',
              'startDate': '01 Jun 26, 12:00 PM IST',
              'endDate': '25 Jul 26, 11:59 PM IST',
              'isLive': true,
              'desc': 'Submit high-fidelity layouts of European parks following template guidelines.'
            },
            {
              'day': '05',
              'month': 'AUG',
              'title': 'Jury Review & Selection',
              'startDate': '05 Aug 26, 10:00 AM IST',
              'endDate': '12 Aug 26, 06:00 PM IST',
              'desc': 'Keymaster games design team reviews map cards for aesthetic and game balance compliance.'
            }
          ]
        }
      },
      {
        'title': 'Acadyk Board Game Marathon',
        'image': 'https://images.unsplash.com/photo-1543536448-d209d2d13a1c?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/somraj_avatar.jpg',
        'height': 180.0,
        'event': {
          'title': 'Acadyk Board Game Marathon',
          'organizer': 'Acadyk Play Club',
          'bannerUrl': 'https://images.unsplash.com/photo-1543536448-d209d2d13a1c?w=800&auto=format&fit=crop',
          'logoUrl': 'https://images.unsplash.com/photo-1543536448-d209d2d13a1c?w=80&auto=format&fit=crop',
          'teamSize': 'Teams of 2 to 4 players',
          'registered': 450,
          'prizes': 'Prizes worth ₹ 50,000',
          'eligibility': 'Open to all university students who love strategy and tabletop board games.',
          'description': 'A weekend-long marathon play session of classic modern strategy games (Catan, Ticket to Ride, and custom student card games). Prizes awarded for tournament points and team spirit.',
          'timeline': [
            {
              'day': '05',
              'month': 'JUN',
              'title': 'Team Registration',
              'startDate': '05 Jun 26, 12:00 PM IST',
              'endDate': '28 Jul 26, 11:59 PM IST',
              'isLive': true,
              'desc': 'Register your team of 2-4 and state your preferred games list.'
            },
            {
              'day': '02',
              'month': 'AUG',
              'title': 'Live Tournaments',
              'startDate': '02 Aug 26, 10:00 AM IST',
              'endDate': '03 Aug 26, 08:00 PM IST',
              'desc': 'Knockout rounds and finals played live at the campus hobby hub.'
            }
          ]
        }
      },
    ];

    // Distribute items to left and right columns for staggered effect
    final List<Map<String, dynamic>> leftColumn = [];
    final List<Map<String, dynamic>> rightColumn = [];
    for (int i = 0; i < opportunities.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(opportunities[i]);
      } else {
        rightColumn.add(opportunities[i]);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: const Color(0xFFE8F5E9), // Light green background matching screenshot
            child: Column(
              children: [
                // Top Custom Header Row
                _buildHeader(context),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // Green Checkmark icon
                        Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F9D58),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Headline & Subheadline
                        const Text(
                          'Registration Successful',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1F22),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Thank you for registering for this opportunity.\nWishing you the best of luck!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Inner Event details Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Image.network(
                                    logoUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Title details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eventTitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1F22)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        organizer,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Calendar / Share buttons
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.calendar_today, size: 16, color: Colors.black87),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.share, size: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Tips link list
                        _buildInfoTile('Here are some tips to make an impact', isDropdown: true),
                        _buildInfoTile('View All Applications', isDropdown: false),
                        const SizedBox(height: 24),
                        
                        // Opportunities you may like section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Opportunities You May Like',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E1F22)),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Select an Opportunity card to explore similar types of events.',
                                style: TextStyle(color: Colors.grey, fontSize: 12.5),
                              ),
                              const SizedBox(height: 20),
                              
                              // Exhibition styled Event Cards Grid
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column
                                  Expanded(
                                    child: Column(
                                      children: leftColumn.map((item) => _buildMainEventCard(context, item, cardBgColor)).toList(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Right Column
                                  Expanded(
                                    child: Column(
                                      children: rightColumn.map((item) => _buildMainEventCard(context, item, cardBgColor)).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom exit button to complete the flow
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Pops the celebration success screen and registers the user
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007A87),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Center(
                      child: Text(
                        'Got It',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Acadyk Logo text
          Row(
            children: const [
              Text(
                'Acadyk',
                style: TextStyle(
                  color: Color(0xFF004B87),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String text, {required bool isDropdown}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF007A87)),
          ),
          Icon(
            isDropdown ? Icons.keyboard_arrow_down : Icons.arrow_outward,
            size: 18,
            color: const Color(0xFF007A87),
          ),
        ],
      ),
    );
  }

  // High Fidelity 1:1 replica of the main Exhibition styled Event Cards
  Widget _buildMainEventCard(BuildContext context, Map<String, dynamic> item, Color cardBg) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventData: item['event']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image + Avatar Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                  child: Image.network(
                    item['image']!,
                    height: item['height'] as double,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: item['height'] as double,
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.broken_image, color: Colors.white),
                      );
                    },
                  ),
                ),
                // Overlapping avatar
                Positioned(
                  left: 12,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundImage: AssetImage(item['avatar']!),
                    ),
                  ),
                ),
              ],
            ),
            // Title text
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 14.0),
              child: Text(
                item['title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
