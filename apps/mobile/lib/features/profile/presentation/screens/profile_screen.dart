import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import '../services/profile_manager.dart';
import 'about_account_screen.dart';
import 'your_account_screen.dart';
import '../../../chat/presentation/screens/direct_message_screen.dart';
import 'edit_status_screen.dart';
import 'connections_list_screen.dart';
import 'package:acadyk/common/services/auth_service.dart';
import 'package:acadyk/common/services/storage_service.dart';
import 'package:acadyk/common/services/profile_service.dart';


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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 414),
            color: scaffoldBg,
            child: Stack(
              children: [
                // Scrollable content
                Positioned.fill(
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // =============================================
                      // SECTION 1: Profile Header Card
                      // =============================================
                      _buildProfileHeaderCard(),
                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 2: Summary / About
                      // =============================================
                      _buildAboutSection(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 3: Listed / Featured
                      // =============================================
                      _buildFeaturedSection(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 4: Activity
                      // =============================================
                      _buildActivitySection(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 5: Experience
                      // =============================================
                      _buildExperienceSection(),

                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 6: Education
                      // =============================================
                      _buildEducationSection(),
                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 7: Projects
                      // =============================================
                      _buildProjectsSection(),
                      const SizedBox(height: 8),

                      // =============================================
                      // SECTION 8: Skills & Connected Apps
                      // =============================================
                      _buildSkillsSection(),
                      const SizedBox(height: 8),
                      _buildConnectedAppsSection(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Transparent top overlay bar with dark translucent icons over banner
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      // Right side search and menu options
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const YourAccountScreen()),
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
                                Icons.menu,
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
      ),
    );
  }

  bool _isFollowing = false;
  String? _profileName;
  String? _profileBio;
  String? _profileLocation;
  String? _profilePhotoUrl;
  String? _coverPhotoUrl;

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
  }

  @override
  void dispose() {
    ProfileManager.profileUpdateNotifier.removeListener(_onProfileUpdated);
    _scrollController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentBio, String currentLocation) {
    final nameCtrl = TextEditingController(text: currentName);
    final bioCtrl = TextEditingController(text: currentBio);
    final locCtrl = TextEditingController(text: currentLocation);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: bioCtrl,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameCtrl.text.trim();
                final newBio = bioCtrl.text.trim();
                final newLoc = locCtrl.text.trim();

                setState(() {
                  _profileName = newName;
                  _profileBio = newBio;
                  _profileLocation = newLoc;
                });

                Navigator.pop(context);

                try {
                  final currentUser = AuthService.currentUser;
                  if (currentUser != null) {
                    await ProfileService.updateProfile(currentUser.id, {
                      'full_name': newName,
                      'bio': newBio,
                      'location': newLoc,
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully!')),
                      );
                    }
                  }
                } catch (_) {}
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
          width: 96,
          height: 96,
          errorBuilder: (context, error, stackTrace) {
            if (avatarString.isNotEmpty && avatarString.startsWith('assets/')) {
              return Image.asset(avatarString, fit: BoxFit.cover, width: 96, height: 96);
            }
            if (isMITS) {
              return Image.asset('assets/images/mits_logo.png', fit: BoxFit.cover, width: 96, height: 96);
            }
            return Image.asset('assets/images/somraj_avatar.jpg', fit: BoxFit.cover, width: 96, height: 96);
          },
        );
      } else if (photoUrl.startsWith('assets/')) {
        return Image.asset(
          photoUrl,
          fit: BoxFit.cover,
          width: 96,
          height: 96,
          errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/somraj_avatar.jpg', fit: BoxFit.cover, width: 96, height: 96),
        );
      }
    }
    if (avatarString.isNotEmpty && avatarString.startsWith('assets/')) {
      return Image.asset(
        avatarString,
        fit: BoxFit.cover,
        width: 96,
        height: 96,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/somraj_avatar.jpg', fit: BoxFit.cover, width: 96, height: 96),
      );
    }
    if (isMITS) {
      return Image.asset('assets/images/mits_logo.png', fit: BoxFit.cover, width: 96, height: 96);
    }
    return Container(
      width: 96,
      height: 96,
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

  Widget _buildBannerImageWidget() {
    if (_coverPhotoUrl != null && _coverPhotoUrl!.isNotEmpty && _coverPhotoUrl!.startsWith('http')) {
      return Image.network(
        _coverPhotoUrl!,
        fit: BoxFit.cover,
        height: 215,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/ocean_wave_header.png', fit: BoxFit.cover, height: 215, width: double.infinity);
        },
      );
    }
    if (_coverPhotoUrl != null && _coverPhotoUrl!.isNotEmpty && _coverPhotoUrl!.startsWith('assets/')) {
      return Image.asset(
        _coverPhotoUrl!,
        fit: BoxFit.cover,
        height: 215,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/ocean_wave_header.png', fit: BoxFit.cover, height: 215, width: double.infinity);
        },
      );
    }
    return Image.asset(
      'assets/images/ocean_wave_header.png',
      fit: BoxFit.cover,
      height: 215,
      width: double.infinity,
    );
  }

  void _loadProfileData() async {
    if (widget.userData != null) {
      _profileName = widget.userData!['name'] ?? widget.userData!['full_name'] ?? widget.userData!['authorName'];
      _profileBio = widget.userData!['headline'] ?? widget.userData!['bio'] ?? widget.userData!['authorSubtitle'];
      _profileLocation = widget.userData!['location'] ?? 'Gwalior, India';
      _profilePhotoUrl = widget.userData!['avatar'] ?? widget.userData!['avatarUrl'] ?? widget.userData!['profile_photo_url'];
      _coverPhotoUrl = widget.userData!['cover_photo_url'];
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

  Widget _buildProfileHeaderCard() {
    // Resolve dynamic values based on userData or defaults
    final String name = _profileName ?? widget.userData?['name'] ?? widget.userData?['full_name'] ?? (widget.isOwnProfile ? ProfileManager.name : 'MITS Gwalior');

    final String username = widget.userData != null 
        ? '@${name.replaceAll(' ', '').replaceAll('-', '').replaceAll('.', '').toLowerCase()}' 
        : (widget.isOwnProfile ? '@${ProfileManager.name.replaceAll(' ', '').toLowerCase()}' : '@mitsgwalior');

    final String bio = _profileBio ?? widget.userData?['headline'] ?? widget.userData?['bio'] ?? (widget.isOwnProfile 
        ? ProfileManager.bio 
        : 'Madhav Institute of Technology & Science, Gwalior (M.P.) • Premier Technical Institution Est. 1957');

    final String location = _profileLocation ?? widget.userData?['location'] ?? (widget.isOwnProfile ? ProfileManager.location : 'Gwalior, India');

    final String avatar = widget.userData != null 
        ? (widget.userData!['avatar'] ?? widget.userData!['avatarUrl'] ?? '')
        : (widget.isOwnProfile ? ProfileManager.avatarUrl : 'assets/images/mits_logo.png');

    final String initials = widget.userData?['initials'] ?? (name.isNotEmpty ? name.substring(0, min(2, name.length)).toUpperCase() : 'M');
    final int bgColorHex = widget.userData?['bgColor'] ?? 0xFF1565C0;
    final bool isMITS = name.contains('MITS');

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner + Squircle Profile Photo Stack
          SizedBox(
            height: 250,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner Image (Aerial Monochrome Ocean Waves with bottom gradient overlay)
                GestureDetector(
                  onTap: widget.isOwnProfile
                      ? () async {
                          final file = await StorageService.pickImage();
                          if (file != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Uploading cover photo...')),
                            );
                            final url = await StorageService.uploadCoverPhoto(
                              AuthService.currentUser!.id,
                              file,
                            );
                            if (url != null) {
                              await ProfileService.updateProfile(
                                AuthService.currentUser!.id,
                                {'cover_photo_url': url},
                              );
                              setState(() {
                                _coverPhotoUrl = url;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cover photo updated successfully!')),
                              );
                            }
                          }
                        }
                      : null,
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

                // Profile Squircle Avatar overlapping the bottom of the banner
                Positioned(
                  left: 20,
                  bottom: 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: Colors.white, width: 4.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: widget.isOwnProfile
                              ? () async {
                                  final file = await StorageService.pickImage();
                                  if (file != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Uploading profile photo...')),
                                    );
                                    final url = await StorageService.uploadProfilePhoto(
                                      AuthService.currentUser!.id,
                                      file,
                                    );
                                    if (url != null) {
                                      await ProfileService.updateProfile(
                                        AuthService.currentUser!.id,
                                        {'profile_photo_url': url},
                                      );
                                      setState(() {
                                        _profilePhotoUrl = url;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Profile photo updated successfully!')),
                                      );
                                    }
                                  }
                                }
                              : null,
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

                      // Emoji status badge on bottom right corner of avatar
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: UserStatusState.statusNotifier,
                          builder: (context, statusValue, child) {
                            final displayEmoji = UserStatusState.emoji ?? '🤕';
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EditStatusScreen()),
                                );
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  displayEmoji,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons Row (Right Aligned: Three Dots + Mail + Edit Profile / Follow)
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 10.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Three dots button in white circle (Shortcuts when visiting another user's profile)
                if (!widget.isOwnProfile) ...[
                  GestureDetector(
                    onTap: () => _showProfileOptionsBottomSheet(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // Mail button in white circle
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DirectMessageScreen(
                          name: name,
                          handle: username,
                          avatarColor: const Color(0xFF6366F1),
                          avatarIcon: Icons.person,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(CupertinoIcons.mail, size: 20, color: Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(width: 10),

                // Edit Profile / Follow pill button
                if (widget.isOwnProfile)
                  GestureDetector(
                    onTap: () => _showEditProfileDialog(context, name, bio, location),
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

          // User Identity Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
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

                // Handle @somraj.lodhi
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),

                // Bio
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
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: '357',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            TextSpan(
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
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: '197.3K',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            TextSpan(
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
  // SUMMARY SECTION
  // =============================================================
  Widget _buildAboutSection() {
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
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text:
                      'I am a Machine Learning student at Madhav Institute of Technology and Science (MITS), Gwalior, with a strong interest in building scalable technology solutions at the intersection of healthcare and intelligent systems.\nCurrently, I am working on AxioVital, a...',
                ),
                TextSpan(
                  text: ' more',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // LISTED / FEATURED SECTION
  // =============================================================
  Widget _buildFeaturedSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                const Text(
                  'Listed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
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
                _buildFeaturedCard(
                  category: 'Post',
                  text: 'Healthcare isn\'t broken because of lack of technology — it\'s broken because of fragmentat...',
                  imageAsset: 'assets/images/arogya_dashboard.jpg',
                  reactions: '13',
                ),
                const SizedBox(width: 12),
                _buildFeaturedCard(
                  category: 'Article',
                  text: 'The Future of Decentralized Teamwork and Remote Engineering Collaborations...',
                  imageAsset: 'assets/images/warp_team.jpg',
                  reactions: '42',
                ),
                const SizedBox(width: 12),
                _buildFeaturedCard(
                  category: 'Post',
                  text: 'Deeply honored to be recognized among the top young innovators and entrepreneurs of this year...',
                  imageAsset: 'assets/images/young_entrepreneur.jpg',
                  reactions: '58',
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard({
    required String category,
    required String text,
    required String imageAsset,
    required String reactions,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              category,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 40,
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Color(0xFF191919), fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(7),
              bottomRight: Radius.circular(7),
            ),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A66C2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.thumb_up, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Text(reactions, style: const TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ACTIVITY SECTION
  // =============================================================
  Widget _buildActivitySection() {
    return Container(
      key: _activityKey,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
              ),
              Text(
                '168 followers',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
              ),
            ],
          ),
          const SizedBox(height: 14),



          // Activity post
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/somraj_avatar.jpg'),
                    fit: BoxFit.cover,
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
                        const Text(
                          'Somraj Lodhi',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_user, size: 14, color: Color(0xFF5E5E5E)),
                        const SizedBox(width: 4),
                        Text('• You', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                    Text(
                      'Founder | Thinker | Quant Engineer',
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
              const Icon(Icons.more_vert, size: 20, color: Color(0xFF5E5E5E)),
            ],
          ),
          const SizedBox(height: 10),

          // Post text
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.45),
              children: [
                TextSpan(text: 'Akedex is built on a universal identity fabric for education. Every learner receives a lifelong Universal Academic ID from the first day of...'),
                TextSpan(
                  text: ' more',
                  style: TextStyle(color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Dark post image
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: double.infinity,
              height: 260,
              color: const Color(0xFF2A2A2A),
              child: Stack(
                children: [
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.bottomCenter,
                        radius: 1.2,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Text content
                  const Positioned(
                    left: 24,
                    top: 80,
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
                  // Sparkle star
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Icon(Icons.auto_awesome, size: 18, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ),
                  // Bottom text
                  Positioned(
                    bottom: 30,
                    left: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'More thoughtful.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        ),
                        Text(
                          'More intelligent.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Engagement bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.heart, size: 24, color: Colors.black87),
                  const SizedBox(width: 6),
                  const Text(
                    '5',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(CupertinoIcons.chat_bubble, size: 24, color: Colors.black87),
                  const SizedBox(width: 6),
                  const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Icon(CupertinoIcons.bookmark, size: 24, color: Colors.black87),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // EXPERIENCE SECTION
  // =============================================================
  Widget _buildExperienceSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),

          // Quantaforze entry
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.crop_square, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Founder', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
                    Text('Quantaforze Corporation · Full-time', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
                    Text('Oct 2025 - Present · 9 mos', style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
                    Text('Gwalior, Madhya Pradesh, India · On-site', style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.diamond, size: 14, color: Color(0xFF5E5E5E)),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Start-up Leadership and Business Ownership',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                          ),
                        ),
                      ],
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
  // EDUCATION SECTION
  // =============================================================
  Widget _buildEducationSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Education', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // College logo placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.school, size: 22, color: Color(0xFF5E5E5E)),
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
  // CONNECTED APPS SECTION
  // =============================================================
  Widget _buildConnectedAppsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBDBDBD), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Connected apps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                ),
                const Icon(Icons.close, size: 22, color: Color(0xFF5E5E5E)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Add the products you use to stand out and get more profile views.',
              style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E), height: 1.4),
            ),
            const SizedBox(height: 14),

            // App grid
            Row(
              children: [
                Expanded(child: _buildAppChip('Gamma', Icons.g_mobiledata, const Color(0xFF7C3AED))),
                const SizedBox(width: 10),
                Expanded(child: _buildAppChip('IntelliJ\nIDEA', Icons.code, const Color(0xFFE91E63))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildAppChip('HubSpot', Icons.hub, const Color(0xFFFF7043))),
                const SizedBox(width: 10),
                Expanded(child: _buildAppChip('Replit', Icons.terminal, const Color(0xFFFF5722))),
              ],
            ),
            const SizedBox(height: 14),

            // Add connected apps button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0A66C2),
                  side: const BorderSide(color: Color(0xFF0A66C2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Add connected apps',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // PROJECTS SECTION
  // =============================================================
  Widget _buildProjectsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Projects (3)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),

          // Project 1: Acadex
          const Text('Acadex', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const Text('Feb 2026 – Present', style: TextStyle(fontSize: 13, color: Color(0xFF5E5E5E))),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                child: const Icon(Icons.crop_square, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Text('Associated with Quantaforze Corporation', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.4),
              children: [
                TextSpan(text: '"Acadex is a school-to-school or institute to institute student records and workflow network that...'),
                TextSpan(text: ' more', style: TextStyle(color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),

          // Project 2: Axiovital
          const Text('Axiovital', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                child: const Icon(Icons.crop_square, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Text('Associated with Quantaforze Corporation', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.4),
              children: [
                TextSpan(text: 'AxioVital is building the digital infrastructure layer for modern healthcare — connecting patients,...'),
                TextSpan(text: ' more', style: TextStyle(color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Other contributors
          const Text('Other contributors', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: AssetImage('assets/images/somraj_avatar.jpg'), fit: BoxFit.cover),
                ),
              ),
              Transform.translate(
                offset: const Offset(-8, 0),
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: AssetImage('assets/images/dharmik_avatar.jpg'), fit: BoxFit.cover),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(-16, 0),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF0F0F0),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('+3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5E5E5E))),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Show all link
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Show all',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF191919)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SKILLS SECTION
  // =============================================================
  Widget _buildSkillsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),

          // Skill 1
          const Text('Start-up Leadership', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                child: const Icon(Icons.crop_square, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('Founder at Quantaforze Corporation', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),

          // Skill 2
          const Text('Business Ownership', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                child: const Icon(Icons.crop_square, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('Founder at Quantaforze Corporation', style: TextStyle(fontSize: 13, color: Color(0xFF191919))),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // HELPERS
  // =============================================================



  Widget _buildAppChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF191919)),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BOTTOM SHEETS & POPUPS
  // =============================================================
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
              // Drag handle
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
                    SnackBar(
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Expanded(child: Text('Profile sent in message!', style: TextStyle(fontSize: 13))),
                        ],
                      ),
                      backgroundColor: const Color(0xFF262626),
                      behavior: SnackBarBehavior.floating,
                      width: 280,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.share_outlined,
                title: 'Share via...',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.share_outlined, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Expanded(child: Text('Share options loaded!', style: TextStyle(fontSize: 13))),
                        ],
                      ),
                      backgroundColor: const Color(0xFF262626),
                      behavior: SnackBarBehavior.floating,
                      width: 280,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
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
                icon: Icons.assignment_outlined,
                title: 'Activity',
                onTap: () {
                  Navigator.pop(context);
                  if (_activityKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _activityKey.currentContext!,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.bookmark_border,
                title: 'Saved items',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.bookmark_outline, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Expanded(child: Text('Saved items loaded!', style: TextStyle(fontSize: 13))),
                        ],
                      ),
                      backgroundColor: const Color(0xFF262626),
                      behavior: SnackBarBehavior.floating,
                      width: 280,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
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
                // Drag handle
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
                  value: 'https://acadyk.com/somraj',
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

