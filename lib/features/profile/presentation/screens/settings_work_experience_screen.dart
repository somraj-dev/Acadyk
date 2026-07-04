import 'package:flutter/material.dart';

class SettingsWorkExperienceScreen extends StatefulWidget {
  const SettingsWorkExperienceScreen({super.key});

  @override
  State<SettingsWorkExperienceScreen> createState() => _SettingsWorkExperienceScreenState();
}

class _SettingsWorkExperienceScreenState extends State<SettingsWorkExperienceScreen> {
  bool _gotFromUnstop = false;
  bool _currentlyWorking = false;
  bool _workFromHome = false;

  String? _selectedDesignation;
  String? _selectedOrganisation;
  String? _selectedEmploymentType;

  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _skillsCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _locationCtrl.dispose();
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
          'Work Experience',
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
                      Text('Work Experience', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Icon(Icons.chevron_right, size: 14, color: Colors.black45),
                      Text('New Experience', style: TextStyle(color: Color(0xFF0073B1), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkbox: Got this job from Unstop
                  Row(
                    children: [
                      Checkbox(
                        value: _gotFromUnstop,
                        activeColor: const Color(0xFF0073B1),
                        onChanged: (val) => setState(() => _gotFromUnstop = val ?? false),
                      ),
                      const Text(
                        'Got this job from Unstop',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Designation *
                  _buildDropdownField(
                    label: 'Designation *',
                    value: _selectedDesignation,
                    items: ['Software Engineer', 'Product Manager', 'Data Scientist', 'UI/UX Designer', 'Analyst'],
                    onChanged: (val) => setState(() => _selectedDesignation = val),
                    hint: 'Select Designation',
                  ),

                  // Organisation *
                  _buildDropdownField(
                    label: 'Organisation *',
                    value: _selectedOrganisation,
                    items: ['Google', 'Meta', 'Amazon', 'Microsoft', 'Acadyk Startup'],
                    onChanged: (val) => setState(() => _selectedOrganisation = val),
                    hint: 'Select Organisation',
                  ),

                  // Employment Type *
                  _buildDropdownField(
                    label: 'Employment Type *',
                    value: _selectedEmploymentType,
                    items: ['Full-time', 'Part-time', 'Contract', 'Internship', 'Freelance'],
                    onChanged: (val) => setState(() => _selectedEmploymentType = val),
                    hint: 'Select Employment Type',
                  ),

                  // Duration Header + Checkbox Currently Working
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Duration *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _currentlyWorking,
                            activeColor: const Color(0xFF0073B1),
                            onChanged: (val) => setState(() => _currentlyWorking = val ?? false),
                          ),
                          const Text(
                            'Currently working in this role',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Start Date & End Date side-by-side
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerField(
                          controller: _startDateCtrl,
                          hint: 'Start date',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePickerField(
                          controller: _endDateCtrl,
                          hint: 'End Date',
                          enabled: !_currentlyWorking,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location & Work from Home
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Location',
                          controller: _locationCtrl,
                          hint: 'Select Location',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _workFromHome,
                              activeColor: const Color(0xFF0073B1),
                              onChanged: (val) => setState(() => _workFromHome = val ?? false),
                            ),
                            const Text(
                              'Work from Home',
                              style: TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ],
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
                    hint: 'Describe your role here, detailing the responsibilities you handled, the skills you applied and developed, and the significant experiences you gained during your tenure.',
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

  Widget _buildDatePickerField({required TextEditingController controller, required String hint, bool enabled = true}) {
    return TextField(
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14.5),
        suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.black45),
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
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint}) {
    return Column(
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
