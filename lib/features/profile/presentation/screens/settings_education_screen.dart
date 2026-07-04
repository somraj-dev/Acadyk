import 'package:flutter/material.dart';

class SettingsEducationScreen extends StatefulWidget {
  const SettingsEducationScreen({super.key});

  @override
  State<SettingsEducationScreen> createState() => _SettingsEducationScreenState();
}

class _SettingsEducationScreenState extends State<SettingsEducationScreen> {
  String? _selectedQualification;
  String? _selectedCourse;
  String? _selectedSpecialization;
  String? _selectedCourseType;
  String? _selectedLateral;

  final TextEditingController _collegeCtrl = TextEditingController();
  final TextEditingController _startYearCtrl = TextEditingController();
  final TextEditingController _endYearCtrl = TextEditingController();
  final TextEditingController _percentageCtrl = TextEditingController();
  final TextEditingController _cgpaCtrl = TextEditingController();
  final TextEditingController _rollNumberCtrl = TextEditingController();
  final TextEditingController _skillsCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    _collegeCtrl.dispose();
    _startYearCtrl.dispose();
    _endYearCtrl.dispose();
    _percentageCtrl.dispose();
    _cgpaCtrl.dispose();
    _rollNumberCtrl.dispose();
    _skillsCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Education',
          style: TextStyle(color: Color(0xFF191919), fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF757575), size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Color(0xFF757575), size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                children: [
                  // Breadcrumb
                  Row(
                    children: const [
                      Text('Education', style: TextStyle(color: Color(0xFF737373), fontSize: 13, fontWeight: FontWeight.w500)),
                      Icon(Icons.chevron_right, size: 16, color: Color(0xFFB0B0B0)),
                      Text('New Education', style: TextStyle(color: Color(0xFF0073B1), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Qualification *
                  _buildDropdownField(
                    label: 'Qualification',
                    isRequired: true,
                    value: _selectedQualification,
                    items: ['B.Tech', 'B.Sc', 'M.Tech', 'MBA', 'PhD'],
                    onChanged: (val) => setState(() => _selectedQualification = val),
                    hint: 'Select Qualification',
                  ),

                  // Course *
                  _buildDropdownField(
                    label: 'Course',
                    isRequired: true,
                    value: _selectedCourse,
                    items: ['Select Course', 'Computer Science', 'Information Technology', 'Electronics', 'Mechanical'],
                    onChanged: (val) => setState(() => _selectedCourse = val),
                    hint: 'Select Course',
                  ),

                  // Specialization *
                  _buildDropdownField(
                    label: 'Specialization',
                    isRequired: true,
                    value: _selectedSpecialization,
                    items: ['Software Engineering', 'Data Science', 'Artificial Intelligence', 'Cybersecurity'],
                    onChanged: (val) => setState(() => _selectedSpecialization = val),
                    hint: 'Select Specialization',
                  ),

                  // College *
                  _buildTextField(
                    label: 'College',
                    isRequired: true,
                    controller: _collegeCtrl,
                    hint: 'College',
                  ),

                  // Duration * (Start Year & End Year side-by-side)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Duration',
                          isRequired: true,
                          controller: _startYearCtrl,
                          hint: 'Start Year',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: ' ',
                          isRequired: false,
                          controller: _endYearCtrl,
                          hint: 'End Year',
                        ),
                      ),
                    ],
                  ),

                  // Course Type
                  _buildDropdownField(
                    label: 'Course type',
                    isRequired: false,
                    value: _selectedCourseType,
                    items: ['Full Time', 'Part Time', 'Correspondence'],
                    onChanged: (val) => setState(() => _selectedCourseType = val),
                    hint: 'Select Course Type',
                  ),

                  // Percentage & CGPA side-by-side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Percentage',
                          isRequired: false,
                          controller: _percentageCtrl,
                          hint: 'Percentage',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'CGPA',
                          isRequired: false,
                          controller: _cgpaCtrl,
                          hint: 'CGPA',
                        ),
                      ),
                    ],
                  ),

                  // Roll Number & Lateral Entry side-by-side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Roll Number',
                          isRequired: false,
                          controller: _rollNumberCtrl,
                          hint: 'Roll number',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Are you a Lateral Entry Student?',
                          isRequired: false,
                          value: _selectedLateral,
                          items: ['Lateral entry', 'Yes', 'No'],
                          onChanged: (val) => setState(() => _selectedLateral = val),
                          hint: 'Lateral entry',
                        ),
                      ),
                    ],
                  ),

                  // Skills
                  _buildTextField(
                    label: 'Skills',
                    isRequired: false,
                    controller: _skillsCtrl,
                    hint: 'Add skills',
                  ),

                  // Description
                  _buildLargeTextField(
                    label: 'Description',
                    isRequired: false,
                    controller: _descriptionCtrl,
                    hint: 'Detail your education journey: degrees, accomplishments, skills gained. Share your academic and learning experiences to stand out',
                  ),

                  const SizedBox(height: 16),

                  // Generate with AI Button (premium chip container with sparkle)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                'Generate with AI',
                                style: TextStyle(
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Attachments Custom Dashed Button
                  CustomPaint(
                    painter: DashedBorderPainter(
                      color: const Color(0xFFCBD5E1),
                      strokeWidth: 1.2,
                      borderRadius: 8.0,
                      dashLength: 5.0,
                      gap: 3.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, color: Color(0xFF64748B), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Attachments',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Bottom bar with Discard and Save
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEFEFEF), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Discard',
                        style: TextStyle(
                          color: Color(0xFF5E5E5E),
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E8F0), // Disabled color until fields complete, or active blue
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
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

  Widget _buildTextField({required String label, required bool isRequired, required TextEditingController controller, required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.trim().isNotEmpty) ...[
            RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF191919),
                ),
                children: isRequired
                    ? const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF191919)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0073B1), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTextField({required String label, required bool isRequired, required TextEditingController controller, required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191919),
              ),
              children: isRequired
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 5,
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF191919), height: 1.4),
            decoration: InputDecoration(
              hintText: hint,
              hintMaxLines: 4,
              hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13.5, height: 1.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0073B1), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required bool isRequired,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191919),
              ),
              children: isRequired
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(hint, style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14.5)),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14.5, color: Color(0xFF191919))),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dashLength,
    required this.borderRadius,
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

    final dashPath = Path();
    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}
