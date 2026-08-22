import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:acadyk/common/services/follow_service.dart';
import 'package:acadyk/common/services/auth_service.dart';
import 'package:acadyk/common/services/profile_service.dart';
import 'package:acadyk/features/profile/presentation/services/profile_manager.dart';
import 'package:acadyk/features/profile/presentation/screens/profile_screen.dart';

class ConnectionsListScreen extends StatefulWidget {
  final String initialTab; // 'followers' or 'following'
  final String userName;
  final String userHandle;
  final String? userId;

  const ConnectionsListScreen({
    super.key,
    required this.initialTab,
    required this.userName,
    this.userHandle = '',
    this.userId,
  });

  @override
  State<ConnectionsListScreen> createState() => _ConnectionsListScreenState();
}

class _ConnectionsListScreenState extends State<ConnectionsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _followersList = [];
  List<Map<String, dynamic>> _followingList = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'followers' ? 1 : 0,
    );
    _loadConnections();
  }

  void _loadConnections() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String uid = widget.userId?.trim() ?? '';
    if (uid.isEmpty) {
      uid = AuthService.currentUser?.id.isNotEmpty == true
          ? AuthService.currentUser!.id
          : ProfileManager.id;
    }
    if (uid.isEmpty) {
      final myProfile = await ProfileService.getMyProfile();
      if (myProfile != null && myProfile['id'] != null) {
        uid = myProfile['id'].toString();
      }
    }

    if (uid.isEmpty) {
      uid = 'me';
    }

    try {
      final followers = await FollowService.getFollowers(uid);
      final following = await FollowService.getFollowing(uid);

      if (mounted) {
        setState(() {
          _followersList = followers;
          _followingList = following;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load connections: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF0F1419);
    const Color textSecondary = Color(0xFF536471);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userName.isNotEmpty ? widget.userName : 'Connections',
              style: const TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (widget.userHandle.isNotEmpty) ...[
              const SizedBox(height: 1),
              Text(
                widget.userHandle,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: textColor,
          unselectedLabelColor: textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          indicatorColor: const Color(0xFF1DA1F2),
          indicatorWeight: 3.0,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Following'),
            Tab(text: 'Followers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConnectionsList(_followingList, 'Not following anyone yet.'),
          _buildConnectionsList(_followersList, 'No followers yet.'),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(List<Map<String, dynamic>> list, String emptyMessage) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CupertinoActivityIndicator(radius: 14),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadConnections,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F1419),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline, size: 48, color: Colors.black26),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: const TextStyle(fontSize: 15, color: Colors.black45, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadConnections(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: list.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEFF3F4)),
        itemBuilder: (context, index) {
          final item = list[index];
          return _ConnectionRow(
            item: item,
            onFollowChanged: () {
              // Trigger reload on next cycle if needed
            },
          );
        },
      ),
    );
  }
}

class _ConnectionRow extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onFollowChanged;

  const _ConnectionRow({
    required this.item,
    this.onFollowChanged,
  });

  @override
  State<_ConnectionRow> createState() => _ConnectionRowState();
}

class _ConnectionRowState extends State<_ConnectionRow> {
  late bool _isFollowing;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.item['isFollowing'] == true || widget.item['is_following'] == true;
  }

  void _toggleFollow() async {
    final targetId = widget.item['id']?.toString() ?? widget.item['userId']?.toString();
    if (targetId == null || targetId.isEmpty || _isUpdating) return;

    final oldState = _isFollowing;
    setState(() {
      _isUpdating = true;
      _isFollowing = !_isFollowing;
    });

    try {
      final serverState = await FollowService.toggleFollow(targetId, oldState);
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
        _isFollowing = serverState;
      });
      widget.onFollowChanged?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
        _isFollowing = oldState;
      });
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          isOwnProfile: false,
          userData: widget.item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF0F1419);
    const Color textSecondary = Color(0xFF536471);

    final fullName = widget.item['fullName'] ?? widget.item['full_name'] ?? widget.item['name'] ?? 'Student';
    final username = widget.item['username'] != null ? '@${widget.item['username']}' : (widget.item['handle'] ?? '');
    final enrollment = widget.item['enrollmentNumber'] ?? widget.item['enrollment_number'];
    final branch = widget.item['branch'] ?? widget.item['department'] ?? widget.item['major'];
    final bio = widget.item['headline'] ?? widget.item['bio'] ?? '';
    final avatarUrl = widget.item['profilePhotoUrl'] ?? widget.item['profile_photo_url'] ?? widget.item['avatar'] ?? '';

    final initials = fullName.isNotEmpty
        ? fullName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join('').toUpperCase()
        : 'ST';

    return InkWell(
      onTap: _openProfile,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: User avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
              backgroundImage: avatarUrl.isNotEmpty && avatarUrl.startsWith('http')
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl.isEmpty || !avatarUrl.startsWith('http'))
                  ? Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Center: User Details (Name, Enrollment/Handle, Branch, Bio)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          fullName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (enrollment != null && enrollment.toString().isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            enrollment.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (username.isNotEmpty)
                    Text(
                      username,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  if (branch != null && branch.toString().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      branch.toString(),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right: Follow button (capsule style)
            GestureDetector(
              onTap: _toggleFollow,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _isFollowing ? const Color(0xFF272C30) : textColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
