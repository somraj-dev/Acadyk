import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_manager.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _selectedCategoryIndex = 0;
  int _selectedRating = 4; // 1 to 5
  String _selectedSeverity = 'Medium';
  String _selectedScreen = 'Home Feed';
  bool _isSubmitting = false;
  final List<String> _selectedQuickTags = [];
  final List<XFile> _attachedImages = [];

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'App Crash / Freeze',
      'icon': Icons.flash_on_rounded,
      'color': Color(0xFFEF4444),
      'desc': 'App crashed unexpectedly, screen froze, or stopped responding',
      'tags': ['Page Crashed', 'Black Screen', 'Frozen Screen', 'Force Closed', 'Memory Lag'],
    },
    {
      'title': 'Feed & Post Glitches',
      'icon': Icons.dynamic_feed_rounded,
      'color': Color(0xFFF59E0B),
      'desc': 'Posts not loading, like/comment errors, image display issues',
      'tags': ['Like Not Working', 'Comments Missing', 'Image Not Loading', 'Duplicate Posts', 'Post Creation Error'],
    },
    {
      'title': 'Chat & Community',
      'icon': Icons.forum_rounded,
      'color': Color(0xFF6366F1),
      'desc': 'Messages delayed, notification issues, club/space glitches',
      'tags': ['Message Failed', 'Notifications Delay', 'Club Error', 'Space Disconnect', 'Unread Badge Bug'],
    },
    {
      'title': 'Account & Profile',
      'icon': Icons.person_rounded,
      'color': Color(0xFF3B82F6),
      'desc': 'Avatar sync, status update, login/auth, or settings issues',
      'tags': ['Avatar Not Updating', 'Status Ring Issue', 'Bio Not Saving', 'Login Issue', 'Roll No Error'],
    },
    {
      'title': 'Performance & Speed',
      'icon': Icons.speed_rounded,
      'color': Color(0xFF10B981),
      'desc': 'Slow page transitions, stuttering animations, high battery usage',
      'tags': ['Slow Loading', 'Stuttering Scroll', 'High Battery Drain', 'Heavy Data Usage'],
    },
    {
      'title': 'Feature Suggestion',
      'icon': Icons.lightbulb_rounded,
      'color': Color(0xFF8B5CF6),
      'desc': 'Ideas, new features, or enhancements you would love to see',
      'tags': ['UI Improvement', 'New Tool Request', 'Accessibility Feature', 'Dark Mode Tweak', 'Export Option'],
    },
    {
      'title': 'General Feedback',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFEC4899),
      'desc': 'Tell us what you like or how your overall experience has been',
      'tags': ['Overall UX', 'Design Polish', 'Navigation Ease', 'College Integration'],
    },
  ];

  final List<String> _affectedScreens = [
    'Home Feed',
    'Profile & Status',
    'Startup Gallery',
    'Clubs & Spaces',
    'Direct Messages',
    'Exhibition',
    'My Courses',
    'Notifications',
    'Settings',
    'Other / Whole App',
  ];

  final List<Map<String, String>> _ratingMoods = [
    {'emoji': '😡', 'label': 'Frustrated'},
    {'emoji': '😕', 'label': 'Poor'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '😊', 'label': 'Good'},
    {'emoji': '🤩', 'label': 'Great!'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() {
          _attachedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not attach image: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedQuickTags.contains(tag)) {
        _selectedQuickTags.remove(tag);
      } else {
        _selectedQuickTags.add(tag);
      }
    });
  }

  Future<void> _submitFeedback() async {
    if (_descriptionController.text.trim().isEmpty && _titleController.text.trim().isEmpty && _selectedQuickTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a brief description or select issue tags.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate sending report to backend / bug tracker
    await Future.delayed(const Duration(milliseconds: 1100));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    final ticketId = '#ACAD-BUG-${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}';
    _showSuccessBottomSheet(ticketId);
  }

  void _showSuccessBottomSheet(String ticketId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Feedback Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you, ${ProfileManager.name}! Your report has been dispatched to the Acadyk engineering & QA team.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSub,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 18, color: textSub),
                    const SizedBox(width: 8),
                    Text(
                      'Ticket Reference: $ticketId',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textMain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Close bottom sheet
                    Navigator.of(context).pop(); // Return to previous screen
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textMain = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final currentCategory = _categories[_selectedCategoryIndex];
    final bool isBugOrCrash = _selectedCategoryIndex <= 4;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: textMain, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Feedback & Bug Report',
          style: TextStyle(
            color: textMain,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Form',
            icon: Icon(Icons.refresh_rounded, color: textSub, size: 22),
            onPressed: () {
              setState(() {
                _titleController.clear();
                _descriptionController.clear();
                _selectedQuickTags.clear();
                _attachedImages.clear();
                _selectedRating = 4;
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                children: [
                  // 1. Header Banner
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                            : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text('🚀', style: TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Help Us Improve Acadyk',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Encountered an app crash, visual glitch, or have an idea? Your feedback directly reaches our dev team.',
                                style: TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Select Category Title
                  _buildSectionHeader('1. What kind of feedback is this?', textMain),
                  const SizedBox(height: 10),

                  // Category Cards Grid / List
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_categories.length, (index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategoryIndex == index;
                      final Color catColor = cat['color'];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                            _selectedQuickTags.clear();
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? catColor.withValues(alpha: isDark ? 0.25 : 0.12)
                                : cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? catColor : borderColor,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 18,
                                color: isSelected ? catColor : textSub,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat['title'] as String,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? (isDark ? Colors.white : catColor) : textMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      currentCategory['desc'] as String,
                      style: TextStyle(fontSize: 12.5, color: textSub, fontStyle: FontStyle.italic),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 3. Quick Issue Tags
                  if ((currentCategory['tags'] as List).isNotEmpty) ...[
                    _buildSectionHeader('Common Topics (Tap to select)', textMain),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (currentCategory['tags'] as List<String>).map((tag) {
                        final isSelected = _selectedQuickTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (_) => _toggleTag(tag),
                          selectedColor: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.6 : 0.9),
                          backgroundColor: cardBg,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.white : textMain,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF0F172A) : borderColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                  ],

                  // 4. Affected Area / Screen & Severity
                  Row(
                    children: [
                      // Affected Screen Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Affected Section', textMain),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedScreen,
                                  dropdownColor: cardBg,
                                  icon: Icon(Icons.arrow_drop_down_rounded, color: textSub),
                                  style: TextStyle(color: textMain, fontSize: 13.5, fontWeight: FontWeight.w500),
                                  items: _affectedScreens.map((screen) {
                                    return DropdownMenuItem(
                                      value: screen,
                                      child: Text(screen, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedScreen = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isBugOrCrash) ...[
                        const SizedBox(width: 12),
                        // Severity Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Severity Level', textMain),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _selectedSeverity,
                                    dropdownColor: cardBg,
                                    icon: Icon(Icons.arrow_drop_down_rounded, color: textSub),
                                    style: TextStyle(
                                      color: _getSeverityColor(_selectedSeverity),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    items: ['Low', 'Medium', 'High', 'Critical'].map((sev) {
                                      return DropdownMenuItem(
                                        value: sev,
                                        child: Text(sev),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedSeverity = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 5. Satisfaction / Mood Rating
                  _buildSectionHeader('2. Rate your recent experience with Acadyk', textMain),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(_ratingMoods.length, (idx) {
                        final ratingValue = idx + 1;
                        final isSelected = _selectedRating == ratingValue;
                        final mood = _ratingMoods[idx];

                        return InkWell(
                          onTap: () => setState(() => _selectedRating = ratingValue),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0F172A).withValues(alpha: isDark ? 0.4 : 0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  mood['emoji']!,
                                  style: TextStyle(
                                    fontSize: isSelected ? 28 : 22,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mood['label']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? textMain : textSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 6. Issue Title & Description Form
                  _buildSectionHeader('3. Issue Summary & Description', textMain),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                          child: TextField(
                            controller: _titleController,
                            style: TextStyle(color: textMain, fontSize: 14.5, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Brief summary (e.g. Page crashed when refreshing feed)',
                              hintStyle: TextStyle(color: textSub.withValues(alpha: 0.8), fontSize: 13.5, fontWeight: FontWeight.normal),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Divider(height: 1, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: 5,
                            minLines: 3,
                            style: TextStyle(color: textMain, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Please share details: What happened? What were you trying to do? Any error messages seen?',
                              hintStyle: TextStyle(color: textSub.withValues(alpha: 0.8), fontSize: 13.5),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 7. Attachments & Screenshots
                  _buildSectionHeader('4. Screenshots or Screen Recording (Optional)', textMain),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_attachedImages.isNotEmpty) ...[
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _attachedImages.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (ctx, index) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.black26 : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: borderColor),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.image_outlined, color: Colors.blueAccent, size: 30),
                                    ),
                                    Positioned(
                                      top: -6,
                                      right: -6,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: borderColor,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, color: textSub, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _attachedImages.isEmpty
                                      ? 'Add Screenshot or Image'
                                      : 'Add Another Screenshot (${_attachedImages.length})',
                                  style: TextStyle(
                                    color: textMain,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 8. Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Submitting Report...',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.send_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Feedback',
                                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.1,
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical':
        return const Color(0xFFEF4444);
      case 'High':
        return const Color(0xFFF97316);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'Low':
      default:
        return const Color(0xFF10B981);
    }
  }
}
