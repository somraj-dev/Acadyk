import 'package:flutter/material.dart';
import 'registration_form_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailScreen({super.key, required this.eventData});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isRegistered = false;
  int _activeFaqTab = 0; // 0 for FAQs, 1 for Discussions
  String _selectedFaqCategory = 'Registration';

  @override
  Widget build(BuildContext context) {
    final event = widget.eventData;
    final timeline = event['timeline'] as List<Map<String, dynamic>>;

    final List<Map<String, dynamic>> importantDates = [
      {'day': '3', 'month': 'Jul', 'dateText': '03 Jul 26, 11:59 PM IST', 'title': 'Registration Deadline'},
      {'day': '4', 'month': 'Jul', 'dateText': '04 Jul 26, 08:00 PM IST', 'title': 'Brand Trivia Round Deadline'},
      {'day': '5', 'month': 'Jul', 'dateText': '05 Jul 26, 11:59 PM IST', 'title': 'Become a Coke Ambassador Round Deadline'},
      {'day': '15', 'month': 'Jul', 'dateText': '15 Jul 26, 08:00 PM IST', 'title': 'Simulation Round Deadline'},
      {'day': '21', 'month': 'Jul', 'dateText': '21 Jul 26, 11:59 PM IST', 'title': 'Resume Submission Deadline'},
    ];

    final List<Map<String, dynamic>> rewards = [
      {'amount': '₹1,00,000', 'label': 'Winner', 'isMerch': false},
      {'amount': '₹75,000', 'label': '1st Runner Up', 'isMerch': false},
      {'amount': '₹50,000', 'label': '2nd Runner Up', 'isMerch': false},
      {'amount': '', 'label': '3rd & 4th Runner Ups', 'isMerch': true},
    ];

    final List<Map<String, String>> faqs = [
      {
        'question': 'How can I participate in this competition?',
        'answer': 'You can participate by clicking the "Register" button below. The registration is completely online and free of cost.'
      },
      {
        'question': 'Is this competition open to students from all universities and courses?',
        'answer': 'This challenge is specifically open for 1st-year students pursuing full-time 2-year MBA/PGDM programs across eligible management institutes.'
      },
      {
        'question': 'Is there a registration fee for participating in this competition?',
        'answer': 'No, there are no registration fees or hidden charges associated with participating in the Coca-Cola Mantra Challenge.'
      },
      {
        'question': 'What details should I fill in if I am an upcoming/admitted MBA student?',
        'answer': 'Please enter your current college name, your program details, your admission roll/reg number, and complete the profile details on Acadyk.'
      },
      {
        'question': 'I am in waitlist and might convert to another college. How can I proceed?',
        'answer': 'You can register with your primary target/current college. If your admission details change later, you can write to support@acadyk.com to update college fields.'
      },
      {
        'question': 'How can I delete my registration from this opportunity?',
        'answer': 'To cancel or delete your registration, please navigate to your dashboard registrations tab or contact support directly.'
      },
      {
        'question': 'I am unable to verify my phone number. What should I do?',
        'answer': 'Ensure your network connection is stable. If you do not receive the OTP, try resending in 2 minutes, or request assistance via support channels.'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: const Color(0xFFF3F2EF),
            child: Column(
              children: [
                // Top App Bar
                _buildAppBar(context, event['title']),
                
                // Scrollable Body (Structured in high-fidelity cards)
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. High-Fidelity Banner Card
                          _buildHighFidelityBanner(event),
                          const SizedBox(height: 12),
                          
                          // 2. Info & Stats Card (Teal border top)
                          _buildInfoStatsCard(event),
                          const SizedBox(height: 12),
                          
                          // 3. Eligibility & Description Card
                          _buildDescriptionCard(event),
                          const SizedBox(height: 12),
                          
                          // 4. Stages & Timelines Card
                          _buildStagesTimelineCard(timeline, event),
                          const SizedBox(height: 12),
                          
                          // 5. Important dates & deadlines
                          _buildImportantDatesCard(importantDates),
                          const SizedBox(height: 12),
                          
                          // 6. Rewards and Prizes
                          _buildRewardsCard(rewards),
                          const SizedBox(height: 12),
                          
                          // 7. Feedback & Rating
                          _buildFeedbackRatingCard(),
                          const SizedBox(height: 12),
                          
                          // 8. FAQs / Discussions
                          _buildFaqsCard(faqs),
                          const SizedBox(height: 12),
                          
                          // Breadcrumbs & Powered By Footer
                          _buildBreadcrumbsAndFooter(event),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Sticky Bottom register bar
                _buildBottomRegisterBar(event),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1F22)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1E1F22),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1E1F22)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF007A87),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1F22),
          ),
        ),
      ],
    );
  }

  // Card 1: High Fidelity Banner (Reproducing Coca-Cola visual layout)
  Widget _buildHighFidelityBanner(Map<String, dynamic> event) {
    final bool isCoke = event['title'].toString().contains('Coca-Cola');
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Top section with logos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo
                    if (isCoke)
                      const Text(
                        'Coca-Cola',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      const Icon(Icons.palette_outlined, color: Colors.blue, size: 28),
                      
                    // Event/Mantra Logo Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCoke ? 'mantra' : 'challenge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Title & Subtitle inside the banner
                Text(
                  event['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1F22),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isCoke
                      ? "Where tomorrow's business leaders are forged today."
                      : "A premium creative contest on Acadyk",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                // MBA / Criteria Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    isCoke ? 'Open to MBA Students' : 'Open to All Students',
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Geometric abstract graphics representation at bottom of banner
          _buildAbstractPattern(isCoke),
        ],
      ),
    );
  }

  Widget _buildAbstractPattern(bool isCoke) {
    return Container(
      height: 90,
      color: const Color(0xFFFFF7E6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left block: Red grid
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.red.shade600,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.arrow_upward, color: Colors.white, size: 24),
                  Icon(Icons.visibility_outlined, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
          // Middle block: Orange star
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFFFF9E1B),
              child: const Center(
                child: Icon(Icons.star, color: Colors.white, size: 36),
              ),
            ),
          ),
          // Right block: Teal layout
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFF00A3A6),
              child: const Center(
                child: Icon(Icons.arrow_forward, color: Colors.white, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 2: Main Info & Stats Card (Teal border line on top)
  Widget _buildInfoStatsCard(Map<String, dynamic> event) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teal Top Border block
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF007A87),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags and Actions Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, size: 14, color: Colors.blue.shade800),
                          const SizedBox(width: 4),
                          Text(
                            'Online',
                            style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.language, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 16),
                    Icon(Icons.favorite_border, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 16),
                    Icon(Icons.share_outlined, color: Colors.grey[600], size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Title and Logo Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1F22)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            event['organizer'],
                            style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Mantra red logo container
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.network(
                        event['logoUrl'],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.red.shade700,
                          alignment: Alignment.center,
                          child: const Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Team size & registered count stats
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.people_outline, color: Colors.blue.shade800, size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Team Size', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              Text(
                                event['teamSize'],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1F22), fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.ads_click, color: Colors.blue.shade800, size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Registered', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              Text(
                                '${_isRegistered ? event['registered'] + 1 : event['registered']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1F22), fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Somraj Lodhi Registration row
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('assets/images/somraj_avatar.jpg'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Somraj Lodhi',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1F22)),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'iitainsomraj701@gmail.com',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _isRegistered ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isRegistered ? 'Registered' : 'Not Registered',
                          style: TextStyle(
                            color: _isRegistered ? Colors.green.shade800 : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Prizes Banner
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFFFC107), size: 30),
                      Column(
                        children: [
                          const Text(
                            'Prizes worth',
                            style: TextStyle(color: Color(0xFF1E1F22), fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            event['prizes'],
                            style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Icon(Icons.emoji_events, color: Color(0xFFFFC107), size: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 3: Eligibility & Guidelines
  Widget _buildDescriptionCard(Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Eligibility'),
          const SizedBox(height: 8),
          Text(
            event['eligibility'],
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF333333), height: 1.4),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('All that you need to know'),
          const SizedBox(height: 8),
          Text(
            event['description'],
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF333333), height: 1.45),
          ),
        ],
      ),
    );
  }

  // Card 4: Stages and Timelines (Dashed line & custom circular node layout)
  Widget _buildStagesTimelineCard(List<Map<String, dynamic>> timeline, Map<String, dynamic> event) {
    final bool isCoke = event['title'].toString().contains('Coca-Cola');
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Stages and Timelines'),
          const SizedBox(height: 20),
          
          // Timeline stack list
          Column(
            children: [
              ...timeline.map((stage) {
                final int index = timeline.indexOf(stage);
                final bool isLast = index == timeline.length - 1 && !isCoke;
                return _buildStageTimelineRow(stage, isLast);
              }),
              if (isCoke)
                _buildStageTimelineRow({
                  'day': 'Inter',
                  'month': 'VIEWS',
                  'title': 'Interviews',
                  'startDate': '25 Jul 26, 09:00 AM IST',
                  'endDate': '10 Aug 26, 06:00 PM IST',
                  'desc': 'The final stage involves a personal interview with Senior Management at Coca-Cola India and Southwest Asia.'
                }, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageTimelineRow(Map<String, dynamic> stage, bool isLast) {
    final bool isLive = stage['isLive'] ?? false;
    final String day = stage['day'] ?? '1';
    final String month = stage['month'] ?? 'JAN';
    final String dateStr = '${stage['startDate']} → ${stage['endDate']}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left vertical timeline node track
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF007A87),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    Text(
                      month,
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          
          // Right content details block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range description text sitting above the card
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey[750], fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                
                // Timeline details Card
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stage['title']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E1F22)),
                            ),
                          ),
                          if (isLive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Live',
                                    style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stage['desc']!,
                        style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 5: Important dates & deadlines
  Widget _buildImportantDatesCard(List<Map<String, dynamic>> dates) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Important dates & deadlines?'),
          const SizedBox(height: 16),
          ...dates.map((date) => _buildDeadlineItem(date)),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(Map<String, dynamic> date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF007A87),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Text(
                  date['day']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  date['month']!,
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date['dateText']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E1F22)),
                ),
                const SizedBox(height: 1),
                Text(
                  date['title']!,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 6: Rewards and Prizes
  Widget _buildRewardsCard(List<Map<String, dynamic>> rewards) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Rewards and Prizes'),
          const SizedBox(height: 16),
          ...rewards.map((reward) => _buildPrizeCard(
            amount: reward['amount'],
            label: reward['label'],
            isMerch: reward['isMerch']
          )),
        ],
      ),
    );
  }

  Widget _buildPrizeCard({required String amount, required String label, bool isMerch = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: isMerch ? Colors.blue : Colors.greenAccent.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isMerch ? Colors.blue.shade50.withOpacity(0.2) : Colors.green.shade50.withOpacity(0.2),
                    Colors.white,
                  ],
                ),
              ),
              child: isMerch
                  ? const Center(child: Icon(Icons.redeem, color: Colors.blue, size: 28))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          amount,
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'CASH',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
            Container(width: 1, color: Colors.grey.shade200),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E1F22),
                      ),
                    ),
                    if (isMerch) ...[
                      const SizedBox(height: 2),
                      const Text(
                        'Exclusive Coca-Cola Merchandise.',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card 7: Feedback & Rating
  Widget _buildFeedbackRatingCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Feedback & Rating'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.edit_note_outlined, size: 32, color: Colors.grey[600]),
                const SizedBox(height: 6),
                const Text(
                  'Write a review',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1F22)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Register for this opportunity to give your feedback and review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 8: FAQs / Discussions
  Widget _buildFaqsCard(List<Map<String, String>> faqs) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('FAQs / Discussions'),
          const SizedBox(height: 12),
          
          // Tab bar headers
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _activeFaqTab = 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FAQs',
                      style: TextStyle(
                        color: _activeFaqTab == 0 ? Colors.blue.shade800 : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2.5,
                      width: 44,
                      color: _activeFaqTab == 0 ? Colors.blue.shade800 : Colors.transparent,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => setState(() => _activeFaqTab = 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discussions',
                      style: TextStyle(
                        color: _activeFaqTab == 1 ? Colors.blue.shade800 : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2.5,
                      width: 80,
                      color: _activeFaqTab == 1 ? Colors.blue.shade800 : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),

          if (_activeFaqTab == 0) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFaqCategoryChip('Registration'),
                  _buildFaqCategoryChip('Become a Coke Ambassador Round'),
                  _buildFaqCategoryChip('Trivia'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...faqs.map((faq) => FAQAccordion(question: faq['question']!, answer: faq['answer']!)),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No discussions yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          const Text(
            "Can't find the answer you are looking for?",
            style: TextStyle(color: Color(0xFF1E1F22), fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Ask a question (Be specific)',
              style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          _buildFooterInfoRow(Icons.access_time_outlined, 'Updated On: 26 Jun 26, 12:22 PM IST'),
          const SizedBox(height: 6),
          _buildFooterInfoRow(Icons.info_outline, 'The data on this page gets updated every 15 minutes.'),
          const SizedBox(height: 6),
          _buildFooterInfoRow(Icons.flag_outlined, 'Report An Issue', isAction: true),
        ],
      ),
    );
  }

  Widget _buildFaqCategoryChip(String title) {
    final bool isSelected = _selectedFaqCategory == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedFaqCategory = title),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.grey[50],
          border: Border.all(color: isSelected ? Colors.blue.shade800 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade800 : Colors.grey[800],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfoRow(IconData icon, String text, {bool isAction = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isAction ? Colors.red.shade800 : Colors.black54),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: isAction ? () {} : null,
          child: Text(
            text,
            style: TextStyle(
              color: isAction ? Colors.red.shade800 : Colors.black54,
              fontSize: 11.5,
              fontWeight: isAction ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // Footer: Breadcrumbs & Copyright branding (Replacing Unstop with Acadyk)
  Widget _buildBreadcrumbsAndFooter(Map<String, dynamic> event) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.home_outlined, size: 14, color: Colors.grey[600]),
              Text(' / Competition / ', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              Expanded(
                child: Text(
                  event['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  'Powered By',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                // Acadyk Logo representation
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Acadyk',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Best Viewed in Chrome, Opera, Mozilla, EDGE & Safari. Copyright ©\n2026 FLIVE Consulting Pvt Ltd - All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 9.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomRegisterBar(Map<String, dynamic> event) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "5 Days Left" floating center tab badge
          Transform.translate(
            offset: const Offset(0, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Text(
                '5 Days Left',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          // Main Register Button
          ElevatedButton(
            onPressed: _isRegistered
                ? null
                : () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RegistrationFormScreen(
                          eventTitle: event['title'],
                          logoUrl: event['logoUrl'],
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _isRegistered = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Successfully Registered!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007A87),
              disabledBackgroundColor: Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Center(
              child: Text(
                _isRegistered ? 'Registered' : 'Register',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Expandable FAQ Accordion Widget
class FAQAccordion extends StatefulWidget {
  final String question;
  final String answer;

  const FAQAccordion({super.key, required this.question, required this.answer});

  @override
  State<FAQAccordion> createState() => _FAQAccordionState();
}

class _FAQAccordionState extends State<FAQAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            widget.question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E1F22),
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.remove : Icons.add,
            color: Colors.black54,
            size: 18,
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.answer,
                style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.35),
              ),
            ),
          ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}
