import 'package:flutter/material.dart';
import 'package:acadyk/common/services/message_service.dart';
import 'package:acadyk/common/services/supabase_service.dart';

class DirectMessageScreen extends StatefulWidget {
  final String name;
  final String handle;
  final Color avatarColor;
  final IconData avatarIcon;
  final Color iconColor;
  final String? conversationId;
  final String? targetUserId;

  const DirectMessageScreen({
    super.key,
    required this.name,
    required this.handle,
    required this.avatarColor,
    required this.avatarIcon,
    this.iconColor = Colors.white,
    this.conversationId,
    this.targetUserId,
  });

  @override
  State<DirectMessageScreen> createState() => _DirectMessageScreenState();
}

class _DirectMessageScreenState extends State<DirectMessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  String? _activeConversationId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (_activeConversationId == null && widget.targetUserId != null) {
      setState(() {
        _isLoading = true;
      });
      final convId = await MessageService.createConversation(widget.targetUserId!);
      if (mounted) {
        setState(() {
          _activeConversationId = convId;
          _isLoading = false;
        });
      }
    }
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_activeConversationId == null) return;
    try {
      final data = await MessageService.getMessages(_activeConversationId!);
      if (mounted) {
        setState(() {
          _messages = data.isNotEmpty ? data : _getMockMessages();
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages = _getMockMessages();
        });
        _scrollToBottom();
      }
    }
  }

  List<Map<String, dynamic>> _getMockMessages() {
    final currentUserId = SupabaseService.client.auth.currentUser?.id ?? 'me';
    return [
      {
        'id': 'msg_1',
        'sender_id': widget.targetUserId ?? 'other',
        'message_text': 'Welcome to ${widget.name}! Feel free to connect or ask any questions.',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'profiles': {'full_name': widget.name},
      },
      {
        'id': 'msg_2',
        'sender_id': currentUserId,
        'message_text': 'Hello ${widget.name}! Thanks for reaching out.',
        'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'profiles': {'full_name': 'You'},
      },
    ];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _activeConversationId == null) return;
    _controller.clear();

    final currentUserId = SupabaseService.client.auth.currentUser?.id ?? 'me';
    final newMessage = {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'sender_id': currentUserId,
      'message_text': text,
      'created_at': DateTime.now().toIso8601String(),
      'profiles': {'full_name': 'You'},
    };

    setState(() {
      _messages.add(newMessage);
    });
    _scrollToBottom();

    try {
      await MessageService.sendMessage(_activeConversationId!, text);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const textPrimary = Color(0xFF111827);
    const textSecondary = Color(0xFF6B7280);
    final currentUserId = SupabaseService.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: widget.avatarColor,
              child: Icon(widget.avatarIcon, color: widget.iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.handle,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: textPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.phone_outlined, color: textPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_outlined, color: textPrimary, size: 28), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['sender_id'] == currentUserId;
                      return _buildMessageRow(msg['content'] ?? '', isMe);
                    },
                  ),
                ),
                _buildBottomInputBar(),
              ],
            ),
    );
  }

  Widget _buildMessageRow(String text, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF3B82F6) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Message...',
                    hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF3B82F6)),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
