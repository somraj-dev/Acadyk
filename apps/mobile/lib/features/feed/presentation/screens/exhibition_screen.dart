import 'package:flutter/material.dart';
import 'event_detail_screen.dart';
import 'startup_details_screen.dart';

class ExhibitionScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? items;
  final String? title;
  final bool isFineArts;

  const ExhibitionScreen({
    super.key,
    this.items,
    this.title,
    this.isFineArts = false,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const cardBgColor = Color(0xFFF9FAFB);


    final List<Map<String, dynamic>> exhibitionItems = items ?? [
      {
        'title': 'Horror Circus tarot deck',
        'image': 'https://images.unsplash.com/photo-1601042879364-f3947d3f9c16?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/alina_avatar.jpg',
        'height': 200.0,
        'event': {
          'title': 'Horror Circus Illustration Challenge',
          'organizer': 'Dark Art Society & BoardGames Inc.',
          'bannerUrl': 'https://images.unsplash.com/photo-1509248961158-e54f6934749c?w=800&auto=format&fit=crop',
          'logoUrl': 'https://images.unsplash.com/photo-1601042879364-f3947d3f9c16?w=80&auto=format&fit=crop',
          'teamSize': 'Individual or Team (Up to 3)',
          'registered': 2450,
          'prizes': 'Prizes worth ₹ 1,50,000',
          'eligibility': 'Open to all digital illustrators, dark artists, and graphic designers worldwide.',
          'description': 'Welcome to the Horror Circus Illustration Challenge 2026. Design the most spooky, gothic, and captivating tarot deck illustration featuring circus characters. The winning entries will be featured in the official dark horror tarot release and get contracts for full-deck illustration.',
          'timeline': [
            {
              'day': '10',
              'month': 'JUN',
              'title': 'Submissions Phase',
              'startDate': '10 Jun 26, 12:00 PM IST',
              'endDate': '15 Jul 26, 11:59 PM IST',
              'isLive': true,
              'desc': 'Submit your digital illustrations in high resolution matching our theme specifications.'
            },
            {
              'day': '20',
              'month': 'JUL',
              'title': 'Community Voting',
              'startDate': '20 Jul 26, 12:00 PM IST',
              'endDate': '25 Jul 26, 08:00 PM IST',
              'desc': 'Top 50 designs will be selected for open community voting on the Acadyk platform.'
            },
            {
              'day': '01',
              'month': 'AUG',
              'title': 'Final Winner Selection',
              'startDate': '01 Aug 26, 05:00 PM IST',
              'endDate': '01 Aug 26, 08:00 PM IST',
              'desc': 'Jury and community votes are aggregated to declare the first, second, and third place winners.'
            }
          ]
        }
      },
      {
        'title': "Author's Tarot Decks",
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
        'title': 'Card board game / Fore...',
        'image': 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/somraj_avatar.jpg',
        'height': 220.0,
        'event': {
          'title': 'The Coca-Cola Mantra Challenge 2026',
          'organizer': 'Coca-Cola India and Southwest Asia',
          'bannerUrl': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&auto=format&fit=crop',
          'logoUrl': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=80&auto=format&fit=crop',
          'teamSize': 'Individual Participation',
          'registered': 13930,
          'prizes': 'Prizes worth ₹ 2,25,000',
          'eligibility': '1st year students pursuing Full-time 2-year MBA/PGDM courses (Batch of 2026-28)',
          'description': 'Welcome to The Coca-Cola Mantra Challenge 2026 - Where Tomorrow\'s Business Leaders Are Forged Today.\n\nThis may lead to a summer internship opportunity but more importantly this is your launchpad into a world of possibilities with one of the most iconic global brands. More than just a selection journey, the Mantra Challenge is a dynamic experience designed to spark your creativity, sharpen your skills, and immerse you in real-world business challenges.\n\nStep into a high-energy arena where ideas thrive, innovation is celebrated, and entrepreneurial thinking leads the way.\n\nGet ready to challenge the status quo, accelerate your learning, and step confidently into your future. The journey begins now - are you ready to lead it?',
          'timeline': [
            {
              'day': '20',
              'month': 'MAY',
              'title': 'Registrations',
              'startDate': '20 May 26, 12:00 PM IST',
              'endDate': '03 Jul 26, 11:59 PM IST',
              'isLive': true,
              'desc': 'Registrations for The Coca-Cola Mantra Challenge are open until July 3, 2026. Ensure you complete your registration before the deadline. For any support, feel free to contact us at support@acadyk.com.'
            },
            {
              'day': '04',
              'month': 'JUL',
              'title': 'Brand Trivia',
              'startDate': '04 Jul 26, 12:00 PM IST',
              'endDate': '04 Jul 26, 08:00 PM IST',
              'desc': 'It\'s time to put your brand knowledge to the test with the Coca-Cola Trivia! This round features engaging questions from the following 4 themes, all centred around the Coca-Cola universe. Hints for the questions will be shared on Acadyk\'s Instagram Stories, so make sure to follow along closely.'
            },
            {
              'day': '15',
              'month': 'JUL',
              'title': 'Simulation Round',
              'startDate': '15 Jul 26, 12:00 PM IST',
              'endDate': '15 Jul 26, 08:00 PM IST',
              'desc': 'In this engaging online simulation, you will step into the shoes of an Area Sales Manager for an FMCG company. This stage challenges you to make strategic decisions, solve real-life challenges, manage resources, and optimise ROI, reflecting the true nature of a day in the life of a manager in the industry.'
            }
          ]
        }
      },
      {
        'title': 'Gandalf the white 🌙🔮',
        'image': 'https://images.unsplash.com/photo-1519074069444-1ba4e6664104?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/user_avatar.jpg',
        'height': 240.0,
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
        'title': 'Parks Europe (Keymaste...',
        'image': 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/alina_avatar.jpg',
        'height': 190.0,
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
        'title': 'Board game illustration. ...',
        'image': 'https://images.unsplash.com/photo-1606167668584-78701c57f13d?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/dharmik_avatar.jpg',
        'height': 170.0,
        'event': {
          'title': 'Board Game Cover Art Challenge',
          'organizer': 'Indie Game Developers Guild',
          'bannerUrl': 'https://images.unsplash.com/photo-1606167668584-78701c57f13d?w=800&auto=format&fit=crop',
          'logoUrl': 'https://images.unsplash.com/photo-1606167668584-78701c57f13d?w=80&auto=format&fit=crop',
          'teamSize': 'Individual Participation',
          'registered': 3100,
          'prizes': 'Prizes worth ₹ 1,40,000',
          'eligibility': 'Open to graphic designers, concept artists, and board game enthusiasts.',
          'description': 'Create an intriguing box cover illustration for a mystery/detective board game. Show off your skills in creating mood, suspense, and character depth.',
          'timeline': [
            {
              'day': '15',
              'month': 'MAY',
              'title': 'Registrations & Launch',
              'startDate': '15 May 26, 12:00 PM IST',
              'endDate': '15 Jul 26, 11:59 PM IST',
              'isLive': true,
              'desc': 'Register and access the creative brief containing the mystery storyline.'
            },
            {
              'day': '20',
              'month': 'JUL',
              'title': 'Artwork Submission',
              'startDate': '20 Jul 26, 12:00 PM IST',
              'endDate': '25 Jul 26, 11:59 PM IST',
              'desc': 'Submit front cover graphics along with a short process writeup.'
            }
          ]
        }
      },
      {
        'title': 'Playing cards in hand',
        'image': 'https://images.unsplash.com/photo-1543536448-d209d2d13a1c?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/somraj_avatar.jpg',
        'height': 230.0,
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
      {
        'title': 'A Trip Around Nizhny Novgorod',
        'image': 'https://images.unsplash.com/photo-1585504198199-20277593b94f?w=500&auto=format&fit=crop&q=80',
        'avatar': 'assets/images/user_avatar.jpg',
        'height': 160.0,
        'event': {
          'title': 'Nizhny Novgorod Pathfinding Contest',
          'organizer': 'Global Geographic Games',
          'bannerUrl': 'https://images.unsplash.com/photo-1585504198199-20277593b94f?w=800&auto=format&fit=crop',
          'logoUrl': 'https://images.unsplash.com/photo-1585504198199-20277593b94f?w=80&auto=format&fit=crop',
          'teamSize': 'Individual Participation',
          'registered': 840,
          'prizes': 'Prizes worth ₹ 60,000',
          'eligibility': 'Open to all geography students, pathfinding enthusiasts, and game programmers.',
          'description': 'Solve pathfinding algorithms and travel puzzle boards based on historic mapping data of Nizhny Novgorod. Optimize travel routes under simulated tourist constraints.',
          'timeline': [
            {
              'day': '18',
              'month': 'JUN',
              'title': 'Contest Sign-up',
              'startDate': '18 Jun 26, 12:00 PM IST',
              'endDate': '30 Jul 26, 11:59 PM IST',
              'isLive': true,
              'desc': 'Sign up and pull the routing code packages from the git server.'
            },
            {
              'day': '05',
              'month': 'AUG',
              'title': 'Submissions Due',
              'startDate': '05 Aug 26, 09:00 AM IST',
              'endDate': '05 Aug 26, 11:59 PM IST',
              'desc': 'Submit routing paths script and performance metrics.'
            }
          ]
        }
      },
    ];

    // Distribute items between left and right columns to achieve a staggered effect
    final List<Map<String, dynamic>> leftColumnItems = [];
    final List<Map<String, dynamic>> rightColumnItems = [];
    for (int i = 0; i < exhibitionItems.length; i++) {
      if (i % 2 == 0) {
        leftColumnItems.add(exhibitionItems[i]);
      } else {
        rightColumnItems.add(exhibitionItems[i]);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF), // Matching the background pattern of the main feed
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: bgColor,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: bgColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  title ?? 'Exhibition',
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF1F2937)),
                    onPressed: () {},
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        children: leftColumnItems.map((item) => _buildCard(context, item, cardBgColor)).toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Column
                    Expanded(
                      child: Column(
                        children: rightColumnItems.map((item) => _buildCard(context, item, cardBgColor)).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> item, Color cardBg) {
    return GestureDetector(
      onTap: () {
        if (isFineArts) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const StartupDetailsScreen(),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventData: item['event']),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, color: Colors.grey.shade500),
                      );
                    },
                  ),
                ),
                // Overlapping avatar at bottom-left corner of the image
                Positioned(
                  left: 12,
                  bottom: -12, // slightly overlap out to look cool and premium
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
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
            const SizedBox(height: 12),
            // Title / Caption
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0, bottom: 14.0),
              child: Text(
                item['title']!,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 14,
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
