import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'registration_form_screen.dart';
import 'home_feed_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? eventData;

  const EventDetailScreen({super.key, this.eventData});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isRegistered = false;
  int _activeFaqTab = 0; // 0 for FAQs, 1 for Discussions
  String _selectedCategory = 'Registration';
  final Set<int> _expandedIndices = {};

  final List<String> _categories = [
    'Registration',
    'Become a Coke Ambassador Round',
    'Trivia & Rounds',
    'Eligibility',
    'General',
  ];

  final List<Map<String, String>> _faqList = [
    {
      'question': 'How can I participate in this competition?',
      'answer': 'You can participate by clicking the "Register" button above. The registration is completely online and free of cost.',
      'category': 'Registration',
    },
    {
      'question': 'Is this competition open to students from all universities and courses?',
      'answer': 'This challenge is specifically open for students, developers, and AI enthusiasts across all recognized universities and courses globally.',
      'category': 'Eligibility',
    },
    {
      'question': 'Is there a registration fee for participating in this competition?',
      'answer': 'No, there are no registration fees or hidden charges associated with participating in the hackathon.',
      'category': 'Registration',
    },
    {
      'question': 'What details should I fill in if I am an upcoming/admitted MBA student?',
      'answer': 'Please enter your current college name, your program details, your admission roll/reg number, and complete the profile details on Acadyk.',
      'category': 'Registration',
    },
    {
      'question': 'I am in waitlist and might convert to another college. How can I proceed?',
      'answer': 'You can register with your primary target/current college. If your admission details change later, you can write to support@acadyk.com to update your details.',
      'category': 'Become a Coke Ambassador Round',
    },
    {
      'question': 'How can I delete my registration from this opportunity?',
      'answer': 'To cancel or delete your registration, click the "Registered ✓" button above to toggle your status, or contact support directly.',
      'category': 'Registration',
    },
    {
      'question': 'I am unable to verify my phone number. What should I do?',
      'answer': 'Ensure your network connection is stable. If you do not receive the OTP, try resending in 2 minutes, or request assistance via support channels.',
      'category': 'General',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final event = widget.eventData ?? {};
    final String title = event['title'] ?? 'SLAB Hackathon -\nMITS (Gwalior)';
    final String dates = event['dates'] ?? 'Saturday 22 August';
    final String locationName = event['location'] ?? 'Madhav Institute of Technology & Science, Gwalior';
    final String locationCity = event['locationCity'] ?? 'Gwalior, Madhya Pradesh';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            color: Colors.white,
            child: Column(
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.back, color: Color(0xFF111827), size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          title.replaceAll('\n', ' - '),
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.share, color: Color(0xFF4B5563), size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link copied to clipboard!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Main Title
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 2. Date and Time Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'AUG',
                                          style: TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          '22',
                                          style: TextStyle(
                                            color: Color(0xFF111827),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dates.contains('Saturday') ? dates : 'Saturday 22 August',
                                          style: const TextStyle(
                                            color: Color(0xFF111827),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          '10:00 - 17:00',
                                          style: TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // 3. Location Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.location,
                                      color: Color(0xFF4B5563),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                locationName,
                                                style: const TextStyle(
                                                  color: Color(0xFF111827),
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.north_east,
                                              color: Color(0xFF6B7280),
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          locationCity,
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // 4. Registration Box
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(13),
                                          topRight: Radius.circular(13),
                                        ),
                                      ),
                                      child: const Text(
                                        'Registration',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            _isRegistered
                                                ? '🎉 You are registered for this event!'
                                                : 'Welcome! To join the event, please register below.',
                                            style: TextStyle(
                                              color: _isRegistered ? const Color(0xFF166534) : const Color(0xFF374151),
                                              fontSize: 14,
                                              fontWeight: _isRegistered ? FontWeight.w600 : FontWeight.normal,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (_isRegistered) {
                                                setState(() {
                                                  _isRegistered = false;
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Registration cancelled.'),
                                                    backgroundColor: Color(0xFF374151),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => RegistrationFormScreen(
                                                      eventId: event['id']?.toString() ?? 'slab-mits-2025',
                                                      eventTitle: title.replaceAll('\n', ' - '),
                                                      logoUrl: event['logoUrl'] ?? 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=150',
                                                      organizer: event['organizer'] ?? 'Madhav Institute of Technology & Science, Gwalior',
                                                    ),
                                                  ),
                                                ).then((result) {
                                                  if (result == true) {
                                                    setState(() {
                                                      _isRegistered = true;
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _isRegistered ? const Color(0xFF16A34A) : const Color(0xFF111827),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text(
                                              _isRegistered ? 'Registered ✓' : 'Register',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // 5. About Event Section
                              const Text(
                                'About Event',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                              const SizedBox(height: 16),

                              _buildContentBlock(
                                'Gwalior, we\'re bringing SLAB to MITS!\n\n'
                                'SLAB Self-Learning Agent Browser is a hands-on hackathon hosted by webcmd, where you\'ll build Browser Agents that can research, test, monitor, book, shop, and complete useful work across real websites.\n\n'
                                'Come with an idea, join a team, or build solo. No prior browser-automation experience is required. We\'ll begin with a practical Browser Agents 101 walkthrough so everyone can start building quickly.',
                              ),

                              _buildSectionHeader('THE THEME: BROWSER AGENTS'),
                              _buildContentBlock('Build an agent that solves a meaningful, real-world browser workflow.'),

                              _buildSectionHeader('BUILD WITH WEBCMD'),
                              _buildContentBlock(
                                'webcmd is self-learning browser infrastructure for AI agents.\n\n'
                                'Your agent can explore an unfamiliar website, preserve what it learns, and transform stable workflows into reliable commands with structured output.\n\n'
                                'Explore once. Learn the workflow. Reuse the command.',
                              ),

                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(color: Color(0xFF374151), fontSize: 14, height: 1.5),
                                    children: [
                                      TextSpan(text: 'Get started: • '),
                                      TextSpan(
                                        text: 'https://github.com/agentrhq/webcmd?utm_source=luma',
                                        style: TextStyle(
                                          color: Color(0xFF2563EB),
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              _buildContentBlock('The webcmd team will be there to help with setup, browser workflows, adapters, and debugging.'),

                              _buildSectionHeader('🛠️ BRING YOUR PREFERRED STACK'),
                              _buildContentBlock('Use Codex, Claude Code, OpenClaw, Playwright, Browser Use, browser MCPs, local or hosted models, and any other tools that help your agent complete the job.'),

                              _buildSectionHeader('⚖️ JUDGING 100 POINTS'),
                              _buildContentBlock('🟢 Live reliability: 30  💡 Real-world usefulness: 25  🧠 Technical depth and recovery: 20  ✨ Creativity: 15  🎤 Demo and storytelling: 10'),

                              _buildSectionHeader('🚨 TWO HARD RULES'),
                              _buildContentBlock(
                                'Your demo must run live or use a screen recording captured from a real execution.\n\n'
                                'Build responsibly. Use your own accounts, respect platform terms, and keep a human approval step for payments, messages, submissions, deletions, and other sensitive actions.',
                              ),

                              _buildBulletPoint('👥 Build solo or form a team of up to four.'),
                              _buildBulletPoint('🎒 Bring a laptop, your preferred model or API keys if you have them, and one browser workflow you\'d love to stop doing manually.'),
                              _buildBulletPoint('🙌 Open to AI-agent builders, developers, students, founders, open-source contributors, automation enthusiasts, and anyone curious about giving agents useful access to the real web.'),
                              _buildBulletPoint('No prior webcmd or browser-automation experience is needed.'),
                              _buildBulletPoint('📍 Madhav Institute of Technology & Science, Gwalior'),
                              _buildBulletPoint('Spots are limited. Hit RSVP and bring a friend who builds.'),

                              const SizedBox(height: 32),
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                              const SizedBox(height: 16),

                              // Location Section
                              const Text(
                                'Location',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Bangalore, India\nIn-person',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                locationCity,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider between sections
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),

                        // Second Page: FAQs / Discussions Section (Matching clean white UI)
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Header with green/teal bar
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00796B),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'FAQs / Discussions',
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // 2. Tabs: FAQs / Discussions
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() => _activeFaqTab = 0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'FAQs',
                                          style: TextStyle(
                                            color: _activeFaqTab == 0 ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: 2.5,
                                          width: 42,
                                          color: _activeFaqTab == 0 ? const Color(0xFF2563EB) : Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  GestureDetector(
                                    onTap: () => setState(() => _activeFaqTab = 1),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Discussions',
                                          style: TextStyle(
                                            color: _activeFaqTab == 1 ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: 2.5,
                                          width: 80,
                                          color: _activeFaqTab == 1 ? const Color(0xFF2563EB) : Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                              const SizedBox(height: 16),

                              // 3. Category Filter Chips (horizontal scroll)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _categories.map((cat) {
                                    final isSelected = _selectedCategory == cat;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedCategory = cat),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                                              width: 1.2,
                                            ),
                                          ),
                                          child: Text(
                                            cat,
                                            style: TextStyle(
                                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF374151),
                                              fontSize: 13,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 4. Accordion List of FAQs
                              ..._faqList.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final faq = entry.value;
                                final isExpanded = _expandedIndices.contains(idx);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isExpanded) {
                                            _expandedIndices.remove(idx);
                                          } else {
                                            _expandedIndices.add(idx);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                faq['question']!,
                                                style: const TextStyle(
                                                  color: Color(0xFF1F2937),
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.35,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              isExpanded ? Icons.remove : Icons.add,
                                              color: const Color(0xFF6B7280),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isExpanded)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0, right: 16.0),
                                        child: Text(
                                          faq['answer']!,
                                          style: const TextStyle(
                                            color: Color(0xFF4B5563),
                                            fontSize: 13.5,
                                            height: 1.45,
                                          ),
                                        ),
                                      ),
                                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                                  ],
                                );
                              }),

                              const SizedBox(height: 24),

                              // 5. Help / Footer notes
                              const Text(
                                'Can\'t find the answer you are looking for?',
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Support team notified! We will get back to you shortly.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Ask a question (Be specific)',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Timestamp & metadata
                              Row(
                                children: const [
                                  Icon(Icons.access_time, color: Color(0xFF9CA3AF), size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Updated On: 26 Jun 26, 12:22 PM IST',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Icon(Icons.info_outline, color: Color(0xFF9CA3AF), size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'The data on this page gets updated every 15 minutes.',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ReportPostScreen(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: const [
                                    Icon(Icons.outlined_flag, color: Color(0xFFDC2626), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Report An Issue',
                                      style: TextStyle(
                                        color: Color(0xFFDC2626),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildContentBlock(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 13.8,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 13.8,
          height: 1.45,
        ),
      ),
    );
  }
}
