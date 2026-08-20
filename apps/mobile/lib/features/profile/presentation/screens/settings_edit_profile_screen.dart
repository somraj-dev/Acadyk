import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:acadyk/common/services/auth_service.dart';
import 'package:acadyk/common/services/profile_service.dart';
import 'package:acadyk/common/services/storage_service.dart';
import 'package:path/path.dart' as p;
import '../services/profile_manager.dart';
import 'add_cover_image_screen.dart';

class SettingsEditProfileScreen extends StatefulWidget {
  const SettingsEditProfileScreen({super.key});

  @override
  State<SettingsEditProfileScreen> createState() => _SettingsEditProfileScreenState();
}

class _SettingsEditProfileScreenState extends State<SettingsEditProfileScreen> {
  late TextEditingController _bioCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _websiteCtrl;

  Uint8List? _pickedAvatarBytes;
  String? _pickedAvatarName;
  String? _avatarPath;

  Uint8List? _pickedBannerBytes;
  String? _pickedBannerName;
  String? _bannerPath;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController(text: ProfileManager.bio);
    _locationCtrl = TextEditingController(text: ProfileManager.location);
    _websiteCtrl = TextEditingController(text: ProfileManager.website);

    _avatarPath = ProfileManager.avatarUrl;
    _bannerPath = ProfileManager.bannerUrl;
    _pickedAvatarBytes = ProfileManager.avatarBytes;
    _pickedBannerBytes = ProfileManager.bannerBytes;
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBannerImage() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCoverImageScreen(
          currentBannerUrl: _bannerPath,
          currentBannerBytes: _pickedBannerBytes,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        if (result['bytes'] != null) {
          _pickedBannerBytes = result['bytes'] as Uint8List;
          _pickedBannerName = result['name'] as String?;
          _bannerPath = result['path'] as String?;
        } else if (result['url'] != null) {
          _bannerPath = result['url'] as String;
          _pickedBannerBytes = null;
          _pickedBannerName = null;
        }
      });
    }
  }

  Future<void> _pickAvatarImage() async {
    final xfile = await StorageService.pickImageXFile();
    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      setState(() {
        _pickedAvatarBytes = bytes;
        _pickedAvatarName = xfile.name;
        _avatarPath = xfile.path;
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
        if (_pickedBannerBytes != null) {
          final uploadedBanner = await StorageService.uploadCoverPhotoBytes(
            user.id,
            _pickedBannerBytes!,
            extension: _pickedBannerName != null ? p.extension(_pickedBannerName!) : '.jpg',
          );
          if (uploadedBanner != null && uploadedBanner.isNotEmpty) {
            finalBannerUrl = uploadedBanner;
          }
        }

        if (_pickedAvatarBytes != null) {
          final uploadedAvatar = await StorageService.uploadProfilePhotoBytes(
            user.id,
            _pickedAvatarBytes!,
            extension: _pickedAvatarName != null ? p.extension(_pickedAvatarName!) : '.jpg',
          );
          if (uploadedAvatar != null && uploadedAvatar.isNotEmpty) {
            finalAvatarUrl = uploadedAvatar;
          }
        }

        await ProfileService.updateProfile(user.id, {
          'full_name': ProfileManager.name,
          'bio': _bioCtrl.text.trim(),
          'location': _locationCtrl.text.trim(),
          'website': _websiteCtrl.text.trim(),
          if (finalAvatarUrl.isNotEmpty) 'profile_photo_url': finalAvatarUrl,
          if (finalBannerUrl.isNotEmpty) 'cover_photo_url': finalBannerUrl,
        });
      } catch (e) {
        debugPrint('[EditProfile] Profile update sync warning: $e');
      }
    }

    ProfileManager.updateProfile(
      newName: ProfileManager.name,
      newBio: _bioCtrl.text.trim(),
      newLocation: _locationCtrl.text.trim(),
      newWebsite: _websiteCtrl.text.trim(),
      newDateOfBirth: ProfileManager.dateOfBirth,
      newAvatar: finalAvatarUrl,
      newBanner: finalBannerUrl,
      newAvatarBytes: _pickedAvatarBytes,
      newBannerBytes: _pickedBannerBytes,
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

  Widget _buildImageWidget(String? path, Uint8List? bytes, String fallbackAsset) {
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackWidget(fallbackAsset),
      );
    }

    if (path != null && path.isNotEmpty) {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackWidget(fallbackAsset),
        );
      } else if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackWidget(fallbackAsset),
        );
      }
    }

    return _buildFallbackWidget(fallbackAsset);
  }

  Widget _buildFallbackWidget(String fallbackAsset) {
    if (fallbackAsset.isNotEmpty) {
      return Image.asset(fallbackAsset, fit: BoxFit.cover);
    }
    return Container(
      color: const Color(0xFF1565C0),
      alignment: Alignment.center,
      child: Text(
        ProfileManager.name.isNotEmpty ? ProfileManager.name.substring(0, 1).toUpperCase() : 'U',
        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
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
                          _buildImageWidget(_bannerPath, _pickedBannerBytes, ''),
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
                              _buildImageWidget(_avatarPath, _pickedAvatarBytes, ''),
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
                      label: 'Summary',
                      controller: _bioCtrl,
                      maxLines: null,
                    ),
                    _buildFormInputField(
                      label: 'HomeTown',
                      controller: _locationCtrl,
                    ),
                    _buildFormInputField(
                      label: 'Website',
                      controller: _websiteCtrl,
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
