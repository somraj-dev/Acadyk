import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import '../services/profile_manager.dart';
import '../services/profile_pins_manager.dart';
import 'about_account_screen.dart';
import 'your_account_screen.dart';
import 'settings_edit_profile_screen.dart';
import 'edit_status_screen.dart';
import 'connections_list_screen.dart';
import 'project_details.dart';
import 'experience_details.dart';
import '../../../feed/presentation/screens/post_detail_screen.dart';
import 'package:acadyk/common/services/auth_service.dart';
import 'package:acadyk/common/services/profile_service.dart';
import 'package:acadyk/common/services/post_service.dart';
import 'package:acadyk/common/services/follow_service.dart';
import 'package:acadyk/common/services/storage_service.dart';
import 'package:path/path.dart' as p;
import 'add_cover_image_screen.dart';
import 'profile_showcase.dart';
import 'club_details_screen.dart';
import 'package:flutter/services.dart';
import 'package:acadyk/features/search/presentation/delegates/acadyk_search_delegate.dart';
import '../../../chat/presentation/screens/direct_message_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isOwnProfile;
  final Map<String, dynamic>? userData;
  const ProfileScreen({super.key, this.isOwnProfile = true, this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isFollowing = false;
  bool _isSummaryExpanded = false;
  bool _showAllProjects = false;
  final Set<int> _expandedProjectIndices = {};
  bool _showAllExperience = false;
  bool _showAllSkills = false;
  bool _showAllClubs = false;

  final Map<int, bool> _featuredLikedMap = {};
  final Map<int, int> _featuredLikesMap = {};

  String? _profileName;
  String? _profileBio;
  String? _profileSummary;
  String? _profileLocation;
  String? _profilePhotoUrl;
  String? _coverPhotoUrl;
  bool _isAudioPlaying = false;

  Timer? _bannerHoldTimer;
  Timer? _avatarHoldTimer;
  bool _avatarHoldTriggered = false;
  bool _bannerHoldTriggered = false;


  void _startBannerHoldTimer() {
    _bannerHoldTimer?.cancel();
    _bannerHoldTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        if (widget.isOwnProfile) {
          _showBannerOptionsBottomSheet();
        } else {
          _showImagePreviewDialog(
            title: 'Cover Photo',
            imageWidget: _buildBannerFullImageWidget(),
            isAvatar: false,
          );
        }
      }
    });
  }

  void _cancelBannerHoldTimer() {
    _bannerHoldTimer?.cancel();
    _bannerHoldTimer = null;
  }

  void _startAvatarHoldTimer(String avatar, String initials, int bgColorHex, bool isMITS) {
    _avatarHoldTimer?.cancel();
    _avatarHoldTriggered = false;
    _avatarHoldTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _avatarHoldTriggered = true;
        if (widget.isOwnProfile) {
          _showAvatarOptionsBottomSheet(avatar, initials, bgColorHex, isMITS);
        } else {
          _showImagePreviewDialog(
            title: 'Profile Photo',
            imageWidget: _buildAvatarFullImageWidget(
              photoUrl: _profilePhotoUrl,
              avatarString: avatar,
              initials: initials,
              bgColorHex: bgColorHex,
              isMITS: isMITS,
            ),
            isAvatar: true,
          );
        }
      }
    });
  }

  void _cancelAvatarHoldTimer() {
    _avatarHoldTimer?.cancel();
    _avatarHoldTimer = null;
  }

  void _showAvatarOptionsBottomSheet(String avatar, String initials, int bgColorHex, bool isMITS) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Add / Change profile photo
                _buildBottomSheetOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Add profile photo',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _pickAndUpdateAvatar();
                  },
                ),

                // Add frame
                _buildBottomSheetOption(
                  icon: Icons.crop_original_outlined,
                  title: 'Add frame',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showFramePickerBottomSheet();
                  },
                ),

                // View profile photo
                _buildBottomSheetOption(
                  icon: Icons.visibility_outlined,
                  title: 'View profile photo',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showImagePreviewDialog(
                      title: 'Profile Photo',
                      imageWidget: _buildAvatarFullImageWidget(
                        photoUrl: _profilePhotoUrl,
                        avatarString: avatar,
                        initials: initials,
                        bgColorHex: bgColorHex,
                        isMITS: isMITS,
                      ),
                      isAvatar: true,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBannerOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Add / Change cover photo
                _buildBottomSheetOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Add cover photo',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _pickAndUpdateBanner();
                  },
                ),

                // View cover photo
                _buildBottomSheetOption(
                  icon: Icons.visibility_outlined,
                  title: 'View cover photo',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showImagePreviewDialog(
                      title: 'Cover Photo',
                      imageWidget: _buildBannerFullImageWidget(),
                      isAvatar: false,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFramePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        final currentFrame = ProfileManager.selectedFrame;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile Frames',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFrameOptionTile(
                  ctx: ctx,
                  frameName: 'Original (No Frame)',
                  value: 'None',
                  isSelected: currentFrame == 'None',
                  color: Colors.grey,
                ),
                _buildFrameOptionTile(
                  ctx: ctx,
                  frameName: '#OpenToWork (Job Opportunities)',
                  value: '#OpenToWork',
                  isSelected: currentFrame == '#OpenToWork',
                  color: const Color(0xFF059669),
                ),
                _buildFrameOptionTile(
                  ctx: ctx,
                  frameName: 'Student @ MITS',
                  value: 'Student @ MITS',
                  isSelected: currentFrame == 'Student @ MITS',
                  color: const Color(0xFF0284C7),
                ),
                _buildFrameOptionTile(
                  ctx: ctx,
                  frameName: '#Hiring (Talent & Collaborators)',
                  value: '#Hiring',
                  isSelected: currentFrame == '#Hiring',
                  color: const Color(0xFF7C3AED),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrameOptionTile({
    required BuildContext ctx,
    required String frameName,
    required String value,
    required bool isSelected,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color, width: 2),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        frameName,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? const Color(0xFF0F4C81) : const Color(0xFF1E1E1E),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0F4C81), size: 22)
          : null,
      onTap: () {
        Navigator.of(ctx).pop();
        ProfileManager.setSelectedFrame(value);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value == 'None' ? 'Profile frame removed.' : 'Applied $value frame!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUpdateAvatar() async {
    final xfile = await StorageService.pickImageXFile();
    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      String finalAvatarUrl = xfile.path;

      final user = AuthService.currentUser;
      if (user != null) {
        try {
          final uploaded = await StorageService.uploadProfilePhotoBytes(
            user.id,
            bytes,
            extension: p.extension(xfile.name),
          );
          if (uploaded != null && uploaded.isNotEmpty) {
            finalAvatarUrl = uploaded;
          }
          await ProfileService.updateProfile(user.id, {
            'profile_photo_url': finalAvatarUrl,
          });
        } catch (e) {
          debugPrint('[ProfileScreen] Error uploading avatar: $e');
        }
      }

      ProfileManager.updateProfile(
        newName: ProfileManager.name,
        newBio: ProfileManager.bio,
        newLocation: ProfileManager.location,
        newWebsite: ProfileManager.website,
        newDateOfBirth: ProfileManager.dateOfBirth,
        newAvatar: finalAvatarUrl,
        newAvatarBytes: bytes,
      );

      if (mounted) {
        setState(() {
          _profilePhotoUrl = finalAvatarUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUpdateBanner() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCoverImageScreen(
          currentBannerUrl: _coverPhotoUrl,
          currentBannerBytes: ProfileManager.bannerBytes,
        ),
      ),
    );

    if (result != null) {
      final bytes = result['bytes'] as Uint8List?;
      final name = result['name'] as String?;
      final path = result['path'] as String?;
      final url = result['url'] as String?;

      String finalBannerUrl = url ?? path ?? '';

      final user = AuthService.currentUser;
      if (user != null) {
        try {
          if (bytes != null) {
            final uploaded = await StorageService.uploadCoverPhotoBytes(
              user.id,
              bytes,
              extension: name != null ? p.extension(name) : '.jpg',
            );
            if (uploaded != null && uploaded.isNotEmpty) {
              finalBannerUrl = uploaded;
            }
          }
          await ProfileService.updateProfile(user.id, {
            'cover_photo_url': finalBannerUrl,
          });
        } catch (e) {
          debugPrint('[ProfileScreen] Error uploading banner: $e');
        }
      }

      ProfileManager.updateProfile(
        newName: ProfileManager.name,
        newBio: ProfileManager.bio,
        newLocation: ProfileManager.location,
        newWebsite: ProfileManager.website,
        newDateOfBirth: ProfileManager.dateOfBirth,
        newBanner: finalBannerUrl,
        newBannerBytes: bytes,
      );

      if (mounted) {
        setState(() {
          _coverPhotoUrl = finalBannerUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cover image updated successfully!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showStatusDetailsDialog({
    required String name,
    required String emoji,
    required String text,
    required bool isBusy,
    String? expiration,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF4444), width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBusy ? 'Busy • Status Active' : 'Status Active',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isBusy ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 22),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    text.isNotEmpty ? text : "No status description provided.",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF334155),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (expiration != null && expiration.isNotEmpty && expiration != 'Never') ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Text(
                        'Expires: $expiration',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _onProfileUpdated() {
    if (mounted) {
      setState(() {
        _profileName = ProfileManager.name;
        _profileBio = ProfileManager.bio;
        _profileSummary = ProfileManager.summary;
        _profileLocation = ProfileManager.location;
        _profilePhotoUrl = ProfileManager.avatarUrl;
        _coverPhotoUrl = ProfileManager.bannerUrl;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    ProfileManager.profileUpdateNotifier.addListener(_onProfileUpdated);
    ProfilePinsManager.pinsChangeNotifier.addListener(_onProfileUpdated);
    PostService.feedChangeNotifier.addListener(_onProfileUpdated);
    FollowService.followChangeNotifier.addListener(_onProfileUpdated);
  }

  @override
  void dispose() {
    _cancelBannerHoldTimer();
    _cancelAvatarHoldTimer();
    ProfileManager.profileUpdateNotifier.removeListener(_onProfileUpdated);
    ProfilePinsManager.pinsChangeNotifier.removeListener(_onProfileUpdated);
    PostService.feedChangeNotifier.removeListener(_onProfileUpdated);
    FollowService.followChangeNotifier.removeListener(_onProfileUpdated);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProfileData() async {
    if (widget.userData != null) {
      _profileName = widget.userData!['name'] ?? widget.userData!['full_name'] ?? widget.userData!['authorName'];
      _profileBio = widget.userData!['headline'] ?? widget.userData!['bio'] ?? widget.userData!['authorSubtitle'];
      _profileSummary = widget.userData!['summary'] ?? widget.userData!['about'];
      _profileLocation = widget.userData!['location'];
      _profilePhotoUrl = widget.userData!['avatar'] ?? widget.userData!['avatarUrl'] ?? widget.userData!['profile_photo_url'];
      _coverPhotoUrl = widget.userData!['cover_photo_url'] ?? widget.userData!['banner'];
    } else {
      _profileName = widget.isOwnProfile ? (ProfileManager.name.isNotEmpty ? ProfileManager.name : (AuthService.currentUser?.fullName ?? '')) : '';
      _profileBio = widget.isOwnProfile ? ProfileManager.bio : '';
      _profileSummary = widget.isOwnProfile ? ProfileManager.summary : '';
      _profileLocation = widget.isOwnProfile ? ProfileManager.location : '';
      _profilePhotoUrl = widget.isOwnProfile ? ProfileManager.avatarUrl : '';
      _coverPhotoUrl = widget.isOwnProfile ? ProfileManager.bannerUrl : '';
    }

    try {
      final userId = widget.isOwnProfile
          ? AuthService.currentUser?.id
          : widget.userData?['id'];
      if (userId != null && userId.isNotEmpty) {
        final data = widget.isOwnProfile
            ? (await ProfileService.getMyProfile() ?? await ProfileService.getProfile(userId))
            : await ProfileService.getProfile(userId);
        if (data != null && mounted) {
          if (widget.isOwnProfile) {
            ProfileManager.loadFromProfileData(data);
          }
          setState(() {
            _profileName = data['fullName'] ?? data['full_name'] ?? _profileName;
            _profileBio = data['bio'] ?? _profileBio;
            _profileLocation = data['location'] ?? _profileLocation;
            _profilePhotoUrl = data['profilePhotoUrl'] ?? data['profile_photo_url'] ?? _profilePhotoUrl;
            _coverPhotoUrl = data['coverPhotoUrl'] ?? data['cover_photo_url'] ?? _coverPhotoUrl;
            if (!widget.isOwnProfile) {
              final isFol = data['isFollowing'] ?? data['is_following'];
              if (isFol is bool) {
                _isFollowing = isFol;
              }
            }
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final isTablet = mediaQuery.size.width >= 600;
    final maxContentWidth = isTablet ? 720.0 : double.infinity;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          color: scaffoldBg,
          child: Stack(
            children: [
              // Scrollable content
              Positioned.fill(
                child: ListView(
                  padding: EdgeInsets.zero,
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    // SECTION 1: Profile Header Card
                    _buildProfileHeaderCard(),
                    const SizedBox(height: 8),

                    // SECTION 2: Summary / About
                    _buildAboutSection(),
                    const SizedBox(height: 8),

                    // SECTION 3: Listed / Featured
                    _buildFeaturedSection(),
                    const SizedBox(height: 8),

                    // SECTION 5: Experience
                    _buildExperienceSection(),
                    const SizedBox(height: 8),

                    // SECTION 6: Education
                    _buildEducationSection(),
                    const SizedBox(height: 8),

                    // SECTION 7: Projects
                    _buildProjectsSection(),
                    const SizedBox(height: 8),

                    // SECTION 8: Skills
                    _buildSkillsSection(),
                    const SizedBox(height: 8),

                    // SECTION 9: Clubs & Organizations
                    _buildClubsSection(),
                    const SizedBox(height: 8),

                    // SECTION 10: Responsibilities
                    if (_getResponsibilitiesList().isNotEmpty) ...[
                      _buildResponsibilitiesSection(),
                      const SizedBox(height: 8),
                    ],

                    // SECTION 11: Licenses & Certificates
                    if (_getCertificatesList().isNotEmpty) ...[
                      _buildCertificatesSection(),
                      const SizedBox(height: 8),
                    ],

                    // SECTION 12: Honors & Achievements
                    if (_getAchievementsList().isNotEmpty) ...[
                      _buildAchievementsSection(),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Transparent top overlay bar with safe positioning
              Positioned(
                top: topPadding > 0 ? topPadding + 6 : 14,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Right side search and menu options
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: AcadykSearchDelegate(),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (widget.isOwnProfile) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const YourAccountScreen()),
                              );
                            } else {
                              _showProfileOptionsBottomSheet(context);
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              widget.isOwnProfile ? Icons.menu : Icons.more_horiz,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SECTION 1: Profile Header Card
  // =============================================================
  Widget _buildProfileHeaderCard() {
    final String name = _profileName ?? widget.userData?['name'] ?? widget.userData?['full_name'] ?? (widget.isOwnProfile ? (ProfileManager.name.isNotEmpty ? ProfileManager.name : (AuthService.currentUser?.fullName?.isNotEmpty == true ? AuthService.currentUser!.fullName! : 'Acadyk Member')) : 'Member');
    final String bio = _profileBio ?? widget.userData?['headline'] ?? widget.userData?['bio'] ?? (widget.isOwnProfile
        ? ProfileManager.bio
        : '');

    final String avatar = widget.userData != null
        ? (widget.userData!['avatar'] ?? widget.userData!['avatarUrl'] ?? '')
        : (widget.isOwnProfile ? ProfileManager.avatarUrl : '');

    final String initials = widget.userData?['initials'] ?? (name.isNotEmpty ? name.substring(0, min(2, name.length)).toUpperCase() : 'U');
    final int bgColorHex = widget.userData?['bgColor'] ?? 0xFF1565C0;
    final bool isMITS = name.contains('MITS');

    final String followingCount = widget.userData?['following']?.toString() ?? (widget.isOwnProfile ? '${ProfileManager.followingCount}' : '0');
    final String followersCount = widget.userData?['followers']?.toString() ?? (widget.isOwnProfile ? (ProfileManager.followersCount > 1000 ? '${(ProfileManager.followersCount / 1000).toStringAsFixed(1)}K' : '${ProfileManager.followersCount}') : '0');

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner + Profile Photo Stack
          SizedBox(
            height: 250,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner Image
                Listener(
                  onPointerDown: (_) {
                    _bannerHoldTriggered = false;
                    _bannerHoldTimer?.cancel();
                    _bannerHoldTimer = Timer(const Duration(seconds: 3), () {
                      _bannerHoldTriggered = true;
                      if (mounted) {
                        if (widget.isOwnProfile) {
                          _showBannerOptionsBottomSheet();
                        } else {
                          _showImagePreviewDialog(
                            title: 'Cover Photo',
                            imageWidget: _buildBannerFullImageWidget(),
                            isAvatar: false,
                          );
                        }
                      }
                    });
                  },
                  onPointerUp: (_) {
                    _bannerHoldTimer?.cancel();
                    if (!_bannerHoldTriggered) {
                      // Immediate click / tap on banner: preview cover image
                      _showImagePreviewDialog(
                        title: 'Cover Photo',
                        imageWidget: _buildBannerFullImageWidget(),
                        isAvatar: false,
                      );
                    }
                  },
                  onPointerCancel: (_) {
                    _bannerHoldTimer?.cancel();
                  },
                  child: Stack(
                    children: [
                      _buildBannerImageWidget(),
                      Container(
                        height: 215,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.65),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.45, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Avatar
                Positioned(
                  left: 20,
                  bottom: 0,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: UserStatusState.statusNotifier,
                    builder: (context, statusVal, child) {
                      final bool hasActiveStatus = widget.isOwnProfile
                          ? UserStatusState.isStatusActive
                          : (widget.userData != null &&
                              (widget.userData!['hasStatus'] == true ||
                                  (widget.userData!['status'] != null &&
                                      widget.userData!['status'].toString().isNotEmpty)));

                      final String currentDisplayEmoji = widget.isOwnProfile
                          ? (UserStatusState.emoji ?? '🎓')
                          : (widget.userData?['statusEmoji'] ?? '🎓');

                      final String activeFrame = widget.isOwnProfile ? ProfileManager.selectedFrame : 'None';
                      Color frameBorderColor = Colors.white;
                      if (hasActiveStatus) {
                        frameBorderColor = const Color(0xFFEF4444);
                      } else if (activeFrame == '#OpenToWork') {
                        frameBorderColor = const Color(0xFF059669);
                      } else if (activeFrame == 'Student @ MITS') {
                        frameBorderColor = const Color(0xFF0284C7);
                      } else if (activeFrame == '#Hiring') {
                        frameBorderColor = const Color(0xFF7C3AED);
                      }

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: frameBorderColor,
                                width: (hasActiveStatus || activeFrame != 'None') ? 3.5 : 4.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: hasActiveStatus
                                      ? const Color(0xFFEF4444).withValues(alpha: 0.38)
                                      : activeFrame != 'None'
                                          ? frameBorderColor.withValues(alpha: 0.3)
                                          : Colors.black.withValues(alpha: 0.12),
                                  blurRadius: (hasActiveStatus || activeFrame != 'None') ? 12 : 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Listener(
                              onPointerDown: (_) {
                                _avatarHoldTriggered = false;
                                _avatarHoldTimer?.cancel();
                                _avatarHoldTimer = Timer(const Duration(seconds: 3), () {
                                  _avatarHoldTriggered = true;
                                  if (mounted) {
                                    if (widget.isOwnProfile) {
                                      _showAvatarOptionsBottomSheet(avatar, initials, bgColorHex, isMITS);
                                    } else {
                                      _showImagePreviewDialog(
                                        title: 'Profile Photo',
                                        imageWidget: _buildAvatarFullImageWidget(
                                          photoUrl: _profilePhotoUrl,
                                          avatarString: avatar,
                                          initials: initials,
                                          bgColorHex: bgColorHex,
                                          isMITS: isMITS,
                                        ),
                                        isAvatar: true,
                                      );
                                    }
                                  }
                                });
                              },
                              onPointerUp: (_) {
                                _avatarHoldTimer?.cancel();
                                if (!_avatarHoldTriggered) {
                                  // Immediate click / tap on avatar: open Set Status screen
                                  if (widget.isOwnProfile) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const EditStatusScreen()),
                                    );
                                  } else {
                                    if (hasActiveStatus) {
                                      _showStatusDetailsDialog(
                                        name: name,
                                        emoji: widget.userData?['statusEmoji'] ?? '🎓',
                                        text: widget.userData?['status'] ?? widget.userData?['headline'] ?? '',
                                        isBusy: widget.userData?['isBusy'] == true,
                                        expiration: widget.userData?['statusExpiration'],
                                      );
                                    } else {
                                      _showImagePreviewDialog(
                                        title: 'Profile Photo',
                                        imageWidget: _buildAvatarFullImageWidget(
                                          photoUrl: _profilePhotoUrl,
                                          avatarString: avatar,
                                          initials: initials,
                                          bgColorHex: bgColorHex,
                                          isMITS: isMITS,
                                        ),
                                        isAvatar: true,
                                      );
                                    }
                                  }
                                }
                              },
                              onPointerCancel: (_) {
                                _avatarHoldTimer?.cancel();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: _buildAvatarImageWidget(
                                  photoUrl: _profilePhotoUrl,
                                  avatarString: avatar,
                                  initials: initials,
                                  bgColorHex: bgColorHex,
                                  isMITS: isMITS,
                                ),
                              ),
                            ),
                          ),

                          // Emoji status badge
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: GestureDetector(
                              onTap: () {
                                if (widget.isOwnProfile) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const EditStatusScreen()),
                                  );
                                } else {
                                  if (hasActiveStatus) {
                                    _showStatusDetailsDialog(
                                      name: name,
                                      emoji: widget.userData?['statusEmoji'] ?? '🎓',
                                      text: widget.userData?['status'] ?? widget.userData?['headline'] ?? '',
                                      isBusy: widget.userData?['isBusy'] == true,
                                      expiration: widget.userData?['statusExpiration'],
                                    );
                                  }
                                }
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: hasActiveStatus ? const Color(0xFFEF4444) : Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: hasActiveStatus
                                          ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                                          : Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  currentDisplayEmoji,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons Row (Right Aligned: Follow / Edit Profile)
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 10.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit Profile / Follow button
                if (widget.isOwnProfile)
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsEditProfileScreen(),
                        ),
                      );
                      _onProfileUpdated();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      final targetId = widget.userData?['id']?.toString();
                      if (targetId != null) {
                        FollowService.toggleFollow(targetId, _isFollowing);
                      }
                      setState(() {
                        _isFollowing = !_isFollowing;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isFollowing ? 'You are now following $name' : 'Unfollowed $name'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: _isFollowing ? const Color(0xFF334155) : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // User Identity Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF334155),
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],

                // Showcase Banners & Add Button below Bio & above Followers/Following
                const SizedBox(height: 12),
                _buildProfileShowcaseRow(name),
                const SizedBox(height: 16),

                // Stats Row: Following & Followers
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConnectionsListScreen(
                              initialTab: 'following',
                              userName: name,
                              userHandle: '',
                            ),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: followingCount,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            const TextSpan(
                              text: ' Following',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConnectionsListScreen(
                              initialTab: 'followers',
                              userName: name,
                              userHandle: '',
                            ),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: followersCount,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            const TextSpan(
                              text: ' Followers',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Profile Showcase Banners Row (Pill capsules matching bright theme design)
  Widget _buildProfileShowcaseRow(String name) {
    final banners = widget.isOwnProfile
        ? ProfileManager.showcaseBanners
        : (widget.userData?['showcaseBanners'] as List<Map<String, String>>? ?? []);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          // 1. Active Showcases (Mentor, Coordinator, Club, Social, Custom)
          for (final banner in banners) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: Text(
                banner['title'] ?? '',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 2. + Add Button (Opens ProfileShowcaseScreen)
          if (widget.isOwnProfile)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileShowcaseScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.plus,
                      size: 13,
                      color: Color(0xFF0F172A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =============================================================
  // SECTION 2: Summary / About
  // =============================================================
  Widget _buildAboutSection() {
    final String defaultSummary = widget.isOwnProfile
        ? (ProfileManager.summary.isNotEmpty ? ProfileManager.summary : 'No summary added yet.')
        : (_profileSummary != null && _profileSummary!.isNotEmpty
            ? _profileSummary!
            : (widget.userData?['summary'] ?? widget.userData?['about'] ?? 'No summary provided.'));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSummaryExpanded = !_isSummaryExpanded;
              });
            },
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF334155),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: _isSummaryExpanded
                        ? defaultSummary
                        : (defaultSummary.length > 180
                            ? '${defaultSummary.substring(0, 180)}...'
                            : defaultSummary),
                  ),
                  if (defaultSummary.length > 180)
                    TextSpan(
                      text: _isSummaryExpanded ? '  Show less' : '  more',
                      style: const TextStyle(
                        color: Color(0xFF0A66C2),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SECTION 3: Listed / Featured
  // =============================================================
  List<Map<String, dynamic>> _getFeaturedItems() {
    final String name = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? (ProfileManager.name.isNotEmpty ? ProfileManager.name : 'Acadyk Member') : 'Member');
    final String bio = _profileBio ?? widget.userData?['headline'] ?? (widget.isOwnProfile ? ProfileManager.bio : '');
    final String avatar = _profilePhotoUrl ?? widget.userData?['avatar'] ?? (widget.isOwnProfile ? ProfileManager.avatarUrl : '');

    final List<Map<String, dynamic>> userCreatedItems = [];
    if (widget.isOwnProfile) {
      final userPosts = PostService.getUserCreatedPosts();
      for (final p in userPosts) {
        userCreatedItems.add({
          'category': 'Post',
          'text': p['content'] ?? '',
          'imageAsset': (p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty) ? p['imageUrl'] : '',
          'reactions': p['likes'] ?? 0,
          'authorName': name,
          'authorHeadline': bio,
          'authorAvatar': avatar,
          'timeAgo': p['timeAgo'] ?? 'Just now',
        });
      }
    } else {
      final posts = widget.userData?['posts'] as List<dynamic>?;
      if (posts != null && posts.isNotEmpty) {
        for (final p in posts) {
          if (p is Map) {
            userCreatedItems.add({
              'category': p['category'] ?? 'Post',
              'text': p['content'] ?? p['text'] ?? '',
              'imageAsset': p['imageUrl'] ?? p['imageAsset'] ?? '',
              'reactions': p['likes'] ?? p['reactions'] ?? 0,
              'authorName': name,
              'authorHeadline': bio,
              'authorAvatar': avatar,
              'timeAgo': p['timeAgo'] ?? 'Recently',
            });
          }
        }
      }
    }

    return userCreatedItems;
  }

  Widget _buildFeaturedSection() {
    final items = _getFeaturedItems();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: const [
                Text(
                  'Listed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                const SizedBox(width: 16),
                for (int i = 0; i < items.length; i++) ...[
                  _buildFeaturedCard(index: i, item: items[i]),
                  const SizedBox(width: 12),
                ],
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard({required int index, required Map<String, dynamic> item}) {
    final bool isLiked = _featuredLikedMap[index] ?? false;
    final int baseLikes = item['reactions'] as int;
    final int currentLikes = _featuredLikesMap[index] ?? baseLikes;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(
              authorName: item['authorName'],
              authorHeadline: item['authorHeadline'],
              authorAvatar: item['authorAvatar'],
              timeAgo: item['timeAgo'],
              postText: item['text'],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                item['category'],
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: 42,
                child: Text(
                  item['text'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF191919),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              child: item['imageAsset'].toString().startsWith('http')
                  ? Image.network(
                      item['imageAsset'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 160,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 36),
                      ),
                    )
                  : Image.asset(
                      item['imageAsset'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 160,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 36),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        final nowLiked = !isLiked;
                        _featuredLikedMap[index] = nowLiked;
                        _featuredLikesMap[index] = nowLiked ? currentLikes + 1 : currentLikes - 1;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isLiked ? const Color(0xFF0A66C2) : const Color(0xFF64748B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.thumb_up, size: 11, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$currentLikes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isLiked ? const Color(0xFF0A66C2) : const Color(0xFF5E5E5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Review post →',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF0A66C2),
                      fontWeight: FontWeight.w600,
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

  // =============================================================
  // SECTION 5: Experience
  // =============================================================
  List<Map<String, dynamic>> _getExperienceList() {
    if (widget.isOwnProfile) {
      return ProfilePinsManager.getPinnedExperiences();
    } else {
      final List<dynamic>? userExp = widget.userData?['experiences'] as List<dynamic>?;
      if (userExp != null && userExp.isNotEmpty) {
        return userExp.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }
  }

  Widget _buildExperienceSection() {
    final experiences = _getExperienceList();
    final displayedExperiences = _showAllExperience ? experiences : experiences.take(1).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Experience (${experiences.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 16),
          if (experiences.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No experience added yet.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
              ),
            )
          else ...[
            for (int i = 0; i < displayedExperiences.length; i++) ...[
              _buildExperienceItem(displayedExperiences[i]),
              if (i < displayedExperiences.length - 1) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 16),
              ],
            ],
            if (experiences.length > 1) ...[
              const SizedBox(height: 16),
              Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAllExperience = !_showAllExperience;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAllExperience ? 'Show less' : 'Show all experiences (${experiences.length})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showAllExperience ? Icons.keyboard_arrow_up : Icons.arrow_forward,
                          size: 18,
                          color: const Color(0xFF0A66C2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceItem(Map<String, dynamic> exp) {
    final String title = exp['title']?.toString() ?? '';
    final String companyName = exp['company']?.toString() ?? exp['organization']?.toString() ?? '';
    final String durationStr = exp['duration']?.toString() ?? '';
    final String locationStr = exp['location']?.toString() ?? '';
    final String? highlightStr = exp['highlight']?.toString();
    final String companyLower = companyName.toLowerCase();
    final String? customLogo = exp['logo']?.toString();
    final String? logoAsset = customLogo ?? (companyLower.contains('quantaforze')
        ? 'assets/images/quantaforze_logo.png'
        : companyLower.contains('mits')
            ? 'assets/images/mits_logo.png'
            : companyLower.contains('acadyk')
                ? 'assets/images/acadyk_logo.png'
                : null);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExperienceDetailsScreen(experienceData: exp),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4),
              child: logoAsset != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        logoAsset,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.business_center,
                          size: 22,
                          color: Color(0xFF191919),
                        ),
                      ),
                    )
                  : const Icon(Icons.business_center, size: 22, color: Color(0xFF191919)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
                  if (companyName.isNotEmpty)
                    Text(companyName, style: const TextStyle(fontSize: 13, color: Color(0xFF191919))),
                  if (durationStr.isNotEmpty)
                    Text(durationStr, style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
                  if (locationStr.isNotEmpty)
                    Text(locationStr, style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
                  if (highlightStr != null && highlightStr.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.diamond, size: 14, color: Color(0xFF0A66C2)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            highlightStr,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getEducationList() {
    if (widget.isOwnProfile) {
      return ProfilePinsManager.getPinnedEducation();
    } else {
      final List<dynamic>? userEdu = widget.userData?['education'] as List<dynamic>?;
      if (userEdu != null && userEdu.isNotEmpty) {
        return userEdu.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      if (widget.userData?['degree'] != null || widget.userData?['branch'] != null) {
        return [
          {
            'school': 'Madhav Institute of Technology and Science, Gwalior',
            'degree': '${widget.userData?['degree'] ?? "Bachelor of Technology"}, ${widget.userData?['branch'] ?? ""}',
            'duration': '2025 – 2029',
          }
        ];
      }
      return [];
    }
  }

  // =============================================================
  // SECTION 6: Education
  // =============================================================
  Widget _buildEducationSection() {
    final educations = _getEducationList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Education (${educations.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 16),
          if (educations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No education details added yet.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
              ),
            )
          else ...[
            for (int i = 0; i < educations.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/images/mits_logo.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school,
                          size: 22,
                          color: Color(0xFF0F4C81),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          educations[i]['school']?.toString() ?? 'Madhav Institute of Technology and Science, Gwalior',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                        ),
                        if (educations[i]['degree'] != null && educations[i]['degree'].toString().isNotEmpty)
                          Text(
                            educations[i]['degree'].toString(),
                            style: const TextStyle(fontSize: 13, color: Color(0xFF191919)),
                          ),
                        if (educations[i]['duration'] != null && educations[i]['duration'].toString().isNotEmpty)
                          Text(
                            educations[i]['duration'].toString(),
                            style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (i < educations.length - 1) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 16),
              ],
            ],
          ],
        ],
      ),
    );
  }

  // =============================================================
  // SECTION 7: Projects 
  // =============================================================
  List<Map<String, dynamic>> _getProjectsList() {
    if (widget.isOwnProfile) {
      return ProfilePinsManager.getPinnedProjects();
    } else {
      final List<dynamic>? userProjects = widget.userData?['projects'] as List<dynamic>?;
      if (userProjects != null && userProjects.isNotEmpty) {
        return userProjects.map((p) => Map<String, dynamic>.from(p as Map)).toList();
      }
      return [];
    }
  }

  Widget _buildProjectsSection() {
    final projects = _getProjectsList();
    final displayedProjects = _showAllProjects ? projects : projects.take(2).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Projects (${projects.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No projects added yet.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
              ),
            )
          else ...[
            for (int i = 0; i < displayedProjects.length; i++) ...[
              _buildProjectItem(i, displayedProjects[i]),
              if (i < displayedProjects.length - 1) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 16),
              ],
            ],
            if (projects.length > 2) ...[
              const SizedBox(height: 16),
              Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAllProjects = !_showAllProjects;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAllProjects ? 'Show less' : 'Show all (${projects.length})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showAllProjects ? Icons.keyboard_arrow_up : Icons.arrow_forward,
                          size: 18,
                          color: const Color(0xFF0A66C2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProjectItem(int index, Map<String, dynamic> proj) {
    final bool isExpanded = _expandedProjectIndices.contains(index);
    final String desc = proj['description']?.toString() ?? '';
    final String title = proj['title']?.toString() ?? '';
    final String time = proj['time']?.toString() ?? proj['duration']?.toString() ?? '';
    final String association = proj['association']?.toString() ?? proj['organization']?.toString() ?? '';
    final String assocLower = association.toLowerCase();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailsScreen(projectData: proj),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: assocLower.contains('quantaforze')
                        ? Image.asset(
                            'assets/images/quantaforze_logo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            assocLower.contains('mits')
                                ? 'assets/images/mits_logo.png'
                                : 'assets/images/acadyk_logo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.folder_outlined,
                              size: 22,
                              color: Color(0xFF0F4C81),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
                      if (time.isNotEmpty)
                        Text(time, style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
                      if (association.isNotEmpty)
                        Text(association, style: const TextStyle(fontSize: 13, color: Color(0xFF191919))),
                    ],
                  ),
                ),
              ],
            ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedProjectIndices.remove(index);
                    } else {
                      _expandedProjectIndices.add(index);
                    }
                  });
                },
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13.5, color: Color(0xFF191919), height: 1.4),
                    children: [
                      TextSpan(
                        text: isExpanded
                            ? desc
                            : (desc.length > 120 ? '${desc.substring(0, 120)}...' : desc),
                      ),
                      if (desc.length > 120)
                        TextSpan(
                          text: isExpanded ? ' Show less' : ' more',
                          style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =============================================================
  // SECTION 8: Skills & Connected Apps
  // =============================================================
  List<Map<String, String>> _getSkillsList() {
    if (widget.isOwnProfile) {
      final pinned = ProfilePinsManager.getPinnedSkills();
      if (pinned.isNotEmpty) {
        return pinned;
      }
      return ProfileManager.skills;
    } else {
      final List<dynamic>? userSkills = widget.userData?['skills'] as List<dynamic>?;
      if (userSkills != null && userSkills.isNotEmpty) {
        return userSkills.map((s) {
          if (s is Map) {
            return Map<String, String>.from(s.map((k, v) => MapEntry(k.toString(), v.toString())));
          }
          return <String, String>{'name': s.toString(), 'association': ''};
        }).toList();
      }
      return [];
    }
  }

  Widget _buildSkillsSection() {
    final skills = _getSkillsList();
    final displayedSkills = _showAllSkills ? skills : skills.take(2).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
            ],
          ),
          const SizedBox(height: 16),
          if (skills.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No skills added yet.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
              ),
            )
          else ...[
            for (int i = 0; i < displayedSkills.length; i++) ...[
              _buildSkillItem(displayedSkills[i]),
              if (i < displayedSkills.length - 1) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 14),
              ],
            ],
            if (skills.length > 2) ...[
              const SizedBox(height: 16),
              Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAllSkills = !_showAllSkills;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAllSkills ? 'Show less' : 'Show all skills (${skills.length})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showAllSkills ? Icons.keyboard_arrow_up : Icons.arrow_forward,
                          size: 18,
                          color: const Color(0xFF0A66C2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSkillItem(Map<String, String> skill) {
    final String name = skill['name']?.toString() ?? '';
    final String association = skill['association']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
        if (association.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.check_circle_outline, size: 13, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(association, style: const TextStyle(fontSize: 13, color: Color(0xFF191919))),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // =============================================================
  // SECTION 9: Clubs & Organizations
  // =============================================================
  List<Map<String, dynamic>> _getClubsList() {
    if (widget.isOwnProfile) {
      return ProfilePinsManager.getPinnedClubs();
    } else {
      final List<dynamic>? userClubs = widget.userData?['clubs'] as List<dynamic>?;
      if (userClubs != null && userClubs.isNotEmpty) {
        return userClubs.map((c) => Map<String, dynamic>.from(c as Map)).toList();
      }
      return [];
    }
  }

  Widget _buildClubsSection() {
    final clubs = _getClubsList();
    final displayedClubs = _showAllClubs ? clubs : clubs.take(2).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clubs & Student Chapters (${clubs.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 16),
          if (clubs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No clubs or student chapters added yet.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
              ),
            )
          else ...[
            for (int i = 0; i < displayedClubs.length; i++) ...[
              _buildClubItem(displayedClubs[i]),
              if (i < displayedClubs.length - 1) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 16),
              ],
            ],
            if (clubs.length > 2) ...[
              const SizedBox(height: 16),
              Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAllClubs = !_showAllClubs;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAllClubs ? 'Show less' : 'Show all clubs (${clubs.length})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showAllClubs ? Icons.keyboard_arrow_up : Icons.arrow_forward,
                          size: 18,
                          color: const Color(0xFF0A66C2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildClubItem(Map<String, dynamic> club) {
    final String name = club['name']?.toString() ?? club['title']?.toString() ?? '';
    final String role = club['role']?.toString() ?? club['subtitle']?.toString() ?? '';
    final String? org = club['organization']?.toString();
    final String? duration = club['duration']?.toString();
    final String? description = club['description']?.toString();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClubDetailsScreen(
              clubData: {
                'title': name,
                'name': name,
                'category': 'Student Chapter',
                'location': org ?? 'MITS Campus, Gwalior',
                'time': duration ?? 'Active Chapter',
                'description': description ?? 'Official student chapter fostering collaborative learning, technical workshops, open source innovation, and campus hackathons.',
                'organizerName': role.isNotEmpty ? role : 'Core Student Committee',
                'organizerRole': 'Leadership & Core Team',
                'memberCount': '450+ Members',
                'heroImage': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=1200&auto=format&fit=crop&q=80',
                'address': 'Madhav Institute of Technology & Science, Racecourse Road, Gwalior',
                'price': 'Free',
                'priceUnit': '/open access',
              },
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: club['iconBg'] as Color? ?? const Color(0xFF0F4C81),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                club['icon'] as IconData? ?? Icons.groups_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191919),
                      ),
                    ),
                  if (role.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                  if (org != null && org.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      org,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                  if (duration != null && duration.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF191919),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // SECTION 10: Responsibilities
  // =============================================================
  List<Map<String, dynamic>> _getResponsibilitiesList() {
    if (widget.isOwnProfile) {
      return ProfilePinsManager.getPinnedResponsibilities();
    } else {
      final List<dynamic>? userResp = widget.userData?['responsibilities'] as List<dynamic>?;
      if (userResp != null && userResp.isNotEmpty) {
        return userResp.map((r) => Map<String, dynamic>.from(r as Map)).toList();
      }
      return [];
    }
  }

  Widget _buildResponsibilitiesSection() {
    final list = _getResponsibilitiesList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Positions of Responsibility (${list.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < list.length; i++) ...[
            _buildResponsibilityItem(list[i]),
            if (i < list.length - 1) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildResponsibilityItem(Map<String, dynamic> item) {
    final title = item['title']?.toString() ?? '';
    final org = item['organization']?.toString() ?? '';
    final duration = item['duration']?.toString() ?? '';
    final location = item['location']?.toString() ?? '';
    final description = item['description']?.toString() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.groups_2_rounded, size: 24, color: Color(0xFF8B5CF6)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              if (org.isNotEmpty)
                Text(org, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              if (duration.isNotEmpty)
                Text(duration, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              if (location.isNotEmpty)
                Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF191919), height: 1.35)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // =============================================================
  // SECTION 11: Licenses & Certifications
  // =============================================================
  List<Map<String, dynamic>> _getCertificatesList() {
    if (widget.isOwnProfile) {
      return ProfilePinsManager.getPinnedCertificates();
    } else {
      final List<dynamic>? userCerts = widget.userData?['certificates'] as List<dynamic>?;
      if (userCerts != null && userCerts.isNotEmpty) {
        return userCerts.map((c) => Map<String, dynamic>.from(c as Map)).toList();
      }
      return [];
    }
  }

  Widget _buildCertificatesSection() {
    final list = _getCertificatesList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Licenses & Certifications (${list.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < list.length; i++) ...[
            _buildCertificateItem(list[i]),
            if (i < list.length - 1) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCertificateItem(Map<String, dynamic> item) {
    final title = item['title']?.toString() ?? '';
    final org = item['issuingOrg']?.toString() ?? '';
    final issueDate = item['issueDate']?.toString() ?? '';
    final credUrl = item['credentialUrl']?.toString() ?? '';
    final description = item['description']?.toString() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEA580C).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.workspace_premium_rounded, size: 24, color: Color(0xFFEA580C)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              if (org.isNotEmpty)
                Text(org, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              if (issueDate.isNotEmpty)
                Text('Issued $issueDate', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              if (credUrl.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  credUrl,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF0073B1), decoration: TextDecoration.underline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF191919), height: 1.35)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // =============================================================
  // SECTION 12: Honors & Achievements
  // =============================================================
  List<Map<String, dynamic>> _getAchievementsList() {
    if (widget.isOwnProfile) {
      return ProfilePinsManager.getPinnedAchievements();
    } else {
      final List<dynamic>? userAchv = widget.userData?['achievements'] as List<dynamic>?;
      if (userAchv != null && userAchv.isNotEmpty) {
        return userAchv.map((a) => Map<String, dynamic>.from(a as Map)).toList();
      }
      return [];
    }
  }

  Widget _buildAchievementsSection() {
    final list = _getAchievementsList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Honors & Awards (${list.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < list.length; i++) ...[
            _buildAchievementItem(list[i]),
            if (i < list.length - 1) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> item) {
    final title = item['title']?.toString() ?? '';
    final org = item['issuingOrg']?.toString() ?? '';
    final date = item['date']?.toString() ?? '';
    final description = item['description']?.toString() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.emoji_events_rounded, size: 24, color: Color(0xFFF59E0B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              if (org.isNotEmpty)
                Text(org, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              if (date.isNotEmpty)
                Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF191919), height: 1.35)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showImagePreviewDialog({
    required String title,
    required Widget imageWidget,
    bool isAvatar = false,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar with Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Image Container with Zoom & Pan support
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(dialogContext).size.height * 0.65,
                    maxWidth: 480,
                  ),
                  color: Colors.black45,
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.5,
                    child: imageWidget,
                  ),
                ),
              ),
              if (widget.isOwnProfile) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: Text(
                    isAvatar ? 'Change Profile Photo' : 'Change Cover Photo',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsEditProfileScreen(),
                      ),
                    );
                    _onProfileUpdated();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerFullImageWidget() {
    if (widget.isOwnProfile && ProfileManager.bannerBytes != null) {
      return Image.memory(
        ProfileManager.bannerBytes!,
        fit: BoxFit.contain,
      );
    }
    if (_coverPhotoUrl != null && _coverPhotoUrl!.isNotEmpty) {
      if (_coverPhotoUrl!.startsWith('http')) {
        return Image.network(
          _coverPhotoUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/young_entrepreneur.jpg', fit: BoxFit.contain);
          },
        );
      } else if (_coverPhotoUrl!.startsWith('assets/')) {
        return Image.asset(
          _coverPhotoUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/young_entrepreneur.jpg', fit: BoxFit.contain);
          },
        );
      } else {
        if (kIsWeb) {
          return Image.network(_coverPhotoUrl!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Image.asset('assets/images/young_entrepreneur.jpg', fit: BoxFit.contain));
        } else {
          return Image.file(File(_coverPhotoUrl!), fit: BoxFit.contain, errorBuilder: (_, __, ___) => Image.asset('assets/images/young_entrepreneur.jpg', fit: BoxFit.contain));
        }
      }
    }
    return Image.asset(
      'assets/images/young_entrepreneur.jpg',
      fit: BoxFit.contain,
    );
  }

  Widget _buildAvatarFullImageWidget({
    required String? photoUrl,
    required String avatarString,
    required String initials,
    required int bgColorHex,
    required bool isMITS,
  }) {
    if (widget.isOwnProfile && ProfileManager.avatarBytes != null) {
      return Image.memory(
        ProfileManager.avatarBytes!,
        fit: BoxFit.contain,
      );
    }
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        return Image.network(
          photoUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex),
        );
      } else if (photoUrl.startsWith('assets/')) {
        return Image.asset(
          photoUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex),
        );
      } else {
        if (kIsWeb) {
          return Image.network(photoUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex));
        } else {
          return Image.file(File(photoUrl), fit: BoxFit.contain, errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex));
        }
      }
    }

    if (avatarString.isNotEmpty && avatarString.startsWith('assets/')) {
      return Image.asset(
        avatarString,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex),
      );
    }

    if (isMITS) {
      return Image.asset(
        'assets/images/mits_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildInitialsFallback('MITS', bgColorHex),
      );
    }

    return _buildInitialsFallback(initials, bgColorHex);
  }

  Widget _buildBannerImageWidget() {
    if (widget.isOwnProfile && ProfileManager.bannerBytes != null) {
      return Image.memory(
        ProfileManager.bannerBytes!,
        fit: BoxFit.cover,
        height: 215,
        width: double.infinity,
      );
    }
    if (_coverPhotoUrl != null && _coverPhotoUrl!.isNotEmpty) {
      if (_coverPhotoUrl!.startsWith('http')) {
        return Image.network(
          _coverPhotoUrl!,
          fit: BoxFit.cover,
          height: 215,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/young_entrepreneur.jpg', fit: BoxFit.cover, height: 215, width: double.infinity);
          },
        );
      } else if (_coverPhotoUrl!.startsWith('assets/')) {
        return Image.asset(
          _coverPhotoUrl!,
          fit: BoxFit.cover,
          height: 215,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/young_entrepreneur.jpg', fit: BoxFit.cover, height: 215, width: double.infinity);
          },
        );
      } else {
        if (kIsWeb) {
          return Image.network(_coverPhotoUrl!, fit: BoxFit.cover, height: 215, width: double.infinity, errorBuilder: (_, __, ___) => Image.asset('assets/images/young_entrepreneur.jpg', fit: BoxFit.cover, height: 215, width: double.infinity));
        } else {
          return Image.file(File(_coverPhotoUrl!), fit: BoxFit.cover, height: 215, width: double.infinity, errorBuilder: (_, __, ___) => Image.asset('assets/images/young_entrepreneur.jpg', fit: BoxFit.cover, height: 215, width: double.infinity));
        }
      }
    }
    return Image.asset(
      'assets/images/young_entrepreneur.jpg',
      fit: BoxFit.cover,
      height: 215,
      width: double.infinity,
    );
  }

  Widget _buildAvatarImageWidget({
    required String? photoUrl,
    required String avatarString,
    required String initials,
    required int bgColorHex,
    required bool isMITS,
  }) {
    if (widget.isOwnProfile && ProfileManager.avatarBytes != null) {
      return Image.memory(
        ProfileManager.avatarBytes!,
        fit: BoxFit.cover,
      );
    }
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        return Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex),
        );
      } else if (photoUrl.startsWith('assets/')) {
        return Image.asset(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex),
        );
      } else {
        if (kIsWeb) {
          return Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex));
        } else {
          return Image.file(File(photoUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex));
        }
      }
    }

    if (avatarString.isNotEmpty && avatarString.startsWith('assets/')) {
      return Image.asset(
        avatarString,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitialsFallback(initials, bgColorHex),
      );
    }

    if (isMITS) {
      return Image.asset(
        'assets/images/mits_logo.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitialsFallback('MITS', bgColorHex),
      );
    }

    return _buildInitialsFallback(initials, bgColorHex);
  }

  Widget _buildInitialsFallback(String initials, int bgColorHex) {
    return Container(
      color: Color(bgColorHex),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    );
  }

  void _showProfileOptionsBottomSheet(BuildContext context) {
    final String currentMemberName = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? (ProfileManager.name.isNotEmpty ? ProfileManager.name : 'Acadyk Member') : 'Member');
    final String currentMemberAvatar = _profilePhotoUrl ?? widget.userData?['avatar'] ?? (widget.isOwnProfile ? ProfileManager.avatarUrl : '');
    final String currentMemberBio = _profileBio ?? widget.userData?['headline'] ?? widget.userData?['bio'] ?? (widget.isOwnProfile ? ProfileManager.bio : 'Acadyk Member');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              _buildBottomSheetOption(
                icon: Icons.near_me_outlined,
                title: 'Send profile in a message',
                onTap: () {
                  Navigator.pop(context);
                  _showSendProfileInMessageBottomSheet(
                    context,
                    currentMemberName,
                    currentMemberAvatar,
                    currentMemberBio,
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.share_outlined,
                title: 'Share via...',
                onTap: () {
                  Navigator.pop(context);
                  _showShareProfileBottomSheet(
                    context,
                    currentMemberName,
                    currentMemberAvatar,
                    currentMemberBio,
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.import_contacts_outlined,
                title: 'Contact info',
                onTap: () {
                  Navigator.pop(context);
                  _showContactInfoBottomSheet(context);
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.info_outline,
                title: 'About this member',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AboutAccountScreen(
                        accountData: {
                          'name': currentMemberName,
                          'username': widget.userData?['username'] ?? (widget.isOwnProfile ? ProfileManager.username : currentMemberName.toLowerCase().replaceAll(' ', '_')),
                          'email': widget.isOwnProfile
                              ? (ProfileManager.email.isNotEmpty ? ProfileManager.email : (AuthService.currentUser?.email ?? ''))
                              : (widget.userData?['email'] ?? widget.userData?['collegeEmail'] ?? '${currentMemberName.toLowerCase().replaceAll(' ', '.')}@acadyk.edu'),
                          'avatarUrl': currentMemberAvatar,
                          'avatarBytes': widget.isOwnProfile ? ProfileManager.avatarBytes : null,
                          'branch': widget.isOwnProfile
                              ? (ProfileManager.branch.isNotEmpty ? ProfileManager.branch : 'Computer Science & Engineering')
                              : (widget.userData?['branch'] ?? widget.userData?['department'] ?? 'Computer Science & Engineering'),
                          'department': widget.isOwnProfile
                              ? (ProfileManager.degree.isNotEmpty ? ProfileManager.degree : 'Information Technology')
                              : (widget.userData?['department'] ?? 'Engineering & Technology'),
                          'academicSession': widget.userData?['academicSession'] ?? (widget.isOwnProfile ? ProfileManager.academicSession : '2022 – 2026'),
                          'mentorName': widget.userData?['mentorName'] ?? widget.userData?['mentorFaculty'] ?? ProfileManager.mentorFaculty,
                          'estYear': widget.userData?['estYear'] ?? ProfileManager.estYear,
                          'isOfficial': widget.userData?['isOfficial'] == true ||
                              (widget.userData?['role'] == 'official') ||
                              (currentMemberName.toLowerCase().contains('mits gwalior') || currentMemberName.toLowerCase().contains('madhav institute')),
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // 1. SEND PROFILE IN A MESSAGE MODAL
  // -------------------------------------------------------------
  void _showSendProfileInMessageBottomSheet(
    BuildContext context,
    String memberName,
    String memberAvatar,
    String memberBio,
  ) {
    final TextEditingController messageCtrl = TextEditingController();
    final TextEditingController searchCtrl = TextEditingController();
    final Set<String> sentToHandles = {};
    String filterText = '';

    final List<Map<String, dynamic>> mockConnections = [
      {
        'name': 'Somraj Dev',
        'handle': 'somraj_dev',
        'headline': 'Founder @ Nexure Agents & Black Torque',
        'avatar': 'assets/images/user_avatar.jpg',
        'color': const Color(0xFF1565C0),
      },
      {
        'name': 'Dharmik Patel',
        'handle': 'dharmik_patel',
        'headline': 'Full Stack Developer | Open Source Contributor',
        'avatar': 'assets/images/dharmik_avatar.jpg',
        'color': const Color(0xFF0D9488),
      },
      {
        'name': 'Alina Sprongole',
        'handle': 'alina_sprongole',
        'headline': 'Tech Lead & Engineer @ Google',
        'avatar': 'assets/images/alina_avatar.jpg',
        'color': const Color(0xFF7C3AED),
      },
      {
        'name': 'Christian Pickett',
        'handle': 'christian_pickett',
        'headline': 'Co-founder @ Orthogonal (YC W26)',
        'avatar': 'assets/images/dharmik_avatar.jpg',
        'color': const Color(0xFFEA580C),
      },
      {
        'name': 'Somraj Ghosh',
        'handle': 'somraj_ghosh',
        'headline': 'Founder & CEO @ Layrda',
        'avatar': 'assets/images/somraj_avatar.jpg',
        'color': const Color(0xFF0284C7),
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final filteredList = mockConnections.where((c) {
              final n = (c['name'] as String).toLowerCase();
              final h = (c['handle'] as String).toLowerCase();
              return n.contains(filterText) || h.contains(filterText);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.85,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            const Text(
                              'Send profile in message',
                              style: TextStyle(
                                fontSize: 17.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 22),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),

                      // Profile Card Preview Snippet
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1565C0),
                                ),
                                child: ClipOval(
                                  child: memberAvatar.isNotEmpty
                                      ? (memberAvatar.startsWith('http')
                                          ? Image.network(memberAvatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(memberName.isNotEmpty ? memberName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
                                          : Image.asset(memberAvatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(memberName.isNotEmpty ? memberName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))
                                      : Center(child: Text(memberName.isNotEmpty ? memberName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memberName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      memberBio.isNotEmpty ? memberBio : 'Acadyk Member',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F4C81).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Profile Card',
                                  style: TextStyle(
                                    color: Color(0xFF0F4C81),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Optional Note Text Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: messageCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Add an optional message...',
                              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                        ),
                      ),

                      // Search contacts field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: searchCtrl,
                                  onChanged: (val) {
                                    setModalState(() {
                                      filterText = val.toLowerCase().trim();
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search connections...',
                                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Connections List
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          itemCount: filteredList.length,
                          itemBuilder: (context, idx) {
                            final item = filteredList[idx];
                            final String handle = item['handle'];
                            final String name = item['name'];
                            final String headline = item['headline'];
                            final String avatarAsset = item['avatar'];
                            final Color avatarColor = item['color'];
                            final bool isSent = sentToHandles.contains(handle);

                            return InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DirectMessageScreen(
                                      name: name,
                                      handle: handle,
                                      avatarColor: avatarColor,
                                      avatarIcon: Icons.person,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: avatarColor,
                                      backgroundImage: AssetImage(avatarAsset),
                                      onBackgroundImageError: (_, __) {},
                                      child: Text(
                                        name[0],
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.5,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            headline,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          if (!isSent) {
                                            sentToHandles.add(handle);
                                          }
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Profile sent to $name!'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: const Color(0xFF0F172A),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSent ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isSent ? 'Sent' : 'Send',
                                          style: TextStyle(
                                            color: isSent ? const Color(0xFF475569) : Colors.white,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // 2. SHARE VIA... MODAL
  // -------------------------------------------------------------
  void _showShareProfileBottomSheet(
    BuildContext context,
    String memberName,
    String memberAvatar,
    String memberBio,
  ) {
    final String memberUsername = widget.userData?['username'] ?? memberName.toLowerCase().replaceAll(' ', '_');
    final String profileUrl = 'https://acadyk.app/u/$memberUsername';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    const Text(
                      'Share profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Profile Link Box with Copy Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, size: 22, color: Color(0xFF0F4C81)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          profileUrl,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: profileUrl));
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile link copied to clipboard!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Color(0xFF0F172A),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Copy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Social Channels Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShareChannelButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: 'Check out $memberName on Acadyk: $profileUrl'));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing to WhatsApp (Link copied)'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF25D366),
                          ),
                        );
                      },
                    ),
                    _buildShareChannelButton(
                      icon: Icons.alternate_email_rounded,
                      label: 'X (Twitter)',
                      color: const Color(0xFF0F172A),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: 'Discover $memberName ($memberBio) on @Acadyk: $profileUrl'));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post ready to share on X (Copied)'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF0F172A),
                          ),
                        );
                      },
                    ),
                    _buildShareChannelButton(
                      icon: Icons.business_center_rounded,
                      label: 'LinkedIn',
                      color: const Color(0xFF0A66C2),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: profileUrl));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing to LinkedIn (Link copied)'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF0A66C2),
                          ),
                        );
                      },
                    ),
                    _buildShareChannelButton(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      color: const Color(0xFFEA4335),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: 'Check out $memberName\'s Acadyk profile: $profileUrl'));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email share text copied!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFFEA4335),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareChannelButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. CONTACT INFO MODAL
  // -------------------------------------------------------------
  void _showContactInfoBottomSheet(BuildContext context) {
    final String currentMemberName = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? (ProfileManager.name.isNotEmpty ? ProfileManager.name : 'Acadyk Member') : 'Member');
    final String contactEmail = widget.isOwnProfile
        ? (ProfileManager.email.isNotEmpty ? ProfileManager.email : (AuthService.currentUser?.email ?? ''))
        : (widget.userData?['email'] ?? widget.userData?['collegeEmail'] ?? '${currentMemberName.toLowerCase().replaceAll(' ', '.')}@acadyk.edu');
    final String contactWebsite = widget.isOwnProfile
        ? (ProfileManager.website.isNotEmpty ? ProfileManager.website : 'https://acadyk.com')
        : (widget.userData?['website'] ?? 'https://${currentMemberName.toLowerCase().replaceAll(' ', '')}.dev');
    final String contactLocation = widget.isOwnProfile
        ? (ProfileManager.location.isNotEmpty ? ProfileManager.location : 'Gwalior, Madhya Pradesh, India')
        : (widget.userData?['location'] ?? 'Indore, Madhya Pradesh, India');
    final String contactCollege = widget.isOwnProfile
        ? 'Madhav Institute of Technology & Science (MITS)'
        : (widget.userData?['college'] ?? widget.userData?['university'] ?? 'Madhav Institute of Technology & Science (MITS)');
    final String memberUsername = widget.userData?['username'] ?? (widget.isOwnProfile ? ProfileManager.username : currentMemberName.toLowerCase().replaceAll(' ', '_'));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Contact info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Email
                _buildContactInfoTile(
                  context: context,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: contactEmail,
                  copyable: true,
                ),
                const SizedBox(height: 12),

                // Website / Portfolio
                _buildContactInfoTile(
                  context: context,
                  icon: Icons.language_rounded,
                  title: 'Portfolio / Website',
                  value: contactWebsite,
                  copyable: true,
                ),
                const SizedBox(height: 12),

                // Profile Link
                _buildContactInfoTile(
                  context: context,
                  icon: Icons.account_circle_outlined,
                  title: 'Acadyk Profile',
                  value: 'acadyk.app/u/$memberUsername',
                  copyable: true,
                ),
                const SizedBox(height: 12),

                // Location
                _buildContactInfoTile(
                  context: context,
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: contactLocation,
                  copyable: true,
                ),
                const SizedBox(height: 12),

                // Institution
                _buildContactInfoTile(
                  context: context,
                  icon: Icons.school_outlined,
                  title: 'Institution',
                  value: contactCollege,
                  copyable: false,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF0F172A)),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    bool copyable = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0F4C81).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF0F4C81)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF64748B)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied $title to clipboard!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF0F172A),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

}
