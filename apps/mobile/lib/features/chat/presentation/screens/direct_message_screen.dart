import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:acadyk/common/services/message_service.dart';
import 'package:acadyk/common/services/auth_service.dart';
import 'package:acadyk/shared/widgets/skeleton/skeleton.dart';
import '../widgets/file_message_bubble.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, dynamic>> _messages = [];
  String? _activeConversationId;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _uploadingFileName;

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    _messages = _getMockMessages();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (_activeConversationId == null && widget.targetUserId != null) {
      if (_messages.isEmpty) {
        setState(() {
          _isLoading = true;
        });
      }
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
    final currentUserId = AuthService.currentUser?.id ?? 'me';
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

    final currentUserId = AuthService.currentUser?.id ?? 'me';
    final newMessage = {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'sender_id': currentUserId,
      'message_text': text,
      'messageType': 'TEXT',
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

  /// WhatsApp-style: Show attachment menu bottom sheet
  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF3B82F6)),
                ),
                title: const Text('Document', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('PDF, DOC, XLS, PPT, TXT', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument();
                },
              ),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_rounded, color: Color(0xFF8B5CF6)),
                ),
                title: const Text('Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('From gallery', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto();
                },
              ),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF10B981)),
                ),
                title: const Text('Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Take a photo', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                onTap: () {
                  Navigator.pop(context);
                  _openCamera();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick a document file (PDF, DOC, etc.)
  Future<void> _pickDocument() async {
    if (_activeConversationId == null) return;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        await _uploadAndSendFile(
          fileName: pickedFile.name,
          filePath: pickedFile.path,
          bytes: pickedFile.bytes,
        );
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
    }
  }

  /// Pick a photo from gallery
  Future<void> _pickPhoto() async {
    if (_activeConversationId == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadAndSendFile(
          fileName: image.name,
          filePath: image.path,
          bytes: kIsWeb ? await image.readAsBytes() : null,
        );
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
  }

  /// Open camera and take photo
  Future<void> _openCamera() async {
    if (_activeConversationId == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadAndSendFile(
          fileName: image.name,
          filePath: image.path,
          bytes: kIsWeb ? await image.readAsBytes() : null,
        );
      }
    } catch (e) {
      debugPrint('Error opening camera: $e');
    }
  }

  /// Upload file and send as a message (WhatsApp-style pipeline)
  Future<void> _uploadAndSendFile({
    required String fileName,
    String? filePath,
    dynamic bytes,
  }) async {
    if (_activeConversationId == null) return;

    setState(() {
      _isUploading = true;
      _uploadingFileName = fileName;
    });

    try {
      final result = await MessageService.sendFileMessage(
        _activeConversationId!,
        file: (filePath != null && !kIsWeb) ? File(filePath) : null,
        bytes: bytes,
        fileName: fileName,
      );

      if (result != null && mounted) {
        // Add the returned message to the list
        setState(() {
          _messages.add(result);
          _isUploading = false;
          _uploadingFileName = null;
        });
        _scrollToBottom();
      } else if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadingFileName = null;
        });
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadingFileName = null;
        });
      }
    }
  }

  /// Check if a message is a file message (WhatsApp-style)
  bool _isFileMessage(Map<String, dynamic> msg) {
    final messageType = msg['messageType'] ?? msg['message_type'] ?? 'TEXT';
    return messageType == 'FILE' ||
        messageType == 'IMAGE' ||
        messageType == 'DOCUMENT' ||
        messageType == 'VIDEO';
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const textPrimary = Color(0xFF111827);
    const textSecondary = Color(0xFF6B7280);
    final currentUserId = AuthService.currentUser?.id;

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
          ? const ChatSkeleton()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _messages.length + (_isUploading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show upload progress at the bottom
                      if (_isUploading && index == _messages.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FileUploadProgressBubble(
                              fileName: _uploadingFileName ?? 'Uploading...',
                              progress: 0,
                            ),
                          ),
                        );
                      }

                      final msg = _messages[index];
                      final isMe = msg['sender_id'] == currentUserId;

                      // Render file messages with WhatsApp-style bubble
                      if (_isFileMessage(msg)) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: FileMessageBubble(
                              fileName: msg['fileName'] ?? msg['file_name'] ?? 'File',
                              fileSizeBytes: (msg['fileSizeBytes'] ?? msg['file_size_bytes'] ?? 0) as int,
                              mimeType: msg['mimeType'] ?? msg['mime_type'] ?? 'application/octet-stream',
                              fileUrl: msg['mediaUrl'] ?? msg['media_url'] ?? '',
                              thumbnailUrl: msg['thumbnailUrl'] ?? msg['thumbnail_url'],
                              isMe: isMe,
                            ),
                          ),
                        );
                      }

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
            // WhatsApp-style: Attachment button (replaces old camera-only button)
            GestureDetector(
              onTap: _showAttachmentMenu,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.attach_file_rounded, color: Colors.white, size: 22),
              ),
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

