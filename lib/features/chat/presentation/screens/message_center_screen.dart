import 'package:flutter/material.dart';
import 'package:acadyk/common/services/message_service.dart';
import 'package:acadyk/common/services/supabase_service.dart';
import 'direct_message_screen.dart';

class MessageCenterScreen extends StatefulWidget {
  const MessageCenterScreen({super.key});

  @override
  State<MessageCenterScreen> createState() => _MessageCenterScreenState();
}

class _MessageCenterScreenState extends State<MessageCenterScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await MessageService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const textColor = Color(0xFF111827);
    final currentUserId = SupabaseService.client.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_square, color: textColor, size: 26),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 16),
                    Icon(Icons.search, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Search messages...', style: TextStyle(color: Color(0xFF6B7280), fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Conversations List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _conversations.isEmpty
                      ? const Center(
                          child: Text(
                            'No messages yet.',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadConversations,
                          child: ListView.builder(
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final conv = _conversations[index];
                              final isGroup = conv['is_group'] ?? false;
                              
                              // Extract details
                              String displayName = 'Chat';
                              String displayAvatar = '';
                              String displayHandle = 'user';
                              String targetUserId = '';

                              if (isGroup) {
                                displayName = conv['group_name'] ?? 'Group Chat';
                                displayAvatar = conv['group_avatar_url'] ?? '';
                              } else {
                                final participants = conv['conversation_participants'] as List? ?? [];
                                final otherParticipants = participants
                                    .where((p) => p['user_id'] != currentUserId)
                                    .toList();

                                if (otherParticipants.isNotEmpty) {
                                  final profile = otherParticipants.first['profiles'] as Map<String, dynamic>? ?? {};
                                  displayName = profile['full_name'] ?? 'Acadyk User';
                                  displayAvatar = profile['profile_photo_url'] ?? '';
                                  displayHandle = profile['username'] ?? 'user';
                                  targetUserId = profile['id'] ?? '';
                                }
                              }

                              final lastMessage = conv['last_message_text'] ?? 'Tap to chat';

                              return _buildChatItem(
                                context: context,
                                conversationId: conv['id'].toString(),
                                targetUserId: targetUserId,
                                name: displayName,
                                subtitle: lastMessage,
                                hasBlueDot: false,
                                isMuted: false,
                                avatarUrl: displayAvatar,
                                handle: displayHandle,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem({
    required BuildContext context,
    required String conversationId,
    required String targetUserId,
    required String name,
    required String subtitle,
    required bool hasBlueDot,
    required bool isMuted,
    required String avatarUrl,
    required String handle,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DirectMessageScreen(
              name: name,
              handle: '@$handle',
              avatarColor: Colors.blue.shade100,
              avatarIcon: Icons.person,
              conversationId: conversationId,
              targetUserId: targetUserId,
            ),
          ),
        ).then((_) => _loadConversations());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: Colors.transparent,
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundImage: (avatarUrl.isNotEmpty && avatarUrl.startsWith('http'))
                  ? NetworkImage(avatarUrl) as ImageProvider
                  : const AssetImage('assets/images/somraj_avatar.jpg'),
            ),
            const SizedBox(width: 16),
            // Name and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
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
}
