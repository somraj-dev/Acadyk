import 'package:flutter/material.dart';
import '../services/profile_manager.dart';

class SettingsEditProfileScreen extends StatefulWidget {
  const SettingsEditProfileScreen({super.key});

  @override
  State<SettingsEditProfileScreen> createState() => _SettingsEditProfileScreenState();
}

class _SettingsEditProfileScreenState extends State<SettingsEditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _dobCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: ProfileManager.name);
    _bioCtrl = TextEditingController(text: ProfileManager.bio);
    _locationCtrl = TextEditingController(text: ProfileManager.location);
    _websiteCtrl = TextEditingController(text: ProfileManager.website);
    _dobCtrl = TextEditingController(text: ProfileManager.dateOfBirth);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _websiteCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ProfileManager.updateProfile(
      newName: _nameCtrl.text.trim(),
      newBio: _bioCtrl.text.trim(),
      newLocation: _locationCtrl.text.trim(),
      newWebsite: _websiteCtrl.text.trim(),
      newDateOfBirth: _dobCtrl.text.trim(),
    );
    Navigator.of(context).pop();
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit profile',
          style: TextStyle(
            color: Color(0xFF191919),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF5E5E5E),
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner and Avatar Stack
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Banner Area
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        image: AssetImage(ProfileManager.bannerUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.35),
                          BlendMode.srcOver,
                        ),
                      ),
                    ),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  // Avatar Area overlapping the banner
                  Positioned(
                    bottom: -45,
                    left: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            image: DecorationImage(
                              image: AssetImage(ProfileManager.avatarUrl),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.35),
                                BlendMode.srcOver,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormInputField(
                      label: 'Name',
                      controller: _nameCtrl,
                    ),
                    _buildFormInputField(
                      label: 'Bio',
                      controller: _bioCtrl,
                      maxLines: null,
                    ),
                    _buildFormInputField(
                      label: 'Location',
                      controller: _locationCtrl,
                    ),
                    _buildFormInputField(
                      label: 'Website',
                      controller: _websiteCtrl,
                    ),
                    _buildFormInputField(
                      label: 'Date of birth',
                      controller: _dobCtrl,
                      subtitle: 'Month and day: Only you\nYear: Only you',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormInputField({
    required String label,
    required TextEditingController controller,
    String? subtitle,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 15.5,
              color: Color(0xFF191919),
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0073B1), width: 1.5),
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
