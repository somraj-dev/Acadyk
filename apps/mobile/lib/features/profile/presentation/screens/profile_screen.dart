import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../services/profile_manager.dart';
import 'about_account_screen.dart';
import 'your_account_screen.dart';
import 'settings_edit_profile_screen.dart';
import 'edit_status_screen.dart';
import 'connections_list_screen.dart';
import 'project_details.dart';
import '../../../feed/presentation/screens/post_detail_screen.dart';
import 'package:acadyk/common/services/auth_service.dart';
import 'package:acadyk/common/services/profile_service.dart';
import 'package:acadyk/common/services/post_service.dart';
import 'package:acadyk/common/services/follow_service.dart';

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
  String? _profileLocation;
  String? _profilePhotoUrl;
  String? _coverPhotoUrl;

  Timer? _bannerHoldTimer;
  Timer? _avatarHoldTimer;
  bool _avatarHoldTriggered = false;

  void _startBannerHoldTimer() {
    _bannerHoldTimer?.cancel();
    _bannerHoldTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _showImagePreviewDialog(
          title: 'Cover Photo',
          imageWidget: _buildBannerFullImageWidget(),
          isAvatar: false,
        );
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
    });
  }

  void _cancelAvatarHoldTimer() {
    _avatarHoldTimer?.cancel();
    _avatarHoldTimer = null;
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
    PostService.feedChangeNotifier.addListener(_onProfileUpdated);
    FollowService.followChangeNotifier.addListener(_onProfileUpdated);
  }

  @override
  void dispose() {
    _cancelBannerHoldTimer();
    _cancelAvatarHoldTimer();
    ProfileManager.profileUpdateNotifier.removeListener(_onProfileUpdated);
    PostService.feedChangeNotifier.removeListener(_onProfileUpdated);
    FollowService.followChangeNotifier.removeListener(_onProfileUpdated);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProfileData() async {
    if (widget.userData != null) {
      _profileName = widget.userData!['name'] ?? widget.userData!['full_name'] ?? widget.userData!['authorName'];
      _profileBio = widget.userData!['headline'] ?? widget.userData!['bio'] ?? widget.userData!['authorSubtitle'];
      _profileLocation = widget.userData!['location'];
      _profilePhotoUrl = widget.userData!['avatar'] ?? widget.userData!['avatarUrl'] ?? widget.userData!['profile_photo_url'];
      _coverPhotoUrl = widget.userData!['cover_photo_url'] ?? widget.userData!['banner'];
    } else {
      _profileName = widget.isOwnProfile ? (ProfileManager.name.isNotEmpty ? ProfileManager.name : (AuthService.currentUser?.fullName ?? '')) : '';
      _profileBio = widget.isOwnProfile ? ProfileManager.bio : '';
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
            _profileName = data['full_name'] ?? data['fullName'] ?? _profileName;
            _profileBio = data['bio'] ?? _profileBio;
            _profileLocation = data['location'] ?? _profileLocation;
            _profilePhotoUrl = data['profile_photo_url'] ?? data['profilePhotoUrl'] ?? _profilePhotoUrl;
            _coverPhotoUrl = data['cover_photo_url'] ?? data['coverPhotoUrl'] ?? _coverPhotoUrl;
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Search within profile loaded'),
                                duration: Duration(seconds: 1),
                              ),
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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _startBannerHoldTimer(),
                  onTapUp: (_) => _cancelBannerHoldTimer(),
                  onTapCancel: () => _cancelBannerHoldTimer(),
                  onPanDown: (_) => _startBannerHoldTimer(),
                  onPanEnd: (_) => _cancelBannerHoldTimer(),
                  onPanCancel: () => _cancelBannerHoldTimer(),
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

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: hasActiveStatus ? const Color(0xFFEF4444) : Colors.white,
                                width: hasActiveStatus ? 3.5 : 4.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: hasActiveStatus
                                      ? const Color(0xFFEF4444).withValues(alpha: 0.38)
                                      : Colors.black.withValues(alpha: 0.12),
                                  blurRadius: hasActiveStatus ? 12 : 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (_) {
                                _avatarHoldTriggered = false;
                                _startAvatarHoldTimer(avatar, initials, bgColorHex, isMITS);
                              },
                              onTapUp: (_) {
                                _cancelAvatarHoldTimer();
                                if (!_avatarHoldTriggered) {
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
                                      _showStatusDetailsDialog(
                                        name: name,
                                        emoji: '🎓',
                                        text: widget.userData?['headline'] ?? bio,
                                        isBusy: false,
                                      );
                                    }
                                  }
                                }
                              },
                              onTapCancel: () => _cancelAvatarHoldTimer(),
                              onPanDown: (_) {
                                _avatarHoldTriggered = false;
                                _startAvatarHoldTimer(avatar, initials, bgColorHex, isMITS);
                              },
                              onPanEnd: (_) => _cancelAvatarHoldTimer(),
                              onPanCancel: () => _cancelAvatarHoldTimer(),
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

  // =============================================================
  // SECTION 2: Summary / About
  // =============================================================
  Widget _buildAboutSection() {
    final String defaultSummary = widget.isOwnProfile
        ? (ProfileManager.summary.isNotEmpty ? ProfileManager.summary : (ProfileManager.bio.isNotEmpty ? ProfileManager.bio : 'No summary added yet.'))
        : (widget.userData?['summary'] ??
            widget.userData?['about'] ??
            (widget.userData?['bio'] != null && widget.userData!['bio'].toString().isNotEmpty ? widget.userData!['bio'] : 'No summary provided.'));

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
      return ProfileManager.experiences;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
            ],
          ),
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
    final String company = (exp['company'] ?? '').toString().toLowerCase();
    final String? customLogo = exp['logo'];
    final String? logoAsset = customLogo ?? (company.contains('quantaforze')
        ? 'assets/images/quantaforze_logo.png'
        : company.contains('mits')
            ? 'assets/images/mits_logo.png'
            : company.contains('acadyk')
                ? 'assets/images/acadyk_logo.png'
                : null);

    return Row(
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
              Text(exp['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              Text(exp['company']!, style: const TextStyle(fontSize: 13, color: Color(0xFF191919))),
              Text(exp['duration']!, style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
              Text(exp['location']!, style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
              if (exp['highlight'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.diamond, size: 14, color: Color(0xFF0A66C2)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        exp['highlight']!,
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
    );
  }

  List<Map<String, dynamic>> _getEducationList() {
    if (widget.isOwnProfile) {
      if (ProfileManager.education.isNotEmpty) {
        return ProfileManager.education;
      }
      if (ProfileManager.branch.isNotEmpty || ProfileManager.degree.isNotEmpty) {
        return [
          {
            'school': 'Madhav Institute of Technology and Science, Gwalior',
            'degree': '${ProfileManager.degree.isNotEmpty ? ProfileManager.degree : "Bachelor of Technology"}, ${ProfileManager.branch.isNotEmpty ? ProfileManager.branch : ""}',
            'duration': '2025 – 2029',
          }
        ];
      }
      return [];
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
          Row(
            children: const [
              Text('Education', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
            ],
          ),
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
                          educations[i]['school'] ?? 'Madhav Institute of Technology and Science, Gwalior',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                        ),
                        if (educations[i]['degree'] != null && educations[i]['degree'].toString().isNotEmpty)
                          Text(
                            educations[i]['degree']!,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF191919)),
                          ),
                        if (educations[i]['duration'] != null && educations[i]['duration'].toString().isNotEmpty)
                          Text(
                            educations[i]['duration']!,
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
      return ProfileManager.projects;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Projects (${projects.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
            ],
          ),
          const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildProjectItem(int index, Map<String, dynamic> proj) {
    final bool isExpanded = _expandedProjectIndices.contains(index);
    final String desc = proj['description'] as String;

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
                    child: (proj['association'] != null &&
                            proj['association'].toString().toLowerCase().contains('quantaforze'))
                        ? Image.asset(
                            'assets/images/quantaforze_logo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            proj['association'].toString().toLowerCase().contains('mits')
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(proj['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProjectDetailsScreen(projectData: proj)),
                              );
                            },
                            child: const Icon(Icons.arrow_outward, size: 18, color: Color(0xFF5E5E5E)),
                          ),
                        ],
                      ),
                      if (proj['time'] != null && proj['time'].toString().isNotEmpty)
                        Text(proj['time']!, style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
                      if (proj['association'] != null && proj['association'].toString().isNotEmpty)
                        Text(proj['association']!, style: const TextStyle(fontSize: 13, color: Color(0xFF191919))),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(skill['name']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
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
              child: Text(skill['association']!, style: const TextStyle(fontSize: 13, color: Color(0xFF191919))),
            ),
          ],
        ),
      ],
    );
  }

  // =============================================================
  // SECTION 9: Clubs & Organizations
  // =============================================================
  List<Map<String, dynamic>> _getClubsList() {
    if (widget.isOwnProfile) {
      return ProfileManager.clubs;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clubs & Organizations (${clubs.length})',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (clubs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No clubs or organizations added yet.',
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
    return Row(
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
              Text(
                club['name'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191919),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                club['role'] as String,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                club['organization'] as String,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                club['duration'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              if (club['description'] != null) ...[
                const SizedBox(height: 6),
                Text(
                  club['description'] as String,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile sent in message!')),
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.share_outlined,
                title: 'Share via...',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard!')),
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
                          'avatarUrl': currentMemberAvatar,
                          'dateJoined': '2026',
                          'location': widget.isOwnProfile ? (ProfileManager.location.isNotEmpty ? ProfileManager.location : 'Campus') : (widget.userData?['location'] ?? 'Campus'),
                          'sharedFollowers': 0,
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

  void _showContactInfoBottomSheet(BuildContext context) {
    final String contactEmail = widget.isOwnProfile
        ? (ProfileManager.email.isNotEmpty ? ProfileManager.email : (AuthService.currentUser?.email ?? ''))
        : (widget.userData?['email'] ?? widget.userData?['collegeEmail'] ?? '');
    final String contactWebsite = widget.isOwnProfile
        ? ProfileManager.website
        : (widget.userData?['website'] ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Contact info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF262626),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (contactEmail.isNotEmpty) ...[
                  _buildContactInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: contactEmail,
                  ),
                  const SizedBox(height: 16),
                ],
                if (contactWebsite.isNotEmpty) ...[
                  _buildContactInfoTile(
                    icon: Icons.link,
                    title: 'Website',
                    value: contactWebsite,
                  ),
                  const SizedBox(height: 16),
                ],
                if (contactEmail.isEmpty && contactWebsite.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No public contact information listed.',
                        style: TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                      ),
                    ),
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
            Icon(icon, size: 26, color: const Color(0xFF262626)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF262626),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F2EF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF5E5E5E)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF5E5E5E),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF191919),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
