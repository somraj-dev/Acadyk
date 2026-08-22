import 'package:flutter/material.dart';
import '../services/profile_manager.dart';
import '../services/profile_pins_manager.dart';

class SettingsSkillsScreen extends StatefulWidget {
  const SettingsSkillsScreen({super.key});

  @override
  State<SettingsSkillsScreen> createState() => _SettingsSkillsScreenState();
}

class _SettingsSkillsScreenState extends State<SettingsSkillsScreen> {
  final TextEditingController _skillNameCtrl = TextEditingController();
  final TextEditingController _associationCtrl = TextEditingController();
  String _selectedProficiency = 'Intermediate';

  final List<String> _suggestedSkills = [
    'Flutter',
    'Dart',
    'Python',
    'Java',
    'Spring Boot',
    'React',
    'Node.js',
    'C++',
    'PostgreSQL',
    'Machine Learning',
    'UI/UX Design',
    'Data Science',
    'Robotics',
    'Cybersecurity',
    'Cloud Computing',
    'Docker',
    'Git & GitHub',
    'Figma',
  ];

  @override
  void dispose() {
    _skillNameCtrl.dispose();
    _associationCtrl.dispose();
    super.dispose();
  }

  void _saveSkill() {
    final skillName = _skillNameCtrl.text.trim();
    if (skillName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or select a skill name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final association = _associationCtrl.text.trim();

    // 1. Add to ProfileManager
    ProfileManager.addSkill(skillName, association);

    // 2. Add to ProfilePinsManager (Category: skill, isPinned: true)
    ProfilePinsManager.addSkillPin(
      skillName: skillName,
      association: association.isNotEmpty ? association : 'Verified Skill',
      proficiency: _selectedProficiency,
      isPinned: true,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Skill "$skillName" added and pinned to profile!'),
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
          'Skills',
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
                      Text('Skills', style: TextStyle(color: Color(0xFF737373), fontSize: 13, fontWeight: FontWeight.w500)),
                      Icon(Icons.chevron_right, size: 16, color: Color(0xFFB0B0B0)),
                      Text('New Skill', style: TextStyle(color: Color(0xFF0073B1), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Skill Input Field
                  _buildTextField(
                    label: 'Skill Name',
                    isRequired: true,
                    controller: _skillNameCtrl,
                    hint: 'e.g. Flutter, Machine Learning, UI/UX',
                  ),
                  const SizedBox(height: 12),

                  // Suggested Skills Chips
                  const Text(
                    'Suggested Skills',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedSkills.map((s) {
                      final isChosen = _skillNameCtrl.text.toLowerCase() == s.toLowerCase();
                      return ChoiceChip(
                        label: Text(s),
                        selected: isChosen,
                        onSelected: (selected) {
                          setState(() {
                            _skillNameCtrl.text = selected ? s : '';
                          });
                        },
                        selectedColor: const Color(0xFF0073B1).withValues(alpha: 0.15),
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: isChosen ? const Color(0xFF0073B1) : const Color(0xFF334155),
                          fontWeight: isChosen ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isChosen ? const Color(0xFF0073B1) : const Color(0xFFE2E8F0),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Associated with (Project / College / Company / Organization)
                  _buildTextField(
                    label: 'Associated with (Optional)',
                    isRequired: false,
                    controller: _associationCtrl,
                    hint: 'e.g. Quantaforze Corp, MITS Gwalior, Personal Project',
                  ),
                  const SizedBox(height: 16),

                  // Proficiency Level
                  const Text(
                    'Proficiency Level',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF191919)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedProficiency,
                    items: ['Beginner', 'Intermediate', 'Advanced', 'Expert']
                        .map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedProficiency = val);
                      }
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
                  onPressed: _saveSkill,
                  child: const Text(
                    'Save Skill',
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
