import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../services/profile_manager.dart';
import '../services/profile_pins_manager.dart';

class SettingsCertificatesScreen extends StatefulWidget {
  const SettingsCertificatesScreen({super.key});

  @override
  State<SettingsCertificatesScreen> createState() => _SettingsCertificatesScreenState();
}

class _SettingsCertificatesScreenState extends State<SettingsCertificatesScreen> {
  bool _hasExpiryDate = false;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _orgCtrl = TextEditingController();
  final TextEditingController _issuedDateCtrl = TextEditingController();
  final TextEditingController _expiryDateCtrl = TextEditingController();
  final TextEditingController _skillsCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  String? _linkedCertificate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _orgCtrl.dispose();
    _issuedDateCtrl.dispose();
    _expiryDateCtrl.dispose();
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
          'Certificates',
          style: TextStyle(color: Color(0xFF191919), fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
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
                  // Title of Certificate *
                  _buildTextField(
                    label: 'Title of Certificate',
                    isRequired: true,
                    controller: _titleCtrl,
                    hint: 'Title of Certificate',
                  ),

                  // Issuing Organization *
                  _buildTextField(
                    label: 'Issuing Organization',
                    isRequired: true,
                    controller: _orgCtrl,
                    hint: 'Organisation',
                  ),

                  // Duration Header + Checkbox Has Expiry date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Duration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF191919),
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _hasExpiryDate,
                              activeColor: const Color(0xFF0073B1),
                              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => setState(() => _hasExpiryDate = val ?? false),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Has Expiry date',
                            style: TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Issued Date & Expiry Date side-by-side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDatePickerField(
                          controller: _issuedDateCtrl,
                          hint: 'Issued date',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePickerField(
                          controller: _expiryDateCtrl,
                          hint: 'Expiry Date',
                          enabled: _hasExpiryDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Link this Certificate
                  _buildDropdownField(
                    label: 'Link this Certificate',
                    isRequired: false,
                    hasInfoIcon: true,
                    value: _linkedCertificate,
                    items: ['Link this Certificate', 'Project Alpha', 'Work Experience at Google'],
                    onChanged: (val) => setState(() => _linkedCertificate = val),
                    hint: 'Link this Certificate',
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
                    hint: 'The skills and knowledge you gained during the process, and how this certification has contributed to your professional development.',
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

            // Bottom bar
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
                        backgroundColor: const Color(0xFF0073B1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final title = _titleCtrl.text.trim();
                        final org = _orgCtrl.text.trim();
                        if (title.isEmpty || org.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter Certificate Title and Organization')),
                          );
                          return;
                        }

                        final issueDate = _issuedDateCtrl.text.trim();
                        final desc = _descriptionCtrl.text.trim();
                        final skills = _skillsCtrl.text.trim();
                        final tagsList = skills.isNotEmpty
                            ? skills.split(RegExp(r'[,|•]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
                            : <String>[];

                        // 1. Add to ProfileManager
                        ProfileManager.addCertificate({
                          'title': title,
                          'issuingOrg': org,
                          'issueDate': issueDate,
                          'description': desc,
                          'skills': skills,
                        });

                        // 2. Add to ProfilePinsManager
                        ProfilePinsManager.addCertificatePin(
                          title: title,
                          issuingOrg: org,
                          issueDate: issueDate.isNotEmpty ? issueDate : 'Issued',
                          description: desc,
                          tags: tagsList,
                          isPinned: true,
                        );

                        // 3. Sync to backend gracefully
                        try {
                          await ApiClient.post('/me/certificates', data: {
                            'title': title,
                            'issuingOrg': org,
                            'skills': skills,
                            'description': desc,
                          });
                        } catch (e) {
                          debugPrint('[Certificates] Backend sync note: $e');
                        }

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Certificate "$title" added and pinned to profile!'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
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

  Widget _buildDatePickerField({required TextEditingController controller, required String hint, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2030),
          );
          if (date != null) {
            controller.text = "${date.day}/${date.month}/${date.year}";
          }
        },
        style: const TextStyle(fontSize: 14.5, color: Color(0xFF191919)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14.5),
          suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
    bool hasInfoIcon = false,
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
          Row(
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
              if (hasInfoIcon) ...[
                const SizedBox(width: 4),
                const Icon(Icons.info_outline, size: 14, color: Color(0xFF64748B)),
              ],
            ],
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
