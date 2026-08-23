import 'package:flutter/material.dart';
import 'create_quiz_poll_screen.dart';
import 'create_opportunity_screen.dart';
import 'create_team_screen.dart';

class SelectOpportunityScreen extends StatelessWidget {
  const SelectOpportunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Colors.white;
    const Color textColor = Color(0xFF111827);
    const Color textSecondary = Color(0xFF6B7280);
    const Color borderCol = Color(0xFFE5E7EB);

    final List<Map<String, dynamic>> items = [
      {
        'title': 'Quizzes',
        'subtitle': 'Assess domain knowledge efficiently',
        'icon': Icons.add,
        'iconColor': const Color(0xFF4B5563),
        'bgColor': const Color(0xFFF3F4F6),
      },
      {
        'title': 'Hackathons & Coding Challenges',
        'subtitle': 'Evaluate technical skills and abilities in action',
        'icon': Icons.code, // displays as a code terminal bracket style
        'iconColor': const Color(0xFF10B981),
        'bgColor': const Color(0xFFECFDF5),
      },
      {
        'title': 'Create Team',
        'subtitle': 'Build and invite members for hackathons & competitions',
        'icon': Icons.groups_outlined,
        'iconColor': const Color(0xFF0284C7),
        'bgColor': const Color(0xFFE0F2FE),
      },
      {
        'title': 'Webinars, Conferences & Workshops',
        'subtitle': 'Engage with potential candidates through hosting',
        'icon': Icons.edit_note_outlined,
        'iconColor': const Color(0xFF3B82F6),
        'bgColor': const Color(0xFFEFF6FF),
      },
      {
        'title': 'Cultural Events',
        'subtitle': 'Invite candidates to your college festivals',
        'icon': Icons.language_outlined, // represents globe or community
        'iconColor': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFFFBEB),
      },
      {
        'title': 'Scholarships & Internships',
        'subtitle': 'Provide financial support and work options',
        'icon': Icons.workspace_premium_outlined,
        'iconColor': const Color(0xFF8B5CF6),
        'bgColor': const Color(0xFFF5F3FF),
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Select Opportunity',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final title = item['title'] as String;
                    if (title == 'Quizzes') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateQuizPollScreen(),
                        ),
                      );
                    } else if (title == 'Hackathons & Coding Challenges') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateOpportunityScreen(
                            initialType: 'Hackathons & Coding Challenges',
                          ),
                        ),
                      );
                    } else if (title == 'Create Team') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTeamScreen(),
                        ),
                      );
                    } else if (title == 'Webinars, Conferences & Workshops') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateOpportunityScreen(
                            initialType: 'Webinars, Conferences & Workshops',
                          ),
                        ),
                      );
                    } else if (title == 'Cultural Events') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateOpportunityScreen(
                            initialType: 'Cultural Events',
                          ),
                        ),
                      );
                    } else if (title == 'Scholarships & Internships') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateOpportunityScreen(
                            initialType: 'Scholarships & Internships',
                          ),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Row(
                      children: [
                        // Left Icon Box
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: item['bgColor'] as Color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderCol, width: 0.8),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['iconColor'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title and Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['subtitle'] as String,
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
