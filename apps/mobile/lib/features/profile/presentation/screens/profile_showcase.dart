import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/profile_manager.dart';

class ProfileShowcaseScreen extends StatefulWidget {
  const ProfileShowcaseScreen({super.key});

  @override
  State<ProfileShowcaseScreen> createState() => _ProfileShowcaseScreenState();
}

class _ProfileShowcaseScreenState extends State<ProfileShowcaseScreen> {
  @override
  Widget build(BuildContext context) {
    const Color bgColor = Colors.white;
    const Color textColor = Color(0xFF0F172A);
    const Color secondaryTextColor = Color(0xFF64748B);
    const Color surfaceColor = Color(0xFFF8FAFC);
    const Color borderColor = Color(0xFFE2E8F0);

    final activeBanners = ProfileManager.showcaseBanners;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Banners',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: On your profile
              const Text(
                'On your profile',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              if (activeBanners.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: activeBanners.map((banner) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            banner['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                ProfileManager.removeShowcaseBanner(banner['type'] ?? '');
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Removed "${banner['title']}" banner'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: const Color(0xFF0F172A),
                                ),
                              );
                            },
                            child: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: const Text(
                    'No banners added yet. Choose an option below to showcase on your profile.',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ),

              const SizedBox(height: 36),

              // HERO SECTION
              const Text(
                'Say more with banners',
                style: TextStyle(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share more about who you are, your academic affiliations, and what you care about. This helps others discover similar interests and connect with you.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14.5,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 36),

              // SECTION 2: Add to profile
              const Text(
                'Add to profile',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Mentor
              _buildAddOptionTile(
                title: 'Mentor',
                subtitle: 'Faculty mentor name & department',
                onTap: () => _showInputDialog(
                  title: 'Faculty Mentor',
                  hint: 'e.g. Dr. R. K. Shrivastava (Faculty Mentor)',
                  initialValue: ProfileManager.mentorFaculty,
                  onSave: (val) {
                    ProfileManager.mentorFaculty = val;
                    ProfileManager.addShowcaseBanner({
                      'type': 'mentor',
                      'title': 'Mentor: $val',
                      'subtitle': 'Faculty Mentor',
                    });
                    setState(() {});
                  },
                ),
              ),

              // 2. Class Coordinator
              _buildAddOptionTile(
                title: 'Class coordinator',
                subtitle: 'Class / batch faculty coordinator',
                onTap: () => _showInputDialog(
                  title: 'Class Coordinator',
                  hint: 'e.g. Prof. Amit Sharma (CSE Coordinator)',
                  initialValue: '',
                  onSave: (val) {
                    ProfileManager.addShowcaseBanner({
                      'type': 'coordinator',
                      'title': 'Coordinator: $val',
                      'subtitle': 'Class Coordinator',
                    });
                    setState(() {});
                  },
                ),
              ),

              // 3. Club Designation
              _buildAddOptionTile(
                title: 'Club designation',
                subtitle: 'Student club, chapter or team role',
                onTap: () => _showInputDialog(
                  title: 'Club Designation',
                  hint: 'e.g. President, Robotics Club',
                  initialValue: '',
                  onSave: (val) {
                    ProfileManager.addShowcaseBanner({
                      'type': 'club',
                      'title': val,
                      'subtitle': 'Club Role',
                    });
                    setState(() {});
                  },
                ),
              ),

              // 4. WhatsApp / Social
              _buildAddOptionTile(
                title: 'WhatsApp / Social',
                subtitle: 'Direct messaging or community link',
                onTap: () => _showInputDialog(
                  title: 'WhatsApp / Social Link',
                  hint: 'e.g. wa.me/919876543210 or @with.smrj',
                  initialValue: '',
                  onSave: (val) {
                    ProfileManager.addShowcaseBanner({
                      'type': 'social',
                      'title': val,
                      'subtitle': 'Social / Chat',
                    });
                    setState(() {});
                  },
                ),
              ),

              // 5. Fill in the blank
              _buildAddOptionTile(
                title: 'Fill in the blank',
                subtitle: 'Custom highlight or personal motto',
                onTap: () => _showInputDialog(
                  title: 'Custom Showcase',
                  hint: 'e.g. Open to collaborate on AI projects',
                  initialValue: '',
                  onSave: (val) {
                    ProfileManager.addShowcaseBanner({
                      'type': 'custom',
                      'title': val,
                      'subtitle': 'Custom Highlight',
                    });
                    setState(() {});
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOptionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.plus_circle,
                  color: Color(0xFF0F172A),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFF94A3B8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInputDialog({
    required String title,
    required String hint,
    required String initialValue,
    required Function(String) onSave,
  }) {
    final TextEditingController controller = TextEditingController(text: initialValue);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Add $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final val = controller.text.trim();
                      if (val.isNotEmpty) {
                        onSave(val);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$title added to your profile showcase!'),
                            backgroundColor: const Color(0xFF10B981),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save to Profile',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
