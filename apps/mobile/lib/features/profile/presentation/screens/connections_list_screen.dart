import 'package:flutter/material.dart';

class ConnectionsListScreen extends StatefulWidget {
  final String initialTab; // 'followers' or 'following'
  final String userName;
  final String userHandle;

  const ConnectionsListScreen({
    super.key,
    required this.initialTab,
    required this.userName,
    required this.userHandle,
  });

  @override
  State<ConnectionsListScreen> createState() => _ConnectionsListScreenState();
}

class _ConnectionsListScreenState extends State<ConnectionsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> followersList = [
    {
      'name': 'Bhawana',
      'handle': '@cricbhawana',
      'avatar': 'assets/images/somraj_avatar.jpg', // Fallback avatar asset
      'bio': 'Cricket analyst | Context over chaos | Match reactions, game plans & strategy | Video \ud83c\udfa5 | Writing \u270d\ufe0f Collabs: DM \u2709\ufe0f',
      'verified': true,
      'isFollowing': false,
    },
    {
      'name': 'Heisenberg \u2622\ufe0f',
      'handle': '@internetumpire',
      'avatar': 'assets/images/user_avatar.jpg',
      'bio': '@ChennaiIPL aficionado. Part time bleeding blue, full time spreading #Yellove. #\u0ba4\u0baf\u0bbf\u0bb4\u0bcd',
      'verified': true,
      'isFollowing': false,
    },
    {
      'name': 'Shivani',
      'handle': '@meme_ki_diwani',
      'avatar': 'assets/images/alina_avatar.jpg',
      'bio': '29 June \ud83c\uddee\ud83c\uddf3 \ud83c\udfc6. 2 Nov \ud83c\udfc6 \ud83c\uddee\ud83c\uddf3. Here to post CRICKET & Stuffs | telegram.me/cricketkidiwan...',
      'verified': true,
      'isFollowing': false,
    },
    {
      'name': 'RATNISH',
      'handle': '@LoyalSachinFan',
      'avatar': 'assets/images/dharmik_avatar.jpg',
      'bio': '.',
      'verified': true,
      'isFollowing': false,
    },
    {
      'name': 'arfan',
      'handle': '@Im__Arfan',
      'avatar': 'assets/images/user_avatar.jpg',
      'bio': 'sirf asli fans ko pata hai t20 leagues ka maza. For Commercial & Collaboration, DM @FarziCricketer',
      'verified': true,
      'isFollowing': false,
    },
  ];

  final List<Map<String, dynamic>> followingList = [
    {
      'name': 'Somraj Lodhi',
      'handle': '@SomrajLodhi',
      'avatar': 'assets/images/somraj_avatar.jpg',
      'bio': 'Founder | Thinker | Quant Engineer | Acadyk Developer',
      'verified': true,
      'isFollowing': true,
    },
    {
      'name': 'Somraj Dev',
      'handle': '@SomrajDev',
      'avatar': 'assets/images/user_avatar.jpg',
      'bio': 'Entrepreneur | Founder @ Nexure Agents & Black Torque Media',
      'verified': true,
      'isFollowing': true,
    },
    {
      'name': 'Somraj Ghosh',
      'handle': '@SomrajGhosh',
      'avatar': 'assets/images/somraj_avatar.jpg',
      'bio': 'Founder & CEO @ Layrda | Building the future of agentic web',
      'verified': true,
      'isFollowing': true,
    },
    {
      'name': 'Alina Sprongole',
      'handle': '@AlinaSprongole',
      'avatar': 'assets/images/alina_avatar.jpg',
      'bio': 'Software Engineer @ Google | Tech Lead',
      'verified': true,
      'isFollowing': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'followers' ? 1 : 0,
    );
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
              widget.userName,
              style: const TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              widget.userHandle,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
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
          _buildConnectionsList(followingList),
          _buildConnectionsList(followersList),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(List<Map<String, dynamic>> list) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEFF3F4)),
      itemBuilder: (context, index) {
        final item = list[index];
        return _ConnectionRow(item: item);
      },
    );
  }
}

class _ConnectionRow extends StatefulWidget {
  final Map<String, dynamic> item;
  const _ConnectionRow({required this.item});

  @override
  State<_ConnectionRow> createState() => _ConnectionRowState();
}

class _ConnectionRowState extends State<_ConnectionRow> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.item['isFollowing'] == true;
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF0F1419);
    const Color textSecondary = Color(0xFF536471);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: User avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(widget.item['avatar']),
          ),
          const SizedBox(width: 12),

          // Center: User Details (Name, Username, Bio)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.item['name'],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (widget.item['verified'] == true) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 16, color: Color(0xFF1DA1F2)),
                    ],
                  ],
                ),
                Text(
                  widget.item['handle'],
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.item['bio'],
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right: Follow button (capsule style)
          GestureDetector(
            onTap: () {
              setState(() {
                _isFollowing = !_isFollowing;
              });
            },
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
    );
  }
}
