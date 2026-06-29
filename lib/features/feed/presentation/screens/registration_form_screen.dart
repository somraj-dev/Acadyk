import 'package:flutter/material.dart';
import 'registration_success_screen.dart';
import 'celebration_success_screen.dart';

class RegistrationFormScreen extends StatefulWidget {
  final String eventTitle;
  final String logoUrl;
  final String organizer;

  const RegistrationFormScreen({
    super.key,
    required this.eventTitle,
    required this.logoUrl,
    required this.organizer,
  });

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers with pre-filled mock data from screenshots
  final TextEditingController _firstNameController = TextEditingController(text: 'Somraj');
  final TextEditingController _lastNameController = TextEditingController(text: 'Lodhi');
  final TextEditingController _emailController = TextEditingController(text: 'iitainsomraj701@gmail.com');
  final TextEditingController _mobileController = TextEditingController(text: '9243657795');
  final TextEditingController _locationController = TextEditingController(text: 'Gwalior, Madhya Pradesh, India');
  final TextEditingController _instituteController = TextEditingController(text: 'Madhav Institute of Technology & Science');

  String _selectedGender = 'Male';
  String _selectedUserType = 'College Students';
  String _selectedCourse = 'B.Tech/BE (Bachelor of Technology / Bachelor of Engineering)';
  String _selectedSpecialization = 'Artificial Intelligence and Machine Learning';
  String _selectedGradYear = '2029';
  String _selectedDuration = '4 Years';
  
  bool _agreeToTerms = false;
  bool _stayInLoop = true;

  final List<String> _genders = [
    'Female', 'Male', 'Transgender', 'Intersex', 'Non-binary', 'Prefer not to say', 'Others'
  ];

  final List<String> _userTypes = [
    'College Students', 'Professional', 'School Student', 'Fresher'
  ];

  final List<String> _gradYears = ['2027', '2028', '2029', '2030'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: Column(
              children: [
                // Header (with back button)
                _buildHeader(),
                
                // Blue progress line indicator
                Container(
                  height: 3,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 240, // 50% progress
                    color: Colors.blue.shade800,
                  ),
                ),
                
                // Form content scroll view
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registration Form',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1F22),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Basic Details section
                          _buildSectionHeader('Basic Details'),
                          const SizedBox(height: 16),
                          
                          _buildLabel('First Name'),
                          _buildTextField(
                            controller: _firstNameController,
                            validator: (val) => val!.isEmpty ? 'Enter your first name' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Last Name (if applicable)', isRequired: false),
                          _buildTextField(controller: _lastNameController),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Email'),
                          _buildTextField(
                            controller: _emailController,
                            isEmail: true,
                            validator: (val) => val!.isEmpty ? 'Enter your email' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Mobile'),
                          _buildMobileField(),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Gender'),
                          _buildChipsSelector(
                            options: _genders,
                            selectedOption: _selectedGender,
                            onSelected: (val) => setState(() => _selectedGender = val),
                            hasIcons: true,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Location'),
                          _buildTextField(
                            controller: _locationController,
                            suffixIcon: Icon(Icons.gps_fixed, color: Colors.grey[600]),
                            validator: (val) => val!.isEmpty ? 'Enter location' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Institute Name'),
                          _buildTextField(
                            controller: _instituteController,
                            validator: (val) => val!.isEmpty ? 'Enter institute name' : null,
                          ),
                          const SizedBox(height: 24),
                          
                          // User Details section
                          _buildSectionHeader('User Details'),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Type'),
                          _buildChipsSelector(
                            options: _userTypes,
                            selectedOption: _selectedUserType,
                            onSelected: (val) => setState(() => _selectedUserType = val),
                            hasIcons: true,
                          ),
                          const SizedBox(height: 12),
                          
                          // Warning info box
                          _buildWarningBox(),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Course'),
                          _buildDropdownField(
                            value: _selectedCourse,
                            options: [_selectedCourse],
                            onChanged: (val) => setState(() => _selectedCourse = val!),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Course Specialization'),
                          _buildDropdownField(
                            value: _selectedSpecialization,
                            options: [_selectedSpecialization],
                            onChanged: (val) => setState(() => _selectedSpecialization = val!),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Graduating Year'),
                          _buildChipsSelector(
                            options: _gradYears,
                            selectedOption: _selectedGradYear,
                            onSelected: (val) => setState(() => _selectedGradYear = val),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel('Course Duration'),
                          _buildChipsSelector(
                            options: const ['4 Years'],
                            selectedOption: _selectedDuration,
                            onSelected: (val) => setState(() => _selectedDuration = val),
                          ),
                          const SizedBox(height: 24),
                          
                          // Terms & Conditions
                          _buildSectionHeader('Terms & Conditions'),
                          const SizedBox(height: 16),
                          _buildTermsCheckboxes(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Sticky Bottom buttons
                _buildBottomButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Logo box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: widget.logoUrl.startsWith('http')
                ? Image.network(widget.logoUrl, fit: BoxFit.contain)
                : Container(
                    color: Colors.blue.shade900,
                    alignment: Alignment.center,
                    child: const Text('ESC', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              widget.eventTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1F22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.blue.shade800,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1F22),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1F22),
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    Widget? suffixIcon,
    bool isEmail = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E1F22)),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 1.5),
        ),
        suffixIcon: suffixIcon ?? (isEmail
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : null),
      ),
    );
  }

  Widget _buildMobileField() {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E1F22)),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            // Flag avatar mock
            Container(
              width: 24,
              height: 16,
              color: Colors.orange.shade300, // simple mock flag
              child: Stack(
                children: [
                  Container(height: 5, color: Colors.orange),
                  Center(child: Container(height: 5, color: Colors.white)),
                  Positioned(bottom: 0, child: Container(width: 24, height: 5, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('+91', style: TextStyle(fontSize: 15, color: Color(0xFF1E1F22))),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 1.5),
        ),
        suffixIcon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
      ),
    );
  }

  Widget _buildChipsSelector({
    required List<String> options,
    required String selectedOption,
    required Function(String) onSelected,
    bool hasIcons = false,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final bool isSelected = option == selectedOption;
        IconData? icon;
        if (hasIcons) {
          if (option == 'Female') icon = Icons.female;
          if (option == 'Male') icon = Icons.male;
          if (option == 'Transgender') icon = Icons.transgender;
          if (option == 'College Students') icon = Icons.school_outlined;
          if (option == 'Professional') icon = Icons.work_outline;
          if (option == 'School Student') icon = Icons.person_outline;
          if (option == 'Fresher') icon = Icons.work_history_outlined;
        }

        return GestureDetector(
          onTap: () => onSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50.withOpacity(0.3) : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.blue.shade800 : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1.0,
                style: isSelected ? BorderStyle.solid : BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: isSelected ? Colors.blue.shade800 : Colors.black54),
                  const SizedBox(width: 6),
                ],
                Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.blue.shade800 : Colors.grey[800],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        border: Border.all(color: const Color(0xFFFFE0B2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please note if you have graduated before 2027, please select the type as "Fresher"',
              style: TextStyle(color: Color(0xFFE65100), fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: options.map((opt) {
        return DropdownMenuItem<String>(
          value: opt,
          child: Text(
            opt,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E1F22)),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildTermsCheckboxes() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (val) => setState(() => _agreeToTerms = val!),
                activeColor: Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'By registering for this opportunity, you agree to share the data mentioned in this form or any form henceforth on this opportunity with the organizer of this opportunity for further analysis, processing, and outreach. Your data will also be used by Acadyk for providing you regular and constant updates on this opportunity. You also agree to the privacy policy and terms of use of Acadyk.',
                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _stayInLoop,
                onChanged: (val) => setState(() => _stayInLoop = val!),
                activeColor: Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Stay in the loop - Get relevant updates curated just for you!',
                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Back',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (!_agreeToTerms) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please accept the terms and conditions to register.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => RegistrationSuccessScreen(
                      eventTitle: widget.eventTitle,
                      logoUrl: widget.logoUrl,
                      organizer: widget.organizer,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0073B1),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
