import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  final GlobalKey _activityKey = GlobalKey();

  bool _isFollowing = false;
  bool _isSummaryExpanded = false;
  bool _showAllProjects = false;
  final Set<int> _expandedProjectIndices = {};
  bool _showAllExperience = false;
  bool _showAllSkills = false;
  bool _showAllClubs = false;

  bool _isActivityLiked = false;
  int _activityLikesCount = 12;
  bool _isActivityBookmarked = false;
  bool _isPostTextExpanded = false;

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
      _profileLocation = widget.userData!['location'] ?? 'Gwalior, India';
      _profilePhotoUrl = widget.userData!['avatar'] ?? widget.userData!['avatarUrl'] ?? widget.userData!['profile_photo_url'];
      _coverPhotoUrl = widget.userData!['cover_photo_url'] ?? widget.userData!['banner'];
    } else {
      _profileName = widget.isOwnProfile ? ProfileManager.name : 'MITS Gwalior';
      _profileBio = widget.isOwnProfile
          ? ProfileManager.bio
          : 'Madhav Institute of Technology & Science, Gwalior (M.P.) • Premier Technical Institution Est. 1957';
      _profileLocation = widget.isOwnProfile ? ProfileManager.location : 'Gwalior, India';
      _profilePhotoUrl = widget.isOwnProfile ? ProfileManager.avatarUrl : 'assets/images/mits_logo.png';
      _coverPhotoUrl = widget.isOwnProfile ? ProfileManager.bannerUrl : 'assets/images/ocean_wave_header.png';
    }

    try {
      final userId = widget.isOwnProfile
          ? AuthService.currentUser?.id
          : widget.userData?['id'];
      if (userId != null) {
        final data = await ProfileService.getProfile(userId);
        if (data != null && mounted) {
          setState(() {
            _profileName = data['full_name'];
            _profileBio = data['bio'];
            _profileLocation = data['location'];
            _profilePhotoUrl = data['profile_photo_url'];
            _coverPhotoUrl = data['cover_photo_url'];
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

                    // SECTION 4: Activity
                    _buildActivitySection(),
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
    final String name = _profileName ?? widget.userData?['name'] ?? widget.userData?['full_name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'MITS Gwalior');
    final String currentAuthUser = AuthService.currentUser?.username ?? '';
    final String baseUsername = currentAuthUser.isNotEmpty ? currentAuthUser : ProfileManager.username;
    final String username = widget.userData != null
        ? '@${(widget.userData!['username'] ?? widget.userData!['handle'] ?? 'somrajlodhi').toString().toLowerCase().replaceAll('@', '')}'
        : (widget.isOwnProfile ? '@${baseUsername.replaceAll(' ', '').toLowerCase()}' : '@mitsgwalior');

    final String bio = _profileBio ?? widget.userData?['headline'] ?? widget.userData?['bio'] ?? (widget.isOwnProfile
        ? ProfileManager.bio
        : 'Madhav Institute of Technology & Science, Gwalior (M.P.) • Premier Technical Institution Est. 1957');

    final String avatar = widget.userData != null
        ? (widget.userData!['avatar'] ?? widget.userData!['avatarUrl'] ?? '')
        : (widget.isOwnProfile ? ProfileManager.avatarUrl : 'assets/images/mits_logo.png');

    final String initials = widget.userData?['initials'] ?? (name.isNotEmpty ? name.substring(0, min(2, name.length)).toUpperCase() : 'M');
    final int bgColorHex = widget.userData?['bgColor'] ?? 0xFF1565C0;
    final bool isMITS = name.contains('MITS');

    final String followingCount = widget.userData?['following']?.toString() ?? (widget.isOwnProfile ? '357' : '${(name.hashCode.abs() % 400 + 40)}');
    final String followersCount = widget.userData?['followers']?.toString() ?? (widget.isOwnProfile ? '197.3K' : '${((name.hashCode.abs() % 800 + 100) / 10).toStringAsFixed(1)}K');

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
                const SizedBox(height: 2),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  bio,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF334155),
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
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
                              userHandle: username,
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
                              userHandle: username,
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
    final String name = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'Somraj Lodhi');
    final String defaultSummary = widget.isOwnProfile
        ? 'I am a Machine Learning student at Madhav Institute of Technology and Science (MITS), Gwalior, with a strong interest in building scalable technology solutions at the intersection of healthcare and intelligent systems.\nCurrently, I am working on AxioVital, a modern digital health infrastructure layer, and Acadex, a student credential and institutional workflow platform.'
        : (widget.userData?['summary'] ??
            widget.userData?['about'] ??
            'I am $name, passionate about engineering, technology research, and active student collaboration at MITS Gwalior. Enthusiastic about creating meaningful, scalable solutions that empower developers, academia, and open-source communities.');

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
    final String name = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'Somraj Lodhi');
    final String bio = _profileBio ?? widget.userData?['headline'] ?? (widget.isOwnProfile ? ProfileManager.bio : 'Innovator at MITS');
    final String avatar = _profilePhotoUrl ?? widget.userData?['avatar'] ?? (widget.isOwnProfile ? ProfileManager.avatarUrl : 'assets/images/somraj_avatar.jpg');

    final List<Map<String, dynamic>> userCreatedItems = [];
    if (widget.isOwnProfile || name.contains('Somraj')) {
      final userPosts = PostService.getUserCreatedPosts();
      for (final p in userPosts) {
        userCreatedItems.add({
          'category': 'Post',
          'text': p['content'] ?? '',
          'imageAsset': (p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty) ? p['imageUrl'] : 'assets/images/arogya_dashboard.jpg',
          'reactions': p['likes'] ?? 0,
          'authorName': name,
          'authorHeadline': bio,
          'authorAvatar': avatar,
          'timeAgo': p['timeAgo'] ?? 'Just now',
        });
      }
    }

    final defaultItems = [
      {
        'category': 'Post',
        'text': "Healthcare isn't broken because of lack of technology — it's broken because of fragmentation across diagnostic workflows.",
        'imageAsset': 'assets/images/arogya_dashboard.jpg',
        'reactions': 13,
        'authorName': name,
        'authorHeadline': bio,
        'authorAvatar': avatar,
        'timeAgo': '2w',
      },
      {
        'category': 'Article',
        'text': "The Future of Decentralized Teamwork and Remote Engineering Collaborations in Higher Education.",
        'imageAsset': 'assets/images/warp_team.jpg',
        'reactions': 42,
        'authorName': name,
        'authorHeadline': bio,
        'authorAvatar': avatar,
        'timeAgo': '1mo',
      },
      {
        'category': 'Post',
        'text': "Deeply honored to be recognized among the top young student innovators and engineering builders of this year!",
        'imageAsset': 'assets/images/young_entrepreneur.jpg',
        'reactions': 58,
        'authorName': name,
        'authorHeadline': bio,
        'authorAvatar': avatar,
        'timeAgo': '3w',
      },
    ];

    return [...userCreatedItems, ...defaultItems];
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
  // SECTION 4: Activity
  // =============================================================
  Widget _buildActivitySection() {
    final String name = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'Somraj Lodhi');
    final String bio = _profileBio ?? widget.userData?['headline'] ?? (widget.isOwnProfile ? ProfileManager.bio : 'Innovator | Developer');
    final String avatar = _profilePhotoUrl ?? widget.userData?['avatar'] ?? (widget.isOwnProfile ? ProfileManager.avatarUrl : 'assets/images/somraj_avatar.jpg');

    const String postBody =
        'Akedex is built on a universal identity fabric for education. Every learner receives a lifelong Universal Academic ID from the first day of learning. We are transforming school-to-college transitions with unified verifiable credentials.';

    return Container(
      key: _activityKey,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                  ),
                  Text(
                    widget.isOwnProfile ? '197.3K followers' : 'Active contributor',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(
                        authorName: name,
                        authorHeadline: bio,
                        authorAvatar: avatar,
                        timeAgo: '3w',
                        postText: postBody,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Show all posts',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Author Row
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(
                    authorName: name,
                    authorHeadline: bio,
                    authorAvatar: avatar,
                    timeAgo: '3w',
                    postText: postBody,
                  ),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    avatar,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFF0F4C81),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 14, color: Color(0xFF0A66C2)),
                          if (widget.isOwnProfile) ...[
                            const SizedBox(width: 4),
                            Text('• You', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          ],
                        ],
                      ),
                      Text(
                        bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          Text('3w • Edited • ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          Icon(Icons.public, size: 12, color: Colors.grey[600]),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF5E5E5E)),
                  onPressed: () {
                    _showPostOptionsModal(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Post Text with expandable "more"
          GestureDetector(
            onTap: () {
              setState(() {
                _isPostTextExpanded = !_isPostTextExpanded;
              });
            },
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.45),
                children: [
                  TextSpan(
                    text: _isPostTextExpanded
                        ? postBody
                        : (postBody.length > 140 ? '${postBody.substring(0, 140)}...' : postBody),
                  ),
                  if (postBody.length > 140)
                    TextSpan(
                      text: _isPostTextExpanded ? ' Show less' : ' more',
                      style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Dark Banner / Media Card
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(
                    authorName: name,
                    authorHeadline: bio,
                    authorAvatar: avatar,
                    timeAgo: '3w',
                    postText: postBody,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: 220,
                color: const Color(0xFF1A1A1A),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.bottomCenter,
                          radius: 1.2,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 20,
                      top: 50,
                      child: Text(
                        'SOMETHING NEW\nIS COMING.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Icon(Icons.auto_awesome, size: 20, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'More thoughtful.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                          ),
                          Text(
                            'More intelligent.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Interactive Engagement Bar: Heart, Comments, Bookmark, Share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Like / Heart
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isActivityLiked = !_isActivityLiked;
                        _activityLikesCount += _isActivityLiked ? 1 : -1;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          _isActivityLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                          size: 24,
                          color: _isActivityLiked ? Colors.redAccent : Colors.black87,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_activityLikesCount',
                          style: TextStyle(
                            color: _isActivityLiked ? Colors.redAccent : Colors.black87,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Comment
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(
                            authorName: name,
                            authorHeadline: bio,
                            authorAvatar: avatar,
                            timeAgo: '3w',
                            postText: postBody,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(CupertinoIcons.chat_bubble, size: 23, color: Colors.black87),
                        SizedBox(width: 6),
                        Text(
                          '3',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Share
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post link copied to clipboard!')),
                      );
                    },
                    child: const Icon(CupertinoIcons.arrow_turn_up_right, size: 22, color: Colors.black87),
                  ),
                ],
              ),

              // Bookmark
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isActivityBookmarked = !_isActivityBookmarked;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isActivityBookmarked ? 'Post saved to bookmarks!' : 'Post removed from bookmarks'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(
                  _isActivityBookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                  size: 24,
                  color: _isActivityBookmarked ? const Color(0xFF0F4C81) : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPostOptionsModal(BuildContext context) {
    final String authorName = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'Somraj Lodhi');
    final String authorAvatar = _profilePhotoUrl ?? widget.userData?['avatar'] ?? (widget.isOwnProfile ? ProfileManager.avatarUrl : 'assets/images/somraj_avatar.jpg');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Top row of actions (Save, Repost, Share)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTopActionIcon(
                      _isActivityBookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                      'Save',
                      color: _isActivityBookmarked ? const Color(0xFF1E88E5) : Colors.black,
                      onTap: () {
                        setState(() {
                          _isActivityBookmarked = !_isActivityBookmarked;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isActivityBookmarked ? 'Post saved to bookmarks!' : 'Post removed from bookmarks'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    _buildTopActionIcon(
                      CupertinoIcons.repeat,
                      'Repost',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post reposted to your network!')),
                        );
                      },
                    ),
                    _buildTopActionIcon(
                      CupertinoIcons.paperplane,
                      'Share',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share options loaded!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Vertical list actions (Hide, About this account, Report)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildListAction(CupertinoIcons.eye_slash, 'Hide', onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post hidden from your feed')),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildListAction(CupertinoIcons.person, 'About this account', onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AboutAccountScreen(
                              accountData: {
                                'name': authorName,
                                'avatarUrl': authorAvatar,
                                'dateJoined': 'June 2024',
                                'location': _profileLocation ?? 'Gwalior, India',
                                'sharedFollowers': 18,
                              },
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildListAction(
                        CupertinoIcons.exclamationmark_bubble,
                        'Report',
                        color: const Color(0xFFED4956),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post reported for review.')),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopActionIcon(IconData icon, String label, {Color color = Colors.black, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildListAction(IconData icon, String label, {Color color = Colors.black, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SECTION 5: Experience
  // =============================================================
  List<Map<String, dynamic>> _getExperienceList() {
    final String name = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'Somraj Lodhi');

    if (widget.isOwnProfile || name.contains('Somraj')) {
      return [
        {
          'title': 'Founder',
          'company': 'Quantaforze Corporation · Full-time',
          'duration': 'Oct 2025 - Present · 9 mos',
          'location': 'Gwalior, Madhya Pradesh, India · On-site',
          'highlight': 'Start-up Leadership and Business Ownership',
        },
        {
          'title': 'AI & Machine Learning Researcher',
          'company': 'MITS Innovation & Research Lab · Part-time',
          'duration': 'Aug 2024 - Oct 2025 · 1 yr 3 mos',
          'location': 'Gwalior, India · Hybrid',
          'highlight': 'Deep Learning, Computer Vision & Edge AI',
        },
        {
          'title': 'Lead Mobile Architect',
          'company': 'Acadyk Open Systems · Open Source',
          'duration': 'Jan 2025 - Present · 6 mos',
          'location': 'Remote',
          'highlight': 'Cross-platform Mobile Architecture & Backend APIs',
        },
      ];
    } else {
      return [
        {
          'title': widget.userData?['headline'] ?? 'Lead Researcher & Developer',
          'company': 'MITS Gwalior · Full-time',
          'duration': '2024 - Present',
          'location': 'Gwalior, Madhya Pradesh, India',
          'highlight': 'Academic Innovation, Systems Architecture & Mentorship',
        },
        {
          'title': 'Technical Contributor',
          'company': 'Student Development Cell (SDC)',
          'duration': '2023 - 2024 · 1 yr',
          'location': 'Gwalior, India',
          'highlight': 'Campus Technology Solutions & Hackathons',
        },
      ];
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

  // =============================================================
  // SECTION 6: Education
  // =============================================================
  Widget _buildEducationSection() {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Madhav Institute of Technology and Science, Gwalior',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                    ),
                    Text(
                      'Bachelor of Technology - BTech, Artificial intelligence and machine learning',
                      style: TextStyle(fontSize: 13, color: Color(0xFF191919)),
                    ),
                    Text(
                      'Aug 2025 – Aug 2029',
                      style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SECTION 7: Projects 
  // =============================================================
  List<Map<String, dynamic>> _getProjectsList() {
    final String name = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'Somraj Lodhi');

    if (widget.isOwnProfile || name.contains('Somraj')) {
      return [
        {
          'title': 'Acadex',
          'time': 'Feb 2026 – Present',
          'association': 'Quantaforze Corporation',
          'description':
              'Acadex is a school-to-school or institute-to-institute student records and workflow network that simplifies credit transfer, academic verifications, and cross-campus collaboration with cryptographically signed micro-credentials.',
          'contributors': 3,
        },
        {
          'title': 'AxioVital',
          'time': 'Nov 2025 – Present',
          'association': 'Quantaforze Corporation',
          'description':
              'AxioVital is building the digital infrastructure layer for modern healthcare — connecting patients, clinics, and diagnostic labs in real-time with zero latency and AI-assisted triage telemetry.',
          'contributors': 4,
        },
        {
          'title': 'NeuralMesh AI',
          'time': 'Aug 2025 – Jan 2026',
          'association': 'MITS AI Research Lab',
          'description':
              'An open-source distributed edge inference network optimizing ONNX runtime models for mobile and IoT devices across low-bandwidth environments.',
          'contributors': 2,
        },
      ];
    } else {
      return [
        {
          'title': 'Campus Connect Hub',
          'time': '2025 – Present',
          'association': 'MITS-DU Engineering Portal',
          'description':
              'Collaborative engineering portal enabling student teams to publish research repositories, find project partners, and manage club events.',
          'contributors': 3,
        },
        {
          'title': 'Smart Diagnostic Classifier',
          'time': '2024 – 2025',
          'association': 'SDC Hackathon',
          'description':
              'Convolutional neural network for automatic classification of biomedical imagery with 96.4% test accuracy.',
          'contributors': 2,
        },
      ];
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    proj['title']!,
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF9CA3AF)),
              ],
            ),
            const SizedBox(height: 2),
            Text(proj['time']!, style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Image.asset(
                      proj['association'].toString().toLowerCase().contains('quantaforze')
                          ? 'assets/images/quantaforze_logo.png'
                          : proj['association'].toString().toLowerCase().contains('mits')
                              ? 'assets/images/mits_logo.png'
                              : 'assets/images/acadyk_logo.png',
                      width: 18,
                      height: 18,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.code, size: 12, color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Associated with ${proj['association']}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF191919)),
                  ),
                ),
              ],
            ),
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
                  style: const TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.4),
                  children: [
                    TextSpan(
                      text: isExpanded ? desc : (desc.length > 100 ? '${desc.substring(0, 100)}...' : desc),
                    ),
                    if (desc.length > 100)
                      TextSpan(
                        text: isExpanded ? ' Show less' : ' more',
                        style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Contributors', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: AssetImage('assets/images/somraj_avatar.jpg'), fit: BoxFit.cover),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage('assets/images/dharmik_avatar.jpg'), fit: BoxFit.cover),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-12, 0),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF0F0F0),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+${proj['contributors']}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5E5E5E)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // SECTION 8: Skills & Connected Apps
  // =============================================================
  List<Map<String, String>> _getSkillsList() {
    final String name = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'Somraj Lodhi');

    if (widget.isOwnProfile || name.contains('Somraj')) {
      return [
        {'name': 'Start-up Leadership', 'association': 'Founder at Quantaforze Corporation'},
        {'name': 'Business Ownership', 'association': 'Founder at Quantaforze Corporation'},
        {'name': 'Artificial Intelligence & Deep Learning', 'association': 'MITS AI Research Lab'},
        {'name': 'Flutter & Dart Mobile Architecture', 'association': 'Acadyk Production Stack'},
      ];
    } else {
      return [
        {'name': 'Applied Machine Learning', 'association': 'Certified Academic Researcher'},
        {'name': 'Full-Stack Development', 'association': 'Software Engineering Lead'},
        {'name': 'Open Source Collaboration', 'association': 'Community Contributor'},
      ];
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
    final String name = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'Somraj Lodhi');

    if (widget.isOwnProfile || name.contains('Somraj')) {
      return [
        {
          'name': 'Student Development Cell (SDC)',
          'role': 'Technical Core Lead & Platform Architect',
          'organization': 'MITS-DU Student Innovation & Technology Council',
          'duration': 'Aug 2024 – Present · 2 yrs',
          'icon': Icons.groups_rounded,
          'iconBg': const Color(0xFF0F4C81),
          'description': 'Leading campus software architectures, open-source repositories, and student hackathons.',
        },
        {
          'name': 'Google Developer Groups (GDG) on Campus',
          'role': 'AI/ML & Mobile App Core Member',
          'organization': 'GDG MITS Gwalior Chapter',
          'duration': 'Sep 2024 – Present',
          'icon': Icons.code_rounded,
          'iconBg': const Color(0xFF1E293B),
          'description': 'Mentoring students in Flutter, TensorFlow, and cloud architectures.',
        },
        {
          'name': 'ACM Student Chapter MITS',
          'role': 'Competitive Programming & Systems Research',
          'organization': 'ACM Chapter, Department of CSE & IT',
          'duration': '2024 – Present',
          'icon': Icons.terminal_rounded,
          'iconBg': const Color(0xFF4C1D95),
          'description': 'Organizing coding contests, algorithmic workshops, and research symposiums.',
        },
        {
          'name': 'MITS Robotics & AI Club (RAI)',
          'role': 'Edge Computing & Vision Systems Contributor',
          'organization': 'MITS Innovation Hub',
          'duration': '2024 – 2025',
          'icon': Icons.smart_toy_rounded,
          'iconBg': const Color(0xFF334155),
          'description': 'Designed lightweight neural network architectures for embedded microcontrollers.',
        },
      ];
    } else {
      final List<dynamic>? userClubs = widget.userData?['clubs'] as List<dynamic>?;
      if (userClubs != null && userClubs.isNotEmpty) {
        return userClubs.map((c) => Map<String, dynamic>.from(c as Map)).toList();
      }
      return [
        {
          'name': 'Student Development Cell (SDC)',
          'role': 'Technical Contributor',
          'organization': 'MITS-DU Student Council',
          'duration': '2024 – Present',
          'icon': Icons.groups_rounded,
          'iconBg': const Color(0xFF0F4C81),
          'description': 'Collaborating on student campus projects and workshops.',
        },
        {
          'name': 'Google Developer Groups (GDG) on Campus',
          'role': 'Campus Member',
          'organization': 'GDG MITS Chapter',
          'duration': '2024 – Present',
          'icon': Icons.code_rounded,
          'iconBg': const Color(0xFF1E293B),
          'description': 'Participating in developer events and technology sessions.',
        },
      ];
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerFullImageWidget() {
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
    final String currentMemberName = _profileName ?? widget.userData?['name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'Somraj Lodhi');
    final String currentMemberAvatar = _profilePhotoUrl ?? widget.userData?['avatar'] ?? (widget.isOwnProfile ? ProfileManager.avatarUrl : 'assets/images/somraj_avatar.jpg');

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
                          'dateJoined': 'June 2024',
                          'location': 'Gwalior, India',
                          'sharedFollowers': 18,
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
                _buildContactInfoTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: 'somraj.lodhi@acadyk.com',
                ),
                const SizedBox(height: 16),
                _buildContactInfoTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: '+91 98765 43210',
                ),
                const SizedBox(height: 16),
                _buildContactInfoTile(
                  icon: Icons.link,
                  title: 'Website',
                  value: 'https://acadyk.com',
                ),
                const SizedBox(height: 24),
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
