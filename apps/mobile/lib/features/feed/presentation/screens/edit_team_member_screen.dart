import 'package:flutter/material.dart';
import '../../../../common/widgets/acadyk_toggle_switch.dart';

class EditTeamMemberScreen extends StatefulWidget {
  final int memberIndex;
  final Map<String, dynamic> memberData;
  final bool isLeader;
  final int totalMembers;

  const EditTeamMemberScreen({
    super.key,
    required this.memberIndex,
    required this.memberData,
    required this.isLeader,
    required this.totalMembers,
  });

  @override
  State<EditTeamMemberScreen> createState() => _EditTeamMemberScreenState();
}

class _EditTeamMemberScreenState extends State<EditTeamMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _locationController;
  late TextEditingController _orgController;

  late bool _isLeader;
  late String? _avatarPath;
  late String _selectedInitial;

  @override
  void initState() {
    super.initState();
    final data = widget.memberData;
    _nameController = TextEditingController(text: data['name']?.toString() ?? '');
    _roleController = TextEditingController(text: data['role']?.toString() ?? '');
    _emailController = TextEditingController(text: data['email']?.toString() ?? '');
    _contactController = TextEditingController(text: data['contact']?.toString() ?? '');
    _locationController = TextEditingController(text: data['location']?.toString() ?? 'Gwalior, Madhya Pradesh, India');
    _orgController = TextEditingController(text: data['organization']?.toString() ?? 'Madhav Institute of Technology & Science');
    _isLeader = widget.isLeader || data['isLeader'] == true;
    _avatarPath = data['avatar']?.toString();
    _selectedInitial = data['initial']?.toString() ?? (_nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'M');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member name cannot be empty.')),
      );
      return;
    }

    final updatedMember = {
      ...widget.memberData,
      'name': name,
      'role': _roleController.text.trim().isNotEmpty ? _roleController.text.trim() : 'Team Member',
      'email': _emailController.text.trim(),
      'contact': _contactController.text.trim(),
      'location': _locationController.text.trim(),
      'organization': _orgController.text.trim(),
      'avatar': _avatarPath,
      'initial': name.isNotEmpty ? name[0].toUpperCase() : _selectedInitial,
      'isLeader': _isLeader,
    };

    Navigator.pop(context, {
      'action': 'update',
      'index': widget.memberIndex,
      'member': updatedMember,
    });
  }

  void _confirmDelete() {
    if (widget.totalMembers <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A team must have at least 1 member.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 8),
            Text('Remove Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${_nameController.text}" from the team roster?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx); // close dialog
              Navigator.pop(context, {
                'action': 'delete',
                'index': widget.memberIndex,
              });
            },
            child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF0284C7);
    const Color darkNavy = Color(0xFF0F172A);
    const Color labelColor = Color(0xFF334155);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Member Details',
          style: TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            tooltip: 'Remove Member',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Member Profile Avatar (Directly from Profile)
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: brandBlue, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: brandBlue.withValues(alpha: 0.15),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _avatarPath != null && _avatarPath!.isNotEmpty
                                ? Image.asset(
                                    _avatarPath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: brandBlue,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _selectedInitial,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: brandBlue,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _selectedInitial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. Full Name
                      _buildLabel('Full Name *'),
                      const SizedBox(height: 6),
                      _buildTextField(_nameController, 'Enter full name (e.g. Somraj Lodhi)'),
                      const SizedBox(height: 16),

                      // 3. Role / Specialization
                      _buildLabel('Role / Specialization *'),
                      const SizedBox(height: 6),
                      _buildTextField(_roleController, 'e.g. B.Tech AIML 3rd Year / ML Engineer'),
                      const SizedBox(height: 16),

                      // 4. Email Address
                      _buildLabel('Email Address'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        _emailController,
                        'e.g. somraj@mitsgwl.ac.in',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // 5. Contact Phone
                      _buildLabel('Contact Phone / Mobile'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        _contactController,
                        'e.g. +91 9243657795',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // 6. Organization / College
                      _buildLabel('College / Organization'),
                      const SizedBox(height: 6),
                      _buildTextField(_orgController, 'e.g. Madhav Institute of Technology & Science'),
                      const SizedBox(height: 16),

                      // 7. Location
                      _buildLabel('Location'),
                      const SizedBox(height: 6),
                      _buildTextField(_locationController, 'e.g. Gwalior, Madhya Pradesh'),
                      const SizedBox(height: 20),

                      // 8. Team Leadership Section
                      if (!widget.isLeader) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.stars_rounded, color: brandBlue, size: 22),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Team Leader Role',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: darkNavy,
                                        ),
                                      ),
                                      Text(
                                        'Assign as the primary contact lead',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              AcadykToggleSwitch(
                                value: _isLeader,
                                onChanged: (val) => setState(() => _isLeader = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 9. Remove Member Action Banner
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.person_remove_outlined, size: 18),
                          label: const Text(
                            'Remove Member from Team',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Save Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: labelColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: _onSave,
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
