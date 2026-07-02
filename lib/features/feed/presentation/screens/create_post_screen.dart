import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
                // 1. Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black87, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D8BF2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // Return the post text if not empty
                          if (_textController.text.trim().isNotEmpty) {
                            Navigator.pop(context, _textController.text);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFECECE8)),

                // 2. Text Input Content Area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Avatar
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/images/somraj_avatar.jpg'),
                          ),
                          const SizedBox(width: 12),
                          // Text Input
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              maxLines: null,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: "What's happening?",
                                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16.0),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 16.0, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Bottom controls
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1, color: Color(0xFFECECE8)),
                    
                    // Reply permission option
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: const [
                          Icon(CupertinoIcons.globe, color: Color(0xFF0D8BF2), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Everyone can reply',
                            style: TextStyle(
                              color: Color(0xFF0D8BF2),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFECECE8)),

                    // Bottom icons row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(CupertinoIcons.photo, color: Color(0xFF0D8BF2), size: 22),
                              SizedBox(width: 20),
                              Icon(Icons.gif_box_outlined, color: Color(0xFF0D8BF2), size: 22),
                              SizedBox(width: 20),
                              Icon(CupertinoIcons.list_bullet, color: Color(0xFF0D8BF2), size: 22),
                              SizedBox(width: 20),
                              Icon(CupertinoIcons.location, color: Color(0xFF0D8BF2), size: 22),
                              SizedBox(width: 20),
                              Icon(CupertinoIcons.flag, color: Color(0xFF0D8BF2), size: 20),
                            ],
                          ),
                          Row(
                            children: const [
                              Icon(CupertinoIcons.circle, color: Color(0xFFE5E7EB), size: 22),
                              SizedBox(width: 16),
                              Icon(CupertinoIcons.add_circled, color: Color(0xFF0D8BF2), size: 22),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
