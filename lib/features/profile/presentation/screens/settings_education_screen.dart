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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Education',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  // Breadcrumb
                  Row(
                    children: const [
                      Text('Education', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Icon(Icons.chevron_right, size: 14, color: Colors.black45),
                      Text('New Education', style: TextStyle(color: Color(0xFF0073B1), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Qualification *
                  _buildDropdownField(
                    label: 'Qualification *',
                    value: _selectedQualification,
                    items: ['B.Tech', 'B.Sc', 'M.Tech', 'MBA', 'PhD'],
                    onChanged: (val) => setState(() => _selectedQualification = val),
                    hint: 'Select Qualification',
                  ),

                  // Course *
                  _buildDropdownField(
                    label: 'Course *',
                    value: _selectedCourse,
                    items: ['Computer Science', 'Information Technology', 'Electronics', 'Mechanical'],
                    onChanged: (val) => setState(() => _selectedCourse = val),
                    hint: 'Select Course',
                  ),

                  // Specialization *
                  _buildDropdownField(
                    label: 'Specialization *',
                    value: _selectedSpecialization,
                    items: ['Software Engineering', 'Data Science', 'Artificial Intelligence', 'Cybersecurity'],
                    onChanged: (val) => setState(() => _selectedSpecialization = val),
                    hint: 'Select Specialization',
                  ),

                  // College *
                  _buildTextField(
                    label: 'College *',
                    controller: _collegeCtrl,
                    hint: 'College',
                  ),

                  // Duration * (Start Year & End Year side-by-side)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Duration *',
                          controller: _startYearCtrl,
                          hint: 'Start Year',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: ' ',
                          controller: _endYearCtrl,
                          hint: 'End Year',
                        ),
                      ),
                    ],
                  ),

                  // Course Type
                  _buildDropdownField(
                    label: 'Course type',
                    value: _selectedCourseType,
                    items: ['Full Time', 'Part Time', 'Correspondence'],
                    onChanged: (val) => setState(() => _selectedCourseType = val),
                    hint: 'Select Course Type',
                  ),

                  // Percentage & CGPA side-by-side
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Percentage',
                          controller: _percentageCtrl,
                          hint: 'Percentage',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'CGPA',
                          controller: _cgpaCtrl,
                          hint: 'CGPA',
                        ),
                      ),
                    ],
                  ),

                  // Roll Number & Lateral Entry side-by-side
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Roll Number',
                          controller: _rollNumberCtrl,
                          hint: 'Roll number',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Are you a Lateral Entry Student?',
                          value: _selectedLateral,
                          items: ['Yes', 'No'],
                          onChanged: (val) => setState(() => _selectedLateral = val),
                          hint: 'Lateral entry',
                        ),
                      ),
                    ],
                  ),

                  // Skills
                  _buildTextField(
                    label: 'Skills',
                    controller: _skillsCtrl,
                    hint: 'Add skills',
                  ),

                  // Description
                  _buildLargeTextField(
                    label: 'Description',
                    controller: _descriptionCtrl,
                    hint: 'Detail your education journey: degrees, accomplishments, skills gained. Share your academic and learning experiences to stand out',
                  ),

                  const SizedBox(height: 12),

                  // Generate with AI Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                      label: const Text(
                        'Generate with AI',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Attachments Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD0D0D0), width: 1, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.black54),
                          SizedBox(width: 6),
                          Text('Attachments', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ],
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
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Discard', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0073B1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.trim().isNotEmpty) ...[
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14.5, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTextField({required String label, required TextEditingController controller, required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 6,
            style: const TextStyle(fontSize: 14.5, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintMaxLines: 4,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
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
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD0D0D0)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(hint, style: const TextStyle(color: Colors.black38, fontSize: 14.5)),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14.5, color: Colors.black87)),
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
