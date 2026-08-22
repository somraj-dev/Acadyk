import 'package:flutter/material.dart';
import '../services/profile_manager.dart';
import '../services/profile_pins_manager.dart';

class SettingsProjectsScreen extends StatefulWidget {
  const SettingsProjectsScreen({super.key});

  @override
  State<SettingsProjectsScreen> createState() => _SettingsProjectsScreenState();
}

class _SettingsProjectsScreenState extends State<SettingsProjectsScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _orgCtrl = TextEditingController();
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _linkCtrl = TextEditingController();
  final TextEditingController _skillsCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  bool _currentlyWorking = true;
  String _selectedStatus = 'Created & Posted';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _orgCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _linkCtrl.dispose();
    _skillsCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _saveProject() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Project Title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final org = _orgCtrl.text.trim().isNotEmpty ? _orgCtrl.text.trim() : 'Personal Project';
    final duration = _startDateCtrl.text.trim().isNotEmpty
        ? '${_startDateCtrl.text.trim()} – ${_currentlyWorking ? "Present" : (_endDateCtrl.text.trim().isNotEmpty ? _endDateCtrl.text.trim() : "Completed")}'
        : (_currentlyWorking ? 'Ongoing' : 'Completed');
    final desc = _descriptionCtrl.text.trim();
    final skills = _skillsCtrl.text.trim();
    final link = _linkCtrl.text.trim();

    final List<String> tagsList = skills.isNotEmpty
        ? skills.split(RegExp(r'[,|•]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : [];

    PinOriginStatus originStatus = PinOriginStatus.posted;
    if (_selectedStatus == 'Active / Ongoing') originStatus = PinOriginStatus.active;
    if (_selectedStatus == 'Completed') originStatus = PinOriginStatus.completed;
    if (_selectedStatus == 'Joined & Contributed') originStatus = PinOriginStatus.joined;

    // 1. Add to ProfileManager
    ProfileManager.addProject({
      'title': title,
      'time': duration,
      'duration': duration,
      'association': org,
      'organization': org,
      'description': desc,
      'skills': skills,
      'link': link,
      'highlight': _selectedStatus,
    });

    // 2. Add to ProfilePinsManager (Category: project, isPinned: true)
    ProfilePinsManager.addProjectPin(
      title: title,
      subtitle: org,
      organization: org,
      duration: duration,
      description: desc,
      tags: tagsList,
      originStatus: originStatus,
      statusLabel: _selectedStatus,
      isPinned: true,
      rawData: {
        'title': title,
        'time': duration,
        'duration': duration,
        'association': org,
        'organization': org,
        'description': desc,
        'skills': skills,
        'link': link,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project "$title" added and pinned to profile!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop(true);
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
          'Projects',
          style: TextStyle(color: Color(0xFF191919), fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: false,
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
                      Text('Projects', style: TextStyle(color: Color(0xFF737373), fontSize: 13, fontWeight: FontWeight.w500)),
                      Icon(Icons.chevron_right, size: 16, color: Color(0xFFB0B0B0)),
                      Text('New Project', style: TextStyle(color: Color(0xFF0073B1), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Project Title *
                  _buildTextField(
                    label: 'Project Title',
                    isRequired: true,
                    controller: _titleCtrl,
                    hint: 'e.g. AI Campus Navigator, Acadyk App',
                  ),
                  const SizedBox(height: 16),

                  // Associated with / Organization
                  _buildTextField(
                    label: 'Associated with (College / Company / Lab)',
                    isRequired: false,
                    controller: _orgCtrl,
                    hint: 'e.g. Madhav Institute of Technology and Science, Personal',
                  ),
                  const SizedBox(height: 16),

                  // Status Dropdown
                  const Text(
                    'Project Status',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF191919)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    items: ['Created & Posted', 'Active / Ongoing', 'Completed', 'Joined & Contributed']
                        .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Currently working checkbox
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _currentlyWorking,
                          activeColor: const Color(0xFF0073B1),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _currentlyWorking = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'I am currently working on this project',
                        style: TextStyle(fontSize: 13.5, color: Color(0xFF191919), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dates Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Start Date',
                          isRequired: false,
                          controller: _startDateCtrl,
                          hint: 'e.g. Jan 2024',
                        ),
                      ),
                      if (!_currentlyWorking) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: 'End Date',
                            isRequired: false,
                            controller: _endDateCtrl,
                            hint: 'e.g. Aug 2024',
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Project URL / Link
                  _buildTextField(
                    label: 'Project URL / Repository Link',
                    isRequired: false,
                    controller: _linkCtrl,
                    hint: 'https://github.com/... or https://acadyk.app',
                  ),
                  const SizedBox(height: 16),

                  // Skills Used
                  _buildTextField(
                    label: 'Skills / Tech Stack Used',
                    isRequired: false,
                    controller: _skillsCtrl,
                    hint: 'e.g. Flutter, Dart, Spring Boot, PostgreSQL',
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _buildTextField(
                    label: 'Description',
                    isRequired: false,
                    controller: _descriptionCtrl,
                    hint: 'Brief summary of what was built and key achievements...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom Save Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0073B1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _saveProject,
                  child: const Text(
                    'Save Project',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required bool isRequired,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF191919)),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14.5, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0073B1), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
