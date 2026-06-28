import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PostDetailScreen extends StatelessWidget {
  final String authorName;
  final String authorHeadline;
  final String authorAvatar;
  final String timeAgo;
  final String postText;
  final String? connectionDegree;

  const PostDetailScreen({
    super.key,
    required this.authorName,
    required this.authorHeadline,
    required this.authorAvatar,
    required this.timeAgo,
    required this.postText,
    this.connectionDegree,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: Column(
              children: [
                // Top bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      const Icon(Icons.more_vert, color: Color(0xFF5E5E5E), size: 24),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),

                // Scrollable content: Post + Comments
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // ============================
                      // POST AUTHOR HEADER
                      // ============================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(authorAvatar),
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
                                      Flexible(
                                        child: Text(
                                          authorName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF191919),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      // Premium badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFC5A059),
                                          borderRadius: BorderRadius.circular(1.5),
                                        ),
                                        child: const Text(
                                          'in',
                                          style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (connectionDegree != null) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          '• $connectionDegree',
                                          style: const TextStyle(color: Color(0xFF5E5E5E), fontSize: 13),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    authorHeadline,
                                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF5E5E5E)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        timeAgo,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E)),
                                      ),
                                      const Text(' • ', style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 12)),
                                      const Icon(Icons.public, size: 12, color: Color(0xFF5E5E5E)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Follow button
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add, size: 18, color: Color(0xFF0A66C2)),
                              label: const Text(
                                'Follow',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A66C2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ============================
                      // FULL POST TEXT
                      // ============================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Color(0xFF191919),
                              height: 1.55,
                            ),
                            children: [
                              const TextSpan(
                                text: 'We raised \$4.3M, led by ',
                              ),
                              const TextSpan(
                                text: 'Pantera Capital',
                                style: TextStyle(
                                  color: Color(0xFF0A66C2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: '.\n\n'),
                              const TextSpan(
                                text: 'Soon, there will be more agents than people online. Those agents will book flights, hire contractors, enrich customer data, conduct research, and complete transactions without a human in the loop. But today, agents are stuck with whatever tools they were originally given. The moment they need something new, they fail, hallucinate, or hand the problem back to a human.\n\n',
                              ),
                              const TextSpan(
                                text: 'Orthogonal fixes this. Through a single integration, agents can discover the capabilities they need in the moment, orchestrate them, and pay for them instantly. An agent describes what it wants, and Orthogonal composes the result, calling the right services in the right order.\n\n',
                              ),
                              const TextSpan(
                                text: 'Our goal is simple: when an agent needs a capability it doesn\'t already have, Orthogonal will be the first place it goes.\n\n',
                              ),
                              const TextSpan(text: 'Thanks to '),
                              const TextSpan(
                                text: 'Pantera Capital',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ', '),
                              const TextSpan(
                                text: 'Y Combinator',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ', '),
                              const TextSpan(
                                text: 'Pioneer Fund',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ', '),
                              const TextSpan(
                                text: 'Decasonic',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ', '),
                              const TextSpan(
                                text: 'Blast Club',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ', '),
                              const TextSpan(
                                text: 'Outbound Capital',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ', Rice Capital ('),
                              const TextSpan(
                                text: 'Taro Fukuyama',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: '), Surreal by Premise ('),
                              const TextSpan(
                                text: 'Mercedes Bent',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' & '),
                              const TextSpan(
                                text: 'Vanessa Larco',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: '), '),
                              const TextSpan(
                                text: 'Batch Ventures',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text: ' (CTO Fund), and our strategic investors for backing us. We\'re building the default front door for the internet.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action/Engagement row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(CupertinoIcons.heart, size: 24, color: Colors.black87),
                                const SizedBox(width: 6),
                                const Text(
                                  '537',
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
                                  '51',
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
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),

                      // ============================
                      // COMMENTS SECTION
                      // ============================

                      // Most relevant dropdown
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            const Text(
                              'Most relevant',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF191919)),
                          ],
                        ),
                      ),

                      // Comment 1: Author comment (Christian Pickett)
                      _buildComment(
                        avatarAsset: 'assets/images/dharmik_avatar.jpg',
                        name: 'Christian Pickett',
                        isAuthor: true,
                        headline: 'Co-founder @ Orthogonal (YC W26)',
                        timeAgo: '1d',
                        connectionDegree: null,
                        commentWidget: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.45),
                            children: [
                              TextSpan(text: 'Read more:\n'),
                              TextSpan(
                                text: 'https://www.thestreet.com/crypto/newsroom/orthogonal-is-betting-the-agent-economy-needs-better-infrastructure',
                                style: TextStyle(
                                  color: Color(0xFF0A66C2),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        likeCount: '10',
                        hasReactions: true,
                      ),

                      // Comment 2: Aryan Gandhi
                      _buildComment(
                        avatarAsset: 'assets/images/somraj_avatar.jpg',
                        name: 'Aryan Gandhi',
                        isAuthor: false,
                        headline: 'Building the Future with AI 0->1 | Gen ...',
                        timeAgo: '15h',
                        connectionDegree: '1st',
                        commentWidget: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.45),
                            children: [
                              TextSpan(
                                text: 'Congratulations on the raise! The idea of agents dynamically discovering and orchestrating capabilities feels like a missing layer in today\'s agent stack. Excited to see where Orthogonal goes from here. ',
                              ),
                              TextSpan(
                                text: 'Christian Pickett',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' 👏'),
                            ],
                          ),
                        ),
                        likeCount: null,
                        hasReactions: false,
                      ),

                      // Comment 3: Ryan Widgeon
                      _buildComment(
                        avatarAsset: 'assets/images/alina_avatar.jpg',
                        name: 'Ryan Widgeon',
                        isAuthor: false,
                        headline: 'Founder | AI/ML | AI Agents |GTM| Forb...',
                        timeAgo: '1d',
                        connectionDegree: '3rd+',
                        commentWidget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Congrats! This is a reallyyy interesting layer to build.\n\nMost agents today are only as useful as the tools they were pre-wired with. The moment the task requires a new capability, they either hallucinate a workaround, fail silently, or punt back to a human.\n\nDynamic capability discovery...',
                              style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.45),
                            ),
                            const Text(
                              ' more',
                              style: TextStyle(fontSize: 14, color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        likeCount: '9',
                        hasReactions: true,
                        replyCount: '1',
                        replies: [
                          // Reply to Ryan: Dr. Xi Zeng
                          _buildReply(
                            avatarAsset: 'assets/images/dharmik_avatar.jpg',
                            name: 'Dr. Xi Zeng',
                            headline: 'Founder and CEO of Chance A...',
                            timeAgo: '18h',
                            connectionDegree: '3rd+',
                            commentWidget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.45),
                                    children: [
                                      TextSpan(
                                        text: 'Ryan Widgeon',
                                        style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: ' The safety point is where this gets interesting. Tool discovery is easy to describe as routing, but the agent also needs a reason to stop....',
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  ' more',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF5E5E5E), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            likeCount: '1',
                            isLastReply: true,
                          ),
                        ],
                      ),

                      // Comment 4: Sudan Bey
                      _buildComment(
                        avatarAsset: 'assets/images/somraj_avatar.jpg',
                        name: 'Sudan Bey',
                        isAuthor: false,
                        headline: 'GTM Sales Leader | Digital Engineering ...',
                        timeAgo: '1d',
                        connectionDegree: '3rd+',
                        commentWidget: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, color: Color(0xFF191919), height: 1.45),
                            children: [
                              TextSpan(text: 'This is a smart direction '),
                              TextSpan(
                                text: 'Orthogonal (YC W26)',
                                style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: '. Customers / organizations are looking for connected action across these AI tools and workflows they already use. This integration layer is just as strategic and important as the intelligence layer.',
                              ),
                            ],
                          ),
                        ),
                        likeCount: null,
                        hasReactions: false,
                      ),

                      const SizedBox(height: 80), // Space for bottom bar
                    ],
                  ),
                ),

                // ============================
                // FIXED BOTTOM COMMENT INPUT
                // ============================
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // User avatar
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/somraj_avatar.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF5E5E5E)),
                      const SizedBox(width: 8),
                      // Comment input
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F2EF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Add a comment...',
                            style: TextStyle(fontSize: 14, color: Color(0xFF5E5E5E)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // @ mention button
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: const Center(
                          child: Text(
                            '@',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5E5E5E)),
                          ),
                        ),
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

  // ============================
  // ACTION BUTTON HELPER
  // ============================
  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5E5E5E)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF5E5E5E))),
      ],
    );
  }

  // ============================
  // COMMENT BUILDER
  // ============================
  Widget _buildComment({
    required String avatarAsset,
    required String name,
    required bool isAuthor,
    required String headline,
    required String timeAgo,
    String? connectionDegree,
    required Widget commentWidget,
    String? likeCount,
    bool hasReactions = false,
    String? replyCount,
    List<Widget>? replies,
  }) {
    final bool hasReplies = replies != null && replies.isNotEmpty;

    Widget rightContent = Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5A059),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                          child: const Text('in', style: TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.bold)),
                        ),
                        if (connectionDegree != null) ...[
                          const SizedBox(width: 4),
                          Text('• $connectionDegree', style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E))),
                        ],
                        if (isAuthor) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B7A2D),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text('Author', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      headline,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF5E5E5E)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(timeAgo, style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E))),
              const SizedBox(width: 4),
              const Icon(Icons.more_vert, size: 18, color: Color(0xFF5E5E5E)),
            ],
          ),
          const SizedBox(height: 8),

          // Comment text
          commentWidget,

          const SizedBox(height: 10),

          // Like / Reply row
          Row(
            children: [
              const Text('Like', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5E5E5E))),
              if (hasReactions && likeCount != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: Color(0xFF0A66C2), shape: BoxShape.circle),
                  child: const Icon(Icons.thumb_up, size: 9, color: Colors.white),
                ),
                Container(
                  width: 16, height: 16,
                  transform: Matrix4.translationValues(-4, 0, 0),
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                  child: const Icon(Icons.favorite, size: 9, color: Colors.white),
                ),
                Text(likeCount, style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E))),
              ] else if (likeCount != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: Color(0xFF0A66C2), shape: BoxShape.circle),
                  child: const Icon(Icons.thumb_up, size: 9, color: Colors.white),
                ),
                const SizedBox(width: 2),
                Text(likeCount, style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E))),
              ],
              const SizedBox(width: 16),
              const Text('Reply', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5E5E5E))),
              if (replyCount != null) ...[
                const SizedBox(width: 8),
                Text(replyCount, style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E))),
              ],
            ],
          ),
        ],
      ),
    );

    Widget mainRow = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 46,
            child: CustomPaint(
              painter: _MainCommentThreadPainter(hasReplies: hasReplies),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(avatarAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: rightContent),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, hasReplies ? 0 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainRow,
          if (hasReplies) ...replies!,
        ],
      ),
    );
  }

  // ============================
  // REPLY (INDENTED COMMENT)
  // ============================
  Widget _buildReply({
    required String avatarAsset,
    required String name,
    required String headline,
    required String timeAgo,
    String? connectionDegree,
    required Widget commentWidget,
    String? likeCount,
    bool isLastReply = true,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 46, // width of parent avatar (36) + gap (10)
            child: CustomPaint(
              painter: _ReplyThreadPainter(isLast: isLastReply),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: isLastReply ? 8 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(avatarAsset),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF191919)), overflow: TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                          decoration: BoxDecoration(color: const Color(0xFFC5A059), borderRadius: BorderRadius.circular(1.5)),
                                          child: const Text('in', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                                        ),
                                        if (connectionDegree != null) ...[
                                          const SizedBox(width: 4),
                                          Text('• $connectionDegree', style: const TextStyle(fontSize: 11, color: Color(0xFF5E5E5E))),
                                        ],
                                      ],
                                    ),
                                    Text(headline, style: const TextStyle(fontSize: 11, color: Color(0xFF5E5E5E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Text(timeAgo, style: const TextStyle(fontSize: 11, color: Color(0xFF5E5E5E))),
                              const SizedBox(width: 4),
                              const Icon(Icons.more_vert, size: 16, color: Color(0xFF5E5E5E)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          commentWidget,
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Like', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5E5E5E))),
                              if (likeCount != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 14, height: 14,
                                  decoration: const BoxDecoration(color: Color(0xFF0A66C2), shape: BoxShape.circle),
                                  child: const Icon(Icons.thumb_up, size: 8, color: Colors.white),
                                ),
                                const SizedBox(width: 2),
                                Text(likeCount, style: const TextStyle(fontSize: 11, color: Color(0xFF5E5E5E))),
                              ],
                              const SizedBox(width: 14),
                              const Text('Reply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5E5E5E))),
                            ],
                          ),
                        ],
                      ),
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
}

class _MainCommentThreadPainter extends CustomPainter {
  final bool hasReplies;
  _MainCommentThreadPainter({required this.hasReplies});

  @override
  void paint(Canvas canvas, Size size) {
    if (!hasReplies) return;
    
    final paint = Paint()
      ..color = const Color(0xFFC7C7C7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = 18.0; 
    final startY = 36.0;

    final path = Path();
    path.moveTo(centerX, startY);
    path.lineTo(centerX, size.height);
    
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReplyThreadPainter extends CustomPainter {
  final bool isLast;
  _ReplyThreadPainter({required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC7C7C7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = 18.0;
    final centerY = 23.0; 

    final elbowPath = Path();
    elbowPath.moveTo(centerX, 0);
    elbowPath.lineTo(centerX, centerY - 12);
    elbowPath.arcToPoint(
      Offset(centerX + 12, centerY),
      radius: const Radius.circular(12),
      clockwise: false,
    );
    elbowPath.lineTo(size.width, centerY);

    canvas.drawPath(elbowPath, paint);

    if (!isLast) {
      final linePath = Path();
      linePath.moveTo(centerX, centerY - 12);
      linePath.lineTo(centerX, size.height);
      canvas.drawPath(linePath, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
