import 'package:flutter/material.dart';

class AddTeamMemberScreen extends StatefulWidget {
  final int memberNumber;
  final Map<String, dynamic>? initialData;
  final String? leaderCollege;
  final String? leaderLocation;

  const AddTeamMemberScreen({
    super.key,
    required this.memberNumber,
    this.initialData,
    this.leaderCollege,
    this.leaderLocation,
  });

  @override
  State<AddTeamMemberScreen> createState() => _AddTeamMemberScreenState();
}

class _AddTeamMemberScreenState extends State<AddTeamMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _locationController;
  late final TextEditingController _orgController;

  String _selectedGender = 'Male';
  final String _selectedCountryCode = '+91';

  final List<Map<String, dynamic>> _genderOptions = [
    {'label': 'Female', 'icon': Icons.female},
    {'label': 'Male', 'icon': Icons.male},
    {'label': 'Transgender', 'icon': Icons.transgender},
    {'label': 'Intersex', 'icon': Icons.male_outlined},
    {'label': 'Non-binary', 'icon': Icons.all_inclusive},
    {'label': 'Prefer not to say', 'icon': Icons.block},
    {'label': 'Others', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _firstNameController = TextEditingController(text: data?['firstName'] ?? '');
    _lastNameController = TextEditingController(text: data?['lastName'] ?? '');
    _emailController = TextEditingController(text: data?['email'] ?? '');
    _mobileController = TextEditingController(text: data?['mobile'] ?? '');
    _locationController = TextEditingController(text: data?['location'] ?? 'Gwalior, Madhya Pradesh, India');
    _orgController = TextEditingController(text: data?['organization'] ?? 'Madhav Institute of Technology & Science');
    _selectedGender = data?['gender'] ?? 'Male';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _locationController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  void _copyLeaderDetails() {
    setState(() {
      _locationController.text = widget.leaderLocation ?? 'Gwalior, Madhya Pradesh, India';
      _orgController.text = widget.leaderCollege ?? 'Madhav Institute of Technology & Science';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied organization and location from Team Leader'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onSave() {
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter First Name')),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Email address')),
      );
      return;
    }

    final fullName = _lastNameController.text.trim().isNotEmpty
        ? '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
        : _firstNameController.text.trim();

    final contact = _mobileController.text.trim().isNotEmpty
        ? '$_selectedCountryCode ${_mobileController.text.trim()}'
        : _emailController.text.trim();

    Navigator.pop(context, {
      'name': fullName,
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'contact': contact,
      'gender': _selectedGender,
      'location': _locationController.text.trim(),
      'organization': _orgController.text.trim(),
      'status': 'pending',
      'initial': fullName.isNotEmpty ? fullName[0].toUpperCase() : 'M',
      'isLeader': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF1E293B);
    const Color labelColor = Color(0xFF334155);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Member ${widget.memberNumber}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. First Name*
                      _buildRequiredLabel('First Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _firstNameController,
                        hintText: 'Enter first name',
                      ),
                      const SizedBox(height: 18),

                      // 2. Last Name (if applicable)
                      const Text(
                        'Last Name (if applicable)',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _lastNameController,
                        hintText: 'Enter last name',
                      ),
                      const SizedBox(height: 18),

                      // 3. Email*
                      _buildRequiredLabel('Email'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'e.g. 25am10so81@mitsgwl.ac.in',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      // 4. Mobile*
                      _buildRequiredLabel('Mobile'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
                              ),
                              child: Row(
                                children: const [
                                  Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                  SizedBox(width: 6),
                                  Text(
                                    '+91',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.5,
                                      color: textColor,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280), size: 20),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14),
                                  hintText: 'Enter 10-digit number',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. Gender*
                      _buildRequiredLabel('Gender'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genderOptions.map((g) {
                          final isSelected = _selectedGender == g['label'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGender = g['label'] as String;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    g['icon'] as IconData,
                                    size: 16,
                                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    g['label'] as String,
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                                      fontSize: 13.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // 6. Location*
                      _buildRequiredLabel('Location'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  hintText: 'City, State, Country',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.my_location, color: Color(0xFF475569), size: 20),
                              onPressed: () {
                                setState(() {
                                  _locationController.text = 'Gwalior, Madhya Pradesh, India';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 7. Copy Details From Team Leader Banner
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _copyLeaderDetails,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF93C5FD), width: 0.8),
                              ),
                              child: const Text(
                                'Copy Details From Team Leader',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 8. Organization Name*
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRequiredLabel('Organization Name'),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _orgController.text = widget.leaderCollege ?? 'Madhav Institute of Technology & Science';
                              });
                            },
                            child: const Text(
                              'Same as leader',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _orgController,
                        hintText: 'Enter college or company name',
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D8BF2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _onSave,
                    child: const Text(
                      'Update',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
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

  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334155),
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        ),
      ),
    );
  }
}
