import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:acadyk/common/providers/profile_provider.dart';
import 'package:acadyk/common/services/storage_service.dart';
import 'package:acadyk/common/services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;
    final avatarUrl = profile?.profilePhotoUrl;

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
                      _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D8BF2),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                final text = _textController.text.trim();
                                if (text.isEmpty && _pickedImage == null) return;

                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  String? uploadedUrl;
                                  if (_pickedImage != null && profile != null) {
                                    uploadedUrl = await StorageService.uploadPostImage(
                                      profile.id,
                                      _pickedImage!,
                                    );
                                  }

                                  await PostService.createPost(
                                    text,
                                    postType: _pickedImage != null ? 'image' : 'text',
                                    imageUrl: uploadedUrl,
                                  );

                                  if (mounted) {
                                    Navigator.pop(context, true);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error creating post: $e')),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
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
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                ? NetworkImage(avatarUrl) as ImageProvider
                                : const AssetImage('assets/images/somraj_avatar.jpg'),
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
                      if (_pickedImage != null) ...[
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            Container(
                              height: 240,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_pickedImage!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _pickedImage = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final file = await StorageService.pickImage();
                                  if (file != null) {
                                    setState(() {
                                      _pickedImage = file;
                                    });
                                  }
                                },
                                child: const Icon(CupertinoIcons.photo, color: Color(0xFF0D8BF2), size: 22),
                              ),
                              const SizedBox(width: 20),
                              const Icon(Icons.gif_box_outlined, color: Color(0xFF0D8BF2), size: 22),
                              const SizedBox(width: 20),
                              const Icon(CupertinoIcons.list_bullet, color: Color(0xFF0D8BF2), size: 22),
                              const SizedBox(width: 20),
                              const Icon(CupertinoIcons.location, color: Color(0xFF0D8BF2), size: 22),
                              const SizedBox(width: 20),
                              const Icon(CupertinoIcons.flag, color: Color(0xFF0D8BF2), size: 20),
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
