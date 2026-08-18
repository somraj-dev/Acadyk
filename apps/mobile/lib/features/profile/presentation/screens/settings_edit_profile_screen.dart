import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:acadyk/common/services/auth_service.dart';
import 'package:acadyk/common/services/profile_service.dart';
import 'package:acadyk/common/services/storage_service.dart';
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

  File? _pickedAvatarFile;
  String? _avatarPath;

  File? _pickedBannerFile;
  String? _bannerPath;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: ProfileManager.name);
    _bioCtrl = TextEditingController(text: ProfileManager.bio);
    _locationCtrl = TextEditingController(text: ProfileManager.location);
    _websiteCtrl = TextEditingController(text: ProfileManager.website);
    _dobCtrl = TextEditingController(text: ProfileManager.dateOfBirth);

    _avatarPath = ProfileManager.avatarUrl;
    _bannerPath = ProfileManager.bannerUrl;
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

  Future<void> _pickBannerImage() async {
    final file = await StorageService.pickImage();
    if (file != null) {
      setState(() {
        _pickedBannerFile = file;
        _bannerPath = file.path;
      });
    }
  }

  Future<void> _pickAvatarImage() async {
    final file = await StorageService.pickImage();
    if (file != null) {
      setState(() {
        _pickedAvatarFile = file;
        _avatarPath = file.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    String finalAvatarUrl = _avatarPath ?? ProfileManager.avatarUrl;
    String finalBannerUrl = _bannerPath ?? ProfileManager.bannerUrl;

    final user = AuthService.currentUser;
    if (user != null) {
      try {
        if (_pickedBannerFile != null) {
          final uploadedBanner = await StorageService.uploadCoverPhoto(user.id, _pickedBannerFile!);
          if (uploadedBanner != null && uploadedBanner.isNotEmpty) {
            finalBannerUrl = uploadedBanner;
          }
        }

        if (_pickedAvatarFile != null) {
          final uploadedAvatar = await StorageService.uploadProfilePhoto(user.id, _pickedAvatarFile!);
          if (uploadedAvatar != null && uploadedAvatar.isNotEmpty) {
            finalAvatarUrl = uploadedAvatar;
          }
        }

        await ProfileService.updateProfile(user.id, {
          'full_name': _nameCtrl.text.trim(),
          'bio': _bioCtrl.text.trim(),
          'location': _locationCtrl.text.trim(),
          'website': _websiteCtrl.text.trim(),
          'profile_photo_url': finalAvatarUrl,
          'cover_photo_url': finalBannerUrl,
        });
      } catch (e) {
        debugPrint('[EditProfile] Profile update sync warning: $e');
      }
    }

    ProfileManager.updateProfile(
      newName: _nameCtrl.text.trim(),
      newBio: _bioCtrl.text.trim(),
      newLocation: _locationCtrl.text.trim(),
      newWebsite: _websiteCtrl.text.trim(),
      newDateOfBirth: _dobCtrl.text.trim(),
      newAvatar: finalAvatarUrl,
      newBanner: finalBannerUrl,
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildImageWidget(String? path, File? file, String fallbackAsset) {
    if (file != null) {
      if (kIsWeb) {
        return Image.network(
          file.path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: BoxFit.cover),
        );
      } else {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: BoxFit.cover),
        );
      }
    }

    if (path != null && path.isNotEmpty) {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: BoxFit.cover),
        );
      } else if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: BoxFit.cover),
        );
      } else {
        if (kIsWeb) {
          return Image.network(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: BoxFit.cover),
          );
        } else {
          return Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: BoxFit.cover),
          );
        }
      }
    }

    return Image.asset(fallbackAsset, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    final currentAuthUser = AuthService.currentUser?.username ?? '';
    final username = (currentAuthUser.isNotEmpty ? currentAuthUser : ProfileManager.username).toLowerCase();

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
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F4C81)),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF191919),
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
                  GestureDetector(
                    onTap: _pickBannerImage,
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      color: Colors.black,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImageWidget(_bannerPath, _pickedBannerFile, 'assets/images/young_entrepreneur.jpg'),
                          Container(
                            color: Colors.black.withValues(alpha: 0.38),
                          ),
                          Center(
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Avatar Area overlapping the banner
                  Positioned(
                    bottom: -45,
                    left: 20,
                    child: GestureDetector(
                      onTap: _pickAvatarImage,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildImageWidget(_avatarPath, _pickedAvatarFile, 'assets/images/somraj_avatar.jpg'),
                              Container(
                                color: Colors.black.withValues(alpha: 0.38),
                              ),
                              const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                    _buildImmutableUsernameField(username),
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

  Widget _buildImmutableUsernameField(String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: _showUsernameRequestDialog,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.lock_outline, size: 14, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '@$username',
                  style: const TextStyle(
                    fontSize: 15.5,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Fixed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
            const SizedBox(height: 4),
            const Text(
              'Unique username assigned by Acadyk. Tap to request a change from the Acadyk Management Team.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF94A3B8),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsernameRequestDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_rounded, color: Color(0xFF0F172A), size: 22),
            SizedBox(width: 10),
            Text(
              'Username Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Your @username is unique and assigned by Acadyk. It is fixed and non-upgradeable directly from settings.\n\nIf you wish to change your username, please submit a formal change request to the Acadyk Management Team.',
          style: TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Username change request submitted to Acadyk Management Team.'),
                  backgroundColor: Color(0xFF10B981),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Request Change'),
          ),
        ],
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
