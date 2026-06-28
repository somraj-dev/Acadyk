import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();

  void _showAttachmentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 40, left: 24, right: 24),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildAttachmentOption(Icons.image, 'Media'),
              _buildAttachmentOption(Icons.calendar_month, 'Event'),
              _buildAttachmentOption(Icons.workspace_premium, 'Celebrate'),
              _buildAttachmentOption(Icons.work, 'Job'),
              _buildAttachmentOption(Icons.bar_chart, 'Poll'),
              _buildAttachmentOption(Icons.description, 'Document'),
              _buildAttachmentOption(Icons.badge, 'Services'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F2EF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF5E5E5E), size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF424242),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View all',
                          style: TextStyle(
                            color: Color(0xFF191919),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 18, color: Color(0xFF191919)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Date*', style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF5E5E5E)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('June 28, 2026', style: TextStyle(fontSize: 16, color: Color(0xFF191919))),
                    Icon(Icons.calendar_today, size: 20, color: Color(0xFF191919)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Time*', style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF5E5E5E)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('12:20 AM', style: TextStyle(fontSize: 16, color: Color(0xFF191919))),
                    Icon(Icons.schedule, size: 20, color: Color(0xFF191919)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi, based on your location',
                style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF5E5E5E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/somraj_avatar.jpg'),
            ),
            const SizedBox(width: 8),
            const Text(
              'Anyone',
              style: TextStyle(color: Color(0xFF5E5E5E), fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF5E5E5E)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule, color: Color(0xFF5E5E5E)),
            onPressed: _showScheduleSheet,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEBEBEB),
                foregroundColor: const Color(0xFF191919),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Post',
                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _textController,
                autofocus: true,
                maxLines: null,
                style: const TextStyle(fontSize: 18, color: Color(0xFF191919)),
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts...',
                  hintStyle: TextStyle(color: Color(0xFF5E5E5E)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // Bottom toolbar pinned to keyboard
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.image_outlined, color: Color(0xFF5E5E5E), size: 28),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF5E5E5E), size: 28),
                  onPressed: _showAttachmentsSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
