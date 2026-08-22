import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:acadyk/common/services/storage_service.dart';
import 'package:acadyk/common/services/post_service.dart';
import 'package:acadyk/features/profile/presentation/services/profile_manager.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();

  // Media
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  String? _altText;

  // Poll
  bool _isPollActive = false;
  final List<TextEditingController> _pollControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  String _pollLength = '1 day';

  // Milestone / Flag
  String? _selectedMilestone;

  // Location & Tagging
  String? _selectedLocation;
  final List<String> _taggedPeople = [];

  // Visibility / Who can reply
  String _replyVisibility = 'Everyone can reply';
  IconData _replyVisibilityIcon = CupertinoIcons.globe;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    for (final c in _pollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? const Color(0xFF000000) : Colors.white;
  Color get _textColor => _isDark ? Colors.white : const Color(0xFF0F1419);
  Color get _subTextColor => _isDark ? const Color(0xFF71767B) : const Color(0xFF536471);
  Color get _borderColor => _isDark ? const Color(0xFF2F3336) : const Color(0xFFEFF3F4);

  bool get _canPost {
    final text = _textController.text.trim();
    if (_isPollActive) {
      final choice1 = _pollControllers[0].text.trim();
      final choice2 = _pollControllers[1].text.trim();
      return text.isNotEmpty && choice1.isNotEmpty && choice2.isNotEmpty;
    }
    return text.isNotEmpty || _pickedImageBytes != null || _selectedMilestone != null;
  }

  String get _currentHintText {
    if (_isPollActive) return 'Ask a question...';
    if (_pickedImageBytes != null) return 'Add a comment...';
    return "What's happening?";
  }

  Future<void> _pickImage() async {
    final XFile? file = await StorageService.pickImageXFile();
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageName = file.name;
        _isPollActive = false;
      });
    }
  }

  void _togglePoll() {
    setState(() {
      _isPollActive = !_isPollActive;
      if (_isPollActive) {
        _pickedImageBytes = null;
        _pickedImageName = null;
      }
    });
  }

  void _openMilestonePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _buildMilestonePickerSheet(ctx),
    );
  }

  void _openLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _buildLocationPickerSheet(ctx),
    );
  }

  void _openTagPeopleDialog() {
    final TextEditingController tagCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tag People', style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tagCtrl,
              autofocus: true,
              style: TextStyle(color: _textColor),
              decoration: InputDecoration(
                hintText: 'Enter name or @handle...',
                hintStyle: TextStyle(color: _subTextColor),
                filled: true,
                fillColor: _isDark ? const Color(0xFF16181C) : const Color(0xFFF7F9F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: _subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9BF0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              final name = tagCtrl.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _taggedPeople.add(name.startsWith('@') ? name : '@$name');
                });
              }
              Navigator.pop(dialogCtx);
            },
            child: const Text('Add Tag', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openVisibilityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _buildVisibilityPickerSheet(ctx),
    );
  }

  void _onPostSubmit() {
    if (!_canPost) return;

    final text = _textController.text.trim();

    // Build poll structure if poll mode active
    Map<String, dynamic>? pollData;
    if (_isPollActive) {
      final options = _pollControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .map((t) => {'text': t, 'votes': 0})
          .toList();
      if (options.length >= 2) {
        pollData = {
          'question': text,
          'options': options,
          'totalVotes': 0,
          'duration': _pollLength,
          'userVotedIndex': -1,
        };
      }
    }

    // Trigger async posting in PostService (shows live progress bar in feed)
    PostService.startPostingAsync(
      content: text,
      postType: _isPollActive
          ? 'poll'
          : (_pickedImageBytes != null ? 'image' : 'text'),
      imageBytes: _pickedImageBytes,
      imageName: _pickedImageName,
      poll: pollData,
      milestone: _selectedMilestone,
      location: _selectedLocation,
      taggedPeople: _taggedPeople.isNotEmpty ? _taggedPeople : null,
      replyVisibility: _replyVisibility,
    );

    // Pop screen immediately to return to the feed and enjoy the smooth posting animation!
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ProfileManager.avatarUrl;
    final name = ProfileManager.name.isNotEmpty ? ProfileManager.name : 'Acadyk Member';
    final initials = name.substring(0, min(2, name.length)).toUpperCase();

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540),
            color: _bgColor,
            child: Column(
              children: [
                // 1. Top Bar: Cancel [X] on Left, Blue [Post] on Right
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: _textColor, size: 24),
                        onPressed: () {
                          if (_textController.text.isNotEmpty || _pickedImageBytes != null) {
                            _showDiscardDialog();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canPost ? const Color(0xFF1D9BF0) : const Color(0xFF1D9BF0).withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: _canPost ? _onPostSubmit : null,
                        child: const Text(
                          'Post',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: _borderColor),

                // 2. Main Compose Area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    children: [
                      // Milestone badge if selected
                      if (_selectedMilestone != null) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D9BF0).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF1D9BF0).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedMilestone!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D9BF0),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => setState(() => _selectedMilestone = null),
                                child: const Icon(Icons.close, size: 16, color: Color(0xFF1D9BF0)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Author Avatar + Multi-line Input
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserAvatar(avatarUrl, initials),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _textController,
                                  maxLines: null,
                                  autofocus: true,
                                  style: TextStyle(fontSize: 16.5, color: _textColor, height: 1.4),
                                  decoration: InputDecoration(
                                    hintText: _currentHintText,
                                    hintStyle: TextStyle(color: _subTextColor, fontSize: 16.5),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                                  ),
                                ),

                                // Attached image preview (Image 5)
                                if (_pickedImageBytes != null) ...[
                                  const SizedBox(height: 14),
                                  _buildMediaPreview(
                                    imageWidget: Image.memory(_pickedImageBytes!, fit: BoxFit.cover),
                                    onRemove: () => setState(() {
                                      _pickedImageBytes = null;
                                      _pickedImageName = null;
                                    }),
                                  ),
                                ],

                                // Poll Composer Widget (Image 4)
                                if (_isPollActive) ...[
                                  const SizedBox(height: 14),
                                  _buildPollComposer(),
                                ],

                                // Location & Tagged people chips
                                if (_selectedLocation != null || _taggedPeople.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      if (_selectedLocation != null)
                                        Chip(
                                          avatar: const Icon(CupertinoIcons.location_solid, size: 14, color: Color(0xFF1D9BF0)),
                                          label: Text(_selectedLocation!, style: const TextStyle(fontSize: 12, color: Color(0xFF1D9BF0))),
                                          backgroundColor: const Color(0xFF1D9BF0).withValues(alpha: 0.1),
                                          deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF1D9BF0)),
                                          onDeleted: () => setState(() => _selectedLocation = null),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      for (final person in _taggedPeople)
                                        Chip(
                                          avatar: const Icon(CupertinoIcons.person_solid, size: 14, color: Color(0xFF1D9BF0)),
                                          label: Text(person, style: const TextStyle(fontSize: 12, color: Color(0xFF1D9BF0))),
                                          backgroundColor: const Color(0xFF1D9BF0).withValues(alpha: 0.1),
                                          deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF1D9BF0)),
                                          onDeleted: () => setState(() => _taggedPeople.remove(person)),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Bottom Controls Area (Reply visibility + Toolbar icons)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(height: 1, color: _borderColor),

                    // Reply permission pill (Image 1, 2)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: InkWell(
                        onTap: _openVisibilityPicker,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_replyVisibilityIcon, color: const Color(0xFF1D9BF0), size: 17),
                              const SizedBox(width: 8),
                              Text(
                                _replyVisibility,
                                style: const TextStyle(
                                  color: Color(0xFF1D9BF0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: _borderColor),

                    // Bottom Icons Toolbar (Photo, Poll, Location, Milestone)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      child: Row(
                        children: [
                          // 1. Image
                          _buildToolbarIcon(
                            icon: CupertinoIcons.photo,
                            tooltip: 'Add Image',
                            isActive: _pickedImageBytes != null,
                            onTap: _pickImage,
                          ),
                          const SizedBox(width: 20),

                          // 2. Poll
                          _buildToolbarIcon(
                            icon: CupertinoIcons.list_bullet,
                            tooltip: 'Create Poll',
                            isActive: _isPollActive,
                            onTap: _togglePoll,
                          ),
                          const SizedBox(width: 20),

                          // 3. Location
                          _buildToolbarIcon(
                            icon: CupertinoIcons.location,
                            tooltip: 'Add Location',
                            isActive: _selectedLocation != null,
                            onTap: _openLocationPicker,
                          ),
                          const SizedBox(width: 20),

                          // 4. Flag / Milestone
                          _buildToolbarIcon(
                            icon: CupertinoIcons.flag,
                            tooltip: 'Add Milestone',
                            isActive: _selectedMilestone != null,
                            onTap: _openMilestonePicker,
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

  // -------------------------------------------------------------
  // WIDGET HELPERS
  // -------------------------------------------------------------

  Widget _buildUserAvatar(String avatarUrl, String initials) {
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFF0F4C81),
        backgroundImage: avatarUrl.startsWith('http')
            ? NetworkImage(avatarUrl) as ImageProvider
            : AssetImage(avatarUrl) as ImageProvider,
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF0F4C81),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildToolbarIcon({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1D9BF0).withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1D9BF0),
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview({
    required Widget imageWidget,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageWidget,
              ),
            ),
            // Close / Remove X button (top right)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
            // Badges at bottom of image: [Photo], [+ALT]
            Positioned(
              bottom: 10,
              left: 10,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Photo',
                      style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showAltTextDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _altText != null ? 'ALT ✓' : '+ALT',
                        style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Action tags below image (Image 5)
        Row(
          children: [
            InkWell(
              onTap: _openTagPeopleDialog,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: const [
                    Icon(CupertinoIcons.person, size: 16, color: Color(0xFF1D9BF0)),
                    SizedBox(width: 6),
                    Text(
                      'Tag people',
                      style: TextStyle(color: Color(0xFF1D9BF0), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: _openLocationPicker,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: const [
                    Icon(CupertinoIcons.location, size: 16, color: Color(0xFF1D9BF0)),
                    SizedBox(width: 6),
                    Text(
                      'Add location',
                      style: TextStyle(color: Color(0xFF1D9BF0), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPollComposer() {
    final pollBg = _isDark ? const Color(0xFF16181C) : const Color(0xFFF7F9F9);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pollBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Remove Poll
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(CupertinoIcons.list_bullet, color: Color(0xFF1D9BF0), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Poll',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF1D9BF0)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _isPollActive = false),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _borderColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: _textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Poll choices
          for (int i = 0; i < _pollControllers.length; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Icon(CupertinoIcons.photo, size: 18, color: _subTextColor),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _pollControllers[i],
                      style: TextStyle(color: _textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Choice ${i + 1}${i >= 2 ? ' (optional)' : ''}',
                        hintStyle: TextStyle(color: _subTextColor, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (i == _pollControllers.length - 1 && _pollControllers.length < 4)
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF1D9BF0), size: 20),
                      onPressed: () => setState(() => _pollControllers.add(TextEditingController())),
                    )
                  else if (i >= 2)
                    IconButton(
                      icon: Icon(Icons.close, color: _subTextColor, size: 18),
                      onPressed: () => setState(() => _pollControllers.removeAt(i).dispose()),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.close, color: _subTextColor, size: 18),
                      onPressed: () => _pollControllers[i].clear(),
                    ),
                ],
              ),
            ),
          ],

          Divider(height: 16, color: _borderColor),

          // Poll Length
          InkWell(
            onTap: _showPollLengthPicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Poll length', style: TextStyle(color: _subTextColor, fontSize: 12.5)),
                  const SizedBox(height: 2),
                  Text(
                    _pollLength,
                    style: const TextStyle(color: Color(0xFF1D9BF0), fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPollLengthPicker() {
    final lengths = ['1 hour', '6 hours', '1 day', '3 days', '7 days'];
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Poll Length', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              for (final len in lengths)
                ListTile(
                  title: Text(len, style: TextStyle(color: _textColor, fontWeight: _pollLength == len ? FontWeight.bold : FontWeight.normal)),
                  trailing: _pollLength == len ? const Icon(Icons.check, color: Color(0xFF1D9BF0)) : null,
                  onTap: () {
                    setState(() => _pollLength = len);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAltTextDialog() {
    final TextEditingController altCtrl = TextEditingController(text: _altText ?? '');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Image Description (ALT)', style: TextStyle(color: _textColor, fontSize: 17, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: altCtrl,
          maxLines: 3,
          style: TextStyle(color: _textColor),
          decoration: InputDecoration(
            hintText: 'Describe this image for screen readers...',
            hintStyle: TextStyle(color: _subTextColor),
            filled: true,
            fillColor: _isDark ? const Color(0xFF16181C) : const Color(0xFFF7F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: _subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9BF0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              setState(() => _altText = altCtrl.text.trim().isNotEmpty ? altCtrl.text.trim() : null);
              Navigator.pop(dialogCtx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Discard post?', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text("This can't be undone and you'll lose your changes.", style: TextStyle(color: _subTextColor, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: _subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
            },
            child: const Text('Discard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // BOTTOM SHEETS (MILESTONE, LOCATION, VISIBILITY)
  // -------------------------------------------------------------

  Widget _buildMilestonePickerSheet(BuildContext ctx) {
    final milestones = [
      '🏆 Academic Excellence Award',
      '💼 New Internship / Job Offer',
      '🚀 Shipped New Project / App',
      '🎓 Semester Milestone / Graduation',
      '📜 Professional Certification',
      '🤝 Student Chapter Leadership',
      '💡 Patent / Research Paper Published',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _borderColor, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Tag Milestone / Achievement', style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (final m in milestones)
              ListTile(
                title: Text(m, style: TextStyle(color: _textColor, fontSize: 14.5, fontWeight: FontWeight.w600)),
                trailing: _selectedMilestone == m ? const Icon(Icons.check, color: Color(0xFF1D9BF0)) : null,
                onTap: () {
                  setState(() => _selectedMilestone = m);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPickerSheet(BuildContext ctx) {
    final locations = [
      'Madhav Institute of Technology & Science, Gwalior',
      'Central Computing Facility (CCF), MITS',
      'Central Library & Research Hub, MITS',
      'Campus Innovation & Startup Cell',
      'MITS Student Activity Center',
      'Gwalior, Madhya Pradesh',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _borderColor, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Add Location', style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (final loc in locations)
              ListTile(
                leading: const Icon(CupertinoIcons.location_solid, color: Color(0xFF1D9BF0), size: 20),
                title: Text(loc, style: TextStyle(color: _textColor, fontSize: 14)),
                onTap: () {
                  setState(() => _selectedLocation = loc);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityPickerSheet(BuildContext ctx) {
    final options = [
      {'title': 'Everyone can reply', 'desc': 'Anyone on Acadyk can reply to this post', 'icon': CupertinoIcons.globe},
      {'title': 'People you follow', 'desc': 'Only accounts you follow can reply', 'icon': CupertinoIcons.person_2_fill},
      {'title': 'Only people you mention', 'desc': 'Only people mentioned can reply', 'icon': CupertinoIcons.at},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _borderColor, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Who can reply?', style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Choose who can reply to this post. Anyone mentioned can always reply.', style: TextStyle(color: _subTextColor, fontSize: 13.5)),
            const SizedBox(height: 16),
            for (final opt in options)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D9BF0).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(opt['icon'] as IconData, color: const Color(0xFF1D9BF0), size: 20),
                ),
                title: Text(opt['title'] as String, style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text(opt['desc'] as String, style: TextStyle(color: _subTextColor, fontSize: 12.5)),
                trailing: _replyVisibility == opt['title'] ? const Icon(Icons.check, color: Color(0xFF1D9BF0)) : null,
                onTap: () {
                  setState(() {
                    _replyVisibility = opt['title'] as String;
                    _replyVisibilityIcon = opt['icon'] as IconData;
                  });
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}
