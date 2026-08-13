import 'package:flutter/material.dart';
import '../services/startup_manager.dart';
import 'add_cofounder_screen.dart';

class CreateStartupScreen extends StatefulWidget {
  const CreateStartupScreen({super.key});

  @override
  State<CreateStartupScreen> createState() => _CreateStartupScreenState();
}

class _CreateStartupScreenState extends State<CreateStartupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _companyNameCtrl = TextEditingController();
  final _companyDescCtrl = TextEditingController();
  final _companyUrlCtrl = TextEditingController();
  final _productLinkCtrl = TextEditingController();
  final _credentialsCtrl = TextEditingController();
  final _whatCompanyMakesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _locationExplanationCtrl = TextEditingController();
  final _foundersCoderExplainCtrl = TextEditingController();
  final _lookingForCofounderCtrl = TextEditingController();
  final _progressCtrl = TextEditingController();
  final _timeWorkedCtrl = TextEditingController();
  final _techStackCtrl = TextEditingController();
  final _pivotHistoryCtrl = TextEditingController();
  final _incubatorCtrl = TextEditingController();
  final _competitorsCtrl = TextEditingController();
  final _monetizationCtrl = TextEditingController();
  final _alternateIdeasCtrl = TextEditingController();
  final _curiousYcCtrl = TextEditingController();
  final _curiousHearCtrl = TextEditingController();

  // Radio button states
  bool? _arePeopleUsing;
  bool? _doHaveRevenue;
  bool? _hasLegalEntity;
  bool? _hasInvestment;
  bool? _isFundraising;
  String? _pendingCofounderName;

  // Files/Media mock states
  String? _videoFileName;
  String? _demoFileName;
  String? _agentSessionFileName;

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _companyDescCtrl.dispose();
    _companyUrlCtrl.dispose();
    _productLinkCtrl.dispose();
    _credentialsCtrl.dispose();
    _whatCompanyMakesCtrl.dispose();
    _locationCtrl.dispose();
    _locationExplanationCtrl.dispose();
    _foundersCoderExplainCtrl.dispose();
    _lookingForCofounderCtrl.dispose();
    _progressCtrl.dispose();
    _timeWorkedCtrl.dispose();
    _techStackCtrl.dispose();
    _pivotHistoryCtrl.dispose();
    _incubatorCtrl.dispose();
    _competitorsCtrl.dispose();
    _monetizationCtrl.dispose();
    _alternateIdeasCtrl.dispose();
    _curiousYcCtrl.dispose();
    _curiousHearCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_companyNameCtrl.text.trim().isEmpty ||
        _companyDescCtrl.text.trim().isEmpty ||
        _videoFileName == null) {
      // Force trigger state rebuild to show errors
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the validation errors listed in the warning box.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Success - add to global startups list
    final newStartup = {
      'title': _companyNameCtrl.text.trim(),
      'image': 'assets/images/young_entrepreneur.jpg', // High-fidelity mock banner
      'isCustom': true,
      'customData': {
        'companyName': _companyNameCtrl.text.trim(),
        'description': _companyDescCtrl.text.trim(),
        'founders': 'Somraj lodhi (CEO) & team',
        'url': _companyUrlCtrl.text.trim().isNotEmpty ? _companyUrlCtrl.text.trim() : 'http://airbnb.com',
        'techStack': _techStackCtrl.text.trim().isNotEmpty ? _techStackCtrl.text.trim() : 'Flutter, Dart, Node.js',
        'location': _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : 'San Francisco, USA',
        'progress': _progressCtrl.text.trim().isNotEmpty ? _progressCtrl.text.trim() : 'Prototype built, early users onboarded.',
      }
    };

    StartupManager.addStartup(newStartup);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${_companyNameCtrl.text}" successfully added to Startup Gallery!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFAF9F5); // Warm cream YC background
    const textColor = Color(0xFF1E1E1E);
    const labelColor = Color(0xFF1E1E1E);
    const helperTextColor = Color(0xFF5A5A55);

    final isNameEmpty = _companyNameCtrl.text.trim().isEmpty;
    final isDescEmpty = _companyDescCtrl.text.trim().isEmpty;
    final isVideoEmpty = _videoFileName == null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Startup Application',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // =============================================
                  // SECTION 1: Founders
                  // =============================================
                  _buildSectionTitle('Founders'),
                  const SizedBox(height: 12),



                  // Add a co-founder button - black capsule
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final selectedName = await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (context) => const AddCofounderScreen(),
                          ),
                        );
                        if (selectedName != null) {
                          setState(() {
                            _pendingCofounderName = selectedName;
                          });
                        }
                      },
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        'Add a co-founder',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  if (_pendingCofounderName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Color(0xFF5E5E5E), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _pendingCofounderName!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Spacer(),
                          const Text(
                            'Request Pending',
                            style: TextStyle(color: Color(0xFFF04E23), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'Who writes code, or does other technical work on your product? Was any of it done by a non-founder? Please explain.',
                    controller: _foundersCoderExplainCtrl,
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'Are you looking for a cofounder?',
                    controller: _lookingForCofounderCtrl,
                  ),
                  const SizedBox(height: 32),

                  // =============================================
                  // SECTION 2: Founder Video
                  // =============================================
                  _buildSectionTitle('Founder Video'),
                  const SizedBox(height: 12),
                  const Text(
                    'Please record a one minute video introducing the founder(s).*',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: labelColor),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12, color: helperTextColor, height: 1.4),
                      children: [
                        TextSpan(text: 'Read more about the video '),
                        TextSpan(text: 'here', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                        TextSpan(text: '. Make sure the file does not exceed 100 MB.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildUploadBox(
                    fileName: _videoFileName,
                    hasArrow: true,
                    onTap: () {
                      setState(() {
                        _videoFileName = 'founder_intro.mp4';
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // =============================================
                  // SECTION 3: Company
                  // =============================================
                  _buildSectionTitle('Company'),
                  const SizedBox(height: 12),

                  _buildInputField(
                    label: 'Company name*',
                    controller: _companyNameCtrl,
                    hintText: '',
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    label: 'Describe what your company does in 50 characters or less.*',
                    controller: _companyDescCtrl,
                    hintText: '',
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    label: 'Company URL, if any',
                    controller: _companyUrlCtrl,
                    hintText: 'https://',
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'If you have a demo, attach it below.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: labelColor),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Anything that shows us how the product works. Please limit to 3 minutes / 100 MB.',
                    style: TextStyle(fontSize: 12, color: helperTextColor),
                  ),
                  const SizedBox(height: 12),
                  _buildUploadBox(
                    fileName: _demoFileName,
                    hasArrow: true,
                    onTap: () {
                      setState(() {
                        _demoFileName = 'demo_recording.mov';
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    label: 'Please provide a link to the product, if any.',
                    controller: _productLinkCtrl,
                    hintText: 'https://',
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    label: 'If login credentials are required for the link above, enter them here.',
                    controller: _credentialsCtrl,
                    hintText: 'username / password',
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'What is your company going to make? Please describe your product and what it does or will do.',
                    controller: _whatCompanyMakesCtrl,
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    label: 'Where do you live now, and where would the company be based in the future?',
                    controller: _locationCtrl,
                    hintText: 'Use the format City A, Country A / City B, Country B',
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'Explain your decision regarding location.',
                    controller: _locationExplanationCtrl,
                  ),
                  const SizedBox(height: 32),

                  // =============================================
                  // SECTION 4: Progress
                  // =============================================
                  _buildSectionTitle('Progress'),
                  const SizedBox(height: 12),

                  _buildTextAreaField(
                    label: 'How far along are you?',
                    controller: _progressCtrl,
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'How long have each of you been working on this? How much of that has been full-time? Please explain.',
                    controller: _timeWorkedCtrl,
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'What tech stack are you using, or planning to use, to build this product? Include AI models and AI coding tools you use.',
                    controller: _techStackCtrl,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Optional: attach a coding agent session you\'re particularly proud of.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: labelColor),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'This is an experimental question to give people a chance to show off their skills with AI coding tools. Many coding agents have commands to export the transcript. Can be text or markdown.',
                    style: TextStyle(fontSize: 12, color: helperTextColor, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  _buildUploadBox(
                    fileName: _agentSessionFileName,
                    hasArrow: false,
                    helperText: 'Click or drag to upload a .md or .txt file\nMaximum file size: 25MB',
                    onTap: () {
                      setState(() {
                        _agentSessionFileName = 'agent_transcript.md';
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildRadioGroup(
                    label: 'Are people using your product?',
                    value: _arePeopleUsing,
                    onChanged: (val) => setState(() => _arePeopleUsing = val),
                  ),
                  const SizedBox(height: 20),

                  _buildRadioGroup(
                    label: 'Do you have revenue?',
                    value: _doHaveRevenue,
                    onChanged: (val) => setState(() => _doHaveRevenue = val),
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'If you are applying with the same idea as a previous batch, did anything change? If you applied with a different idea, why did you pivot and what did you learn from the last idea?',
                    controller: _pivotHistoryCtrl,
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'If you have already participated or committed to participate in an incubator, "accelerator" or "pre-accelerator" program, please tell us about it.',
                    controller: _incubatorCtrl,
                  ),
                  const SizedBox(height: 32),

                  // =============================================
                  // SECTION 5: Idea
                  // =============================================
                  _buildSectionTitle('Idea'),
                  const SizedBox(height: 12),

                  _buildTextAreaField(
                    label: 'Why did you pick this idea to work on? Do you have domain expertise in this area? How do you know people need what you\'re making?',
                    controller: _competitorsCtrl,
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'Who are your competitors? What do you understand about your business that they don\'t?',
                    controller: _monetizationCtrl,
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'How do or will you make money? How much could you make? (We realize you can\'t know precisely, but give your best estimate)',
                    controller: _alternateIdeasCtrl,
                  ),
                  const SizedBox(height: 20),

                  _buildTextAreaField(
                    label: 'If you had any other ideas you considered, please list them here.',
                    controller: _curiousYcCtrl,
                  ),
                  const SizedBox(height: 32),

                  // =============================================
                  // SECTION 6: Equity
                  // =============================================
                  _buildSectionTitle('Equity'),
                  const SizedBox(height: 12),

                  _buildRadioGroup(
                    label: 'Have you formed ANY legal entity yet?',
                    helper: 'This may be in the United States, in your home country or in another country.',
                    value: _hasLegalEntity,
                    onChanged: (val) => setState(() => _hasLegalEntity = val),
                  ),
                  const SizedBox(height: 20),

                  _buildRadioGroup(
                    label: 'Have you taken any investment yet?',
                    value: _hasInvestment,
                    onChanged: (val) => setState(() => _hasInvestment = val),
                  ),
                  const SizedBox(height: 20),

                  _buildRadioGroup(
                    label: 'Are you currently fundraising?',
                    value: _isFundraising,
                    onChanged: (val) => setState(() => _isFundraising = val),
                  ),
                  const SizedBox(height: 32),



                  // =============================================
                  // VALIDATION WARNING BOX
                  // =============================================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF2F2),
                      border: Border.all(color: const Color(0xFFE8D0D0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildValidationBullet('Company name is required', isNameEmpty),
                        const SizedBox(height: 8),
                        _buildValidationBullet('Company description is required', isDescEmpty),
                        const SizedBox(height: 8),
                        _buildValidationBullet('Founder video is required', isVideoEmpty),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF04E23), // YC Orange
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Submit Application',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E1E),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        const Divider(color: Color(0xFFE5E5E0), height: 1),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF1E1E1E), width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E1E1E)),
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E), height: 1.3),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            TextFormField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  borderRadius: BorderRadius.circular(4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF1E1E1E), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E1E1E)),
            ),
            // Resize handles overlay in bottom right corner (picture-perfect same)
            Positioned(
              right: 4,
              bottom: 4,
              child: SizedBox(
                width: 12,
                height: 12,
                child: CustomPaint(
                  painter: _ResizeHandlePainter(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadBox({
    String? fileName,
    required bool hasArrow,
    String helperText = 'Drop here or browse',
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.transparent, // transparent inside the dashed box
            ),
            child: CustomPaint(
              painter: _DashedBorderPainter(color: const Color(0xFFCCCCCC)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasArrow && fileName == null) ...[
                      const Icon(Icons.arrow_downward, size: 28, color: Color(0xFF7A7A76)),
                      const SizedBox(height: 8),
                    ],
                    if (fileName == null) ...[
                      if (hasArrow) ...[
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Color(0xFF7A7A76), fontSize: 13),
                            children: [
                              TextSpan(text: 'Drop here or '),
                              TextSpan(
                                text: 'browse',
                                style: TextStyle(
                                  color: Color(0xFF0066CC),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          helperText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF7A7A76), fontSize: 13, height: 1.4),
                        ),
                      ],
                    ] else ...[
                      const Icon(Icons.check_circle_outline, color: Color(0xFFF04E23), size: 28),
                      const SizedBox(height: 6),
                      Text(
                        fileName,
                        style: const TextStyle(
                          color: Color(0xFFF04E23),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup({
    required String label,
    String? helper,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E), height: 1.3),
        ),
        if (helper != null) ...[
          const SizedBox(height: 2),
          Text(helper, style: const TextStyle(fontSize: 12, color: Color(0xFF5A5A55))),
        ],
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: value,
              activeColor: Colors.black, // black dot active indicator
              onChanged: onChanged,
            ),
            const Text('Yes', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 24),
            Radio<bool>(
              value: false,
              groupValue: value,
              activeColor: Colors.black, // black dot active indicator
              onChanged: onChanged,
            ),
            const Text('No', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildValidationBullet(String text, bool isError) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isError ? const Color(0xFFD32F2F) : Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isError ? const Color(0xFFD32F2F) : const Color(0xFF4A4A4A),
              decoration: isError ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = dashLength;
        dashedPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += length + gap;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ResizeHandlePainter extends CustomPainter {
  final Color color;
  _ResizeHandlePainter({this.color = const Color(0xFFCCCCCC)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double w = size.width;
    double h = size.height;

    // Draw three diagonal lines in the bottom-right corner representing the resize handle
    canvas.drawLine(Offset(w - 2, h - 8), Offset(w - 8, h - 2), paint);
    canvas.drawLine(Offset(w - 2, h - 5), Offset(w - 5, h - 2), paint);
    canvas.drawLine(Offset(w - 2, h - 2), Offset(w - 2, h - 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
