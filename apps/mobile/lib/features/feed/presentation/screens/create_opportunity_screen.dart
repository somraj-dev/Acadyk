import 'package:flutter/material.dart';
import '../services/opportunities_manager.dart';

class CreateOpportunityScreen extends StatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  State<CreateOpportunityScreen> createState() => _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  int _currentStep = 1; // Step 1: Opportunity details, Step 2: Registration Form

  // Form Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _orgController = TextEditingController(text: 'Madhav Institute of Technology and Science');
  final TextEditingController _festivalController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descController = TextEditingController(
    text: 'This field helps you to mention the details of the opportunity you are listing. It is better to include Rules, Eligibility, Process, Format, etc., in order to get the opportunity approved. The more details, the better!\n\n'
        'Guidelines:\n'
        '• Mention all the guidelines like eligibility, format, etc.\n'
        '• Inter-college team members allowed or not.\n'
        '• Inter-specialization team members allowed or not.\n'
        '• The number of questions/problem statements in each round.'
  );
  final TextEditingController _skillsController = TextEditingController();

  // Selected dropdown options
  String _selectedType = 'Hackathons & Coding Challenges';
  String _selectedSubType = 'Online Coding Challenge';

  // Toggle states matching screenshots
  bool _isTeamParticipation = true;
  int _minTeamSize = 1;
  int _maxTeamSize = 2;
  bool _isOnline = true;

  // Step 2 checklist eligibility
  final Set<String> _selectedEligibility = {'Everyone can apply'};

  void _generateAIDescription() {
    setState(() {
      _descController.text =
          'This field helps you to mention the details of the opportunity you are listing. It is better to include Rules, Eligibility, Process, Format, etc., in order to get the opportunity approved. The more details, the better!\n\n'
          'Guidelines:\n'
          '• Mention all the guidelines like eligibility, format, etc.\n'
          '• Inter-college team members allowed or not.\n'
          '• Inter-specialization team members allowed or not.\n'
          '• The number of questions/problem statements in the rounds.';
    });
  }

  void _finishCreation() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opportunity Title is required.')),
      );
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    // Build opportunity object
    final newOpportunity = {
      'title': _titleController.text,
      'logoUrl': 'assets/images/mits_logo.png', // Native local asset path
      'bannerUrl': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&auto=format&fit=crop',
      'organizer': _orgController.text,
      'timeAgo': 'Just now',
      'tagline': _descController.text.split('\n').first,
      'dates': '10-12 October 2025\nFri, 10:00 AM',
      'location': _isOnline ? 'Online\nAcadyk Sandbox' : 'Campus\nIn-person',
      'teamSizeText': _isTeamParticipation
          ? '$_minTeamSize-$_maxTeamSize Members\nTeam Size'
          : 'Individual\nParticipation',
      'tags': [
        _isOnline ? 'Online' : 'Offline',
        _isTeamParticipation ? 'Team Event' : 'Individual',
        'Hackathon',
        'Open to All'
      ],
      'prizePool': '₹ 1,50,000',
      'likes': 0,
      'comments': 0,
      'event': {
        'title': _titleController.text,
        'organizer': _orgController.text,
        'bannerUrl': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&auto=format&fit=crop',
        'logoUrl': 'assets/images/mits_logo.png',
        'teamSize': _isTeamParticipation ? 'Team ($_minTeamSize-$_maxTeamSize Members)' : 'Individual',
        'registered': 1,
        'prizes': 'Prizes worth ₹ 1,50,000 + certificates',
        'eligibility': _selectedEligibility.join(', '),
        'description': _descController.text.isNotEmpty
            ? _descController.text
            : 'Join our special challenge to solve high impact developer questions.',
        'timeline': [
          {
            'day': '10',
            'month': 'OCT',
            'title': 'Hackathon Challenge Starts',
            'startDate': '10 Oct 25, 10:00 AM IST',
            'endDate': '12 Oct 25, 11:59 PM IST',
            'isLive': true,
            'desc': 'Access problem statement and submit solution prototype.'
          }
        ]
      }
    };

    OpportunitiesManager.addOpportunity(newOpportunity);

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Opportunity Posted!'),
            ],
          ),
          content: Text(
            'Your opportunity "${_titleController.text}" has been successfully announced!\n\n'
            'It will now appear instantly at the top of the "Discover Opportunities" page.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close CreateOpportunityScreen
                Navigator.pop(context); // Close SelectOpportunityScreen
              },
              child: const Text('Go to Opportunities', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF111827);
    const Color borderCol = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
        titleSpacing: 16,
        title: const Text(
          'Post an Opportunity',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.close, color: textColor, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // STEPPER INDICATOR ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  _buildStepIndicator(1, 'Opportunity details', active: _currentStep == 1),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('---', style: TextStyle(color: Color(0xFFD1D5DB))),
                        ],
                      ),
                    ),
                  ),
                  _buildStepIndicator(2, 'Registration Form', active: _currentStep == 2),
                ],
              ),
            ),
            const Divider(height: 1, color: borderCol),

            // FORM BODY (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: _currentStep == 1 ? _buildDetailsStep() : _buildRegistrationStep(),
              ),
            ),

            // FOOTER ACTION ROW
            const Divider(height: 1, color: borderCol),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: Colors.white,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opportunity saved as draft.')),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Save as Draft',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentStep == 1) {
                        if (_titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opportunity Title is required.')),
                          );
                          return;
                        }
                        setState(() {
                          _currentStep = 2;
                        });
                      } else {
                        _finishCreation();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentStep == 1 ? 'Save and next' : 'Finish',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int number, String label, {required bool active}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0066FF) : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF4B5563),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF111827) : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Opportunity Details Layout
  // ---------------------------------------------------------------------------
  Widget _buildDetailsStep() {
    const Color textColor = Color(0xFF111827);
    const Color textSecondary = Color(0xFF6B7280);
    const Color borderCol = Color(0xFFE5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // STACKED LOGO UPLOAD AREA
        SizedBox(
          height: 150,
          child: Stack(
            children: [
              // Blue gradient header card
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF60A5FA), Color(0xFF93C5FD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              // Floating logo box
              Positioned(
                bottom: 10,
                left: 16,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              'assets/images/mits_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Change Logo blue banner
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ready to upload a custom logo image!')),
                            );
                          },
                          child: Container(
                            height: 24,
                            width: double.infinity,
                            color: const Color(0xFF0066FF),
                            alignment: Alignment.center,
                            child: const Text(
                              'Change Logo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Text description on the right of the logo box
              const Positioned(
                bottom: 30,
                left: 122,
                right: 16,
                child: Text(
                  'Supported logo image JPG, JPEG, or PNG. Max 1 MB',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 1. Opportunity Title
        const Row(
          children: [
            Text(
              'Opportunity Title',
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(_titleController, 'Enter Opportunity Title.'),
        const SizedBox(height: 4),
        const Text(
          'Max 190 characters',
          style: TextStyle(color: textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // 2. Organisation Name
        Row(
          children: [
            const Text(
              'Organisation Name',
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Icon(Icons.info_outline, color: textSecondary.withOpacity(0.7), size: 16),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(_orgController, 'Organisation Name'),
        const SizedBox(height: 20),

        // 3. Opportunity Type
        const Row(
          children: [
            Text(
              'Opportunity Type',
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          currentValue: _selectedType,
          items: ['Hackathons & Coding Challenges', 'Quizzes', 'Webinars', 'Cultural Events'],
          onChanged: (val) => setState(() => _selectedType = val!),
        ),
        const SizedBox(height: 20),

        // 4. Opportunity Sub-type
        const Row(
          children: [
            Text(
              'Opportunity Sub-type',
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          currentValue: _selectedSubType,
          items: ['Online Coding Challenge', 'Hackathon Sprint', 'Designathon', 'Ideathon'],
          onChanged: (val) => setState(() => _selectedSubType = val!),
        ),
        const SizedBox(height: 20),

        // 5. Link Festival/Campaign
        Row(
          children: [
            const Text(
              'Link Festival/Campaign',
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Icon(Icons.info_outline, color: textSecondary.withOpacity(0.7), size: 16),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(_festivalController, 'Enter Festival/campaign...'),
        const SizedBox(height: 20),

        // 6. Company Website URL
        Row(
          children: [
            const Text(
              'Company Website URL',
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Icon(Icons.info_outline, color: textSecondary.withOpacity(0.7), size: 16),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(_websiteController, 'https:// Company Website...'),
        const SizedBox(height: 28),

        // =============================================
        // SECTION: About the Opportunity
        // =============================================
        const Text(
          'About the Opportunity',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header description row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Opportunity Description',
                        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: textSecondary, size: 18),
                        onPressed: () => setState(() => _descController.clear()),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _generateAIDescription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4C81),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 13),
                        label: const Text(
                          'Generate',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Rich Text Editor Toolbar mock
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderCol)),
                ),
                padding: const EdgeInsets.only(bottom: 10),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('B', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0066FF))),
                    Text('I', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18, color: Color(0xFF6B7280))),
                    Text('U', style: TextStyle(decoration: TextDecoration.underline, fontSize: 18, color: Color(0xFF6B7280))),
                    Text('S', style: TextStyle(decoration: TextDecoration.lineThrough, fontSize: 18, color: Color(0xFF6B7280))),
                    Icon(Icons.align_horizontal_left, color: Color(0xFF6B7280)),
                    Icon(Icons.align_horizontal_center, color: Color(0xFF6B7280)),
                    Icon(Icons.align_horizontal_right, color: Color(0xFF6B7280)),
                    Icon(Icons.format_align_justify, color: Color(0xFF6B7280)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Description editor block
              TextField(
                controller: _descController,
                maxLines: 12,
                style: const TextStyle(color: textColor, fontSize: 14, height: 1.4),
                decoration: const InputDecoration(
                  hintText: 'Include Rules, Eligibility, Process, Format, etc.',
                  hintStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 7. Skills to be assessed
        Row(
          children: [
            const Text(
              'Skills to be assessed',
              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Icon(Icons.info_outline, color: textSecondary.withOpacity(0.7), size: 16),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'List required skills to attract participants with matching abilities or engage individuals eager to improve them',
          style: TextStyle(color: textSecondary, fontSize: 12.5, height: 1.3),
        ),
        const SizedBox(height: 8),
        _buildTextField(_skillsController, 'Example: Photoshop, ...'),
        const SizedBox(height: 28),

        // =============================================
        // SECTION: Mode & Participation
        // =============================================
        const Text(
          'Opportunity Mode & Participation Type',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Participation Type toggles
              const Text(
                'Participation Type',
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      icon: Icons.person_outline,
                      label: 'Individual',
                      isSelected: !_isTeamParticipation,
                      onTap: () => setState(() => _isTeamParticipation = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildToggleButton(
                      icon: Icons.people_outline,
                      label: 'Team Participation',
                      isSelected: _isTeamParticipation,
                      onTap: () => setState(() => _isTeamParticipation = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Team size spinner
              if (_isTeamParticipation) ...[
                const Text(
                  'Set team size',
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildSpinner('Min', _minTeamSize, (val) => setState(() => _minTeamSize = val))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSpinner('Max', _maxTeamSize, (val) => setState(() => _maxTeamSize = val))),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Mode of Opportunity toggles
              Row(
                children: [
                  const Text(
                    'Mode of Opportunity',
                    style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.info_outline, color: textSecondary.withOpacity(0.7), size: 16),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      icon: Icons.language_outlined,
                      label: 'Online',
                      isSelected: _isOnline,
                      onTap: () => setState(() => _isOnline = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildToggleButton(
                      icon: Icons.location_on_outlined,
                      label: 'Offline',
                      isSelected: !_isOnline,
                      onTap: () => setState(() => _isOnline = false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Registration Criteria Layout
  // ---------------------------------------------------------------------------
  Widget _buildRegistrationStep() {
    const Color textColor = Color(0xFF111827);
    const Color textSecondary = Color(0xFF6B7280);
    const Color borderCol = Color(0xFFE5E7EB);

    final List<String> categories = [
      'Everyone can apply',
      'College Students',
      'Freshers',
      'Professionals',
      'School Students',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registration Criteria',
          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select who can participate. Additional filters will appear based on your selection.',
          style: TextStyle(color: textSecondary, fontSize: 14, height: 1.3),
        ),
        const SizedBox(height: 24),

        // Who can register Card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Who can register?',
                    style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: textSecondary, size: 20),
                    onPressed: () => setState(() => _selectedEligibility.clear()),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the candidate type(s) eligible to register',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((cat) {
                  final bool active = _selectedEligibility.contains(cat);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (active) {
                          _selectedEligibility.remove(cat);
                        } else {
                          _selectedEligibility.add(cat);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? const Color(0xFF0066FF) : borderCol,
                          width: active ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: active ? const Color(0xFF0066FF) : textColor,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // College/Organization Card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'College/Organization',
                      style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Default : Everyone can apply',
                      style: TextStyle(
                        color: Color(0xFF0066FF),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Restrict applicants based on their College/Organization',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Organization restrictions updated.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF),
                  foregroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // INPUT COMPONENT BUILDERS
  // ---------------------------------------------------------------------------
  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFF111827), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String currentValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280), size: 24),
          style: const TextStyle(color: Color(0xFF111827), fontSize: 15),
          onChanged: onChanged,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066FF) : const Color(0xFFE5E7EB),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF4B5563), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF4B5563),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinner(String label, int value, ValueChanged<int> onChanged) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(color: Color(0xFF111827), fontSize: 14.5, fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged(value + 1),
                child: const Icon(Icons.keyboard_arrow_up, size: 16, color: Color(0xFF4B5563)),
              ),
              GestureDetector(
                onTap: () => onChanged(value > 1 ? value - 1 : 1),
                child: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF4B5563)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
