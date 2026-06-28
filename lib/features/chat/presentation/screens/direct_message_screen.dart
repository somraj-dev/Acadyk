import 'package:flutter/material.dart';

class DirectMessageScreen extends StatelessWidget {
  final String name;
  final String handle;
  final Color avatarColor;
  final IconData avatarIcon;
  final Color iconColor;

  const DirectMessageScreen({
    super.key,
    required this.name,
    required this.handle,
    required this.avatarColor,
    required this.avatarIcon,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF000000);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: avatarColor,
              child: Icon(avatarIcon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  handle,
                  style: const TextStyle(
                    color: Color(0xFFA0A0A0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.phone_outlined, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_outlined, color: Colors.white, size: 28), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                _buildSentMessage('Ek ye madarchod corrupt aadami h'),
                const SizedBox(height: 16),
                _buildReceivedMessage('Sabbi corrupt h bhai', showAvatar: true),
                const SizedBox(height: 16),
                _buildSentMessage('Me nhi hu'),
                const SizedBox(height: 2),
                _buildSentMessage('Me chutiya hu corrupt nhi'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: const Text('💔💔', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 24),
                _buildReceivedMessage('Me bhi', showAvatar: false),
                const SizedBox(height: 2),
                _buildReceivedMessage(
                  'Khair corruption is only bad when I am not involved so yeah',
                  showAvatar: true,
                  bottomHint: 'Double-tap to ❤️',
                ),
                const SizedBox(height: 24),
                _buildReplyMessage(
                  replyText: 'Khair corruption is only bad when I am not involved so yeah',
                  sentText: 'Sahi kaha mera bhi yahi hisab h',
                  isGradient: true,
                ),
                const SizedBox(height: 2),
                _buildSentMessage('Hamesa sw'),
                const SizedBox(height: 16),
                _buildReceivedMessage(
                  'Same same',
                  showAvatar: true,
                  hasHeartReaction: true,
                ),
              ],
            ),
          ),
          _buildBottomInputBar(),
        ],
      ),
    );
  }

  Widget _buildSentMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFD300C5), // Vibrant pink/magenta
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(String text, {required bool showAvatar, String? bottomHint, bool hasHeartReaction = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: avatarColor,
                child: Icon(avatarIcon, color: iconColor, size: 18),
              ),
            )
          else
            const SizedBox(width: 36), // Placeholder for missing avatar
            
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 260),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF262626), // Dark grey received bubble
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  if (hasHeartReaction)
                    Positioned(
                      bottom: -10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262626),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Text('❤️', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                ],
              ),
              if (bottomHint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                  child: Text(
                    bottomHint,
                    style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyMessage({required String replyText, required String sentText, bool isGradient = false}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 4.0, right: 8.0),
            child: Text('You replied', style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 12)),
          ),
          // Quoted Bubble
          Container(
            constraints: const BoxConstraints(maxWidth: 240),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A), // Darker grey for quote
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    replyText,
                    style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 3, height: 30, color: const Color(0xFF333333)), // Vertical grey line
              ],
            ),
          ),
          // Reply Sent Bubble
          Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isGradient ? const LinearGradient(
                colors: [Color(0xFF5A45FF), Color(0xFF9030FF)], // Blue to purple
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ) : null,
              color: isGradient ? null : const Color(0xFFD300C5),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              sentText,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      color: const Color(0xFF000000),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SafeArea(
        child: Row(
          children: [
            // Camera Button
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6), // Blue
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 8),
            // Input Field Pill
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerLeft,
                child: const Text('Message...', style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
            // Right Icons
            const Icon(Icons.mic_none_outlined, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            const Icon(Icons.image_outlined, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            const Icon(Icons.sticky_note_2_outlined, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            const Icon(Icons.add_circle_outline, color: Colors.white, size: 26),
          ],
        ),
      ),
    );
  }
}
