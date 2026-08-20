import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:acadyk/common/services/storage_service.dart';

class AddCoverImageScreen extends StatefulWidget {
  final String? currentBannerUrl;
  final Uint8List? currentBannerBytes;

  const AddCoverImageScreen({
    super.key,
    this.currentBannerUrl,
    this.currentBannerBytes,
  });

  @override
  State<AddCoverImageScreen> createState() => _AddCoverImageScreenState();
}

class _AddCoverImageScreenState extends State<AddCoverImageScreen> {
  String? _selectedUrl;
  Uint8List? _uploadedBytes;
  String? _uploadedName;
  String? _uploadedPath;

  // Curated preset cover images powered by Lummi / Unsplash
  final List<Map<String, String>> _presetImages = [
    {
      'id': 'ocean_waves',
      'title': 'Coastal Ocean Waves & Shore',
      'url': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
      'assetFallback': 'assets/images/ocean_wave_header.png',
    },
    {
      'id': 'glass_cabin',
      'title': 'Glass Cabin & Lake Forest',
      'url': 'https://images.unsplash.com/photo-1510798831971-661eb04b3739?auto=format&fit=crop&w=1200&q=80',
      'assetFallback': 'assets/images/team_celebration_banner.png',
    },
    {
      'id': 'flower_meadow',
      'title': 'Wildflower Meadow in Sunlight',
      'url': 'https://images.unsplash.com/photo-1470240731273-7821a6eeb6bd?auto=format&fit=crop&w=1200&q=80',
      'assetFallback': 'assets/images/young_entrepreneur.jpg',
    },
    {
      'id': 'sunset_cliff',
      'title': 'Sunset Ocean Cliff & Cascades',
      'url': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
      'assetFallback': 'assets/images/ocean_wave_header.png',
    },
    {
      'id': 'mediterranean_street',
      'title': 'Mediterranean Sunlit Street',
      'url': 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=1200&q=80',
      'assetFallback': 'assets/images/team_celebration_banner.png',
    },
    {
      'id': 'bougainvillea_arch',
      'title': 'Moroccan Arch & Bougainvillea',
      'url': 'https://images.unsplash.com/photo-1509233725247-49e657c54213?auto=format&fit=crop&w=1200&q=80',
      'assetFallback': 'assets/images/young_entrepreneur.jpg',
    },
    {
      'id': 'night_skyline',
      'title': 'City Skyline at Night',
      'url': 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?auto=format&fit=crop&w=1200&q=80',
      'assetFallback': 'assets/images/time_handshake.jpg',
    },
    {
      'id': 'tech_workspace',
      'title': 'Modern Tech Workspace',
      'url': 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80',
      'assetFallback': 'assets/images/warp_team.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.currentBannerUrl;
    _uploadedBytes = widget.currentBannerBytes;
  }

  Future<void> _handleUploadSinglePhoto() async {
    final xfile = await StorageService.pickImageXFile();
    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      setState(() {
        _uploadedBytes = bytes;
        _uploadedName = xfile.name;
        _uploadedPath = xfile.path;
        _selectedUrl = null; // Clear preset selection when custom photo uploaded
      });
    }
  }

  void _onSave() {
    if (_uploadedBytes != null) {
      Navigator.of(context).pop({
        'bytes': _uploadedBytes,
        'name': _uploadedName,
        'path': _uploadedPath,
        'url': _uploadedPath,
      });
    } else if (_selectedUrl != null) {
      Navigator.of(context).pop({
        'url': _selectedUrl,
        'bytes': null,
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const textColor = Color(0xFF1E293B);
    const subtitleColor = Color(0xFF64748B);

    final bool hasSelection = (_uploadedBytes != null) || (_selectedUrl != null && _selectedUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add a cover image',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.5,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle description
                    const Text(
                      'Showcase your personality, interests, work, or team moments',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: subtitleColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Upload single photo button
                    OutlinedButton.icon(
                      onPressed: _handleUploadSinglePhoto,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.file_upload_outlined,
                        size: 20,
                        color: textColor,
                      ),
                      label: const Text(
                        'Upload single photo',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    if (_uploadedBytes != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _uploadedBytes!,
                                width: 70,
                                height: 42,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Custom Photo Selected',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                  Text(
                                    'From your local device gallery',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20, color: Color(0xFF166534)),
                              onPressed: () {
                                setState(() {
                                  _uploadedBytes = null;
                                  _uploadedName = null;
                                  _uploadedPath = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
                    const SizedBox(height: 16),

                    // Section Heading
                    const Text(
                      'Choose an image',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Powered by Lummi.ai',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Curated Image Cards List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _presetImages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _presetImages[index];
                        final url = item['url']!;
                        final fallback = item['assetFallback']!;
                        final isSelected = (_uploadedBytes == null && _selectedUrl == url);

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _uploadedBytes = null;
                              _uploadedName = null;
                              _uploadedPath = null;
                              _selectedUrl = url;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0F4C81) : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Radio Selection Circle
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                  child: Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    color: isSelected ? const Color(0xFF0F4C81) : const Color(0xFF64748B),
                                    size: 24,
                                  ),
                                ),

                                // Image Thumbnail
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(11),
                                      bottomRight: Radius.circular(11),
                                    ),
                                    child: Image.network(
                                      url,
                                      height: 64,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        fallback,
                                        height: 64,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar with 'Learn more' and 'Save' button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Curated cover images powered by Lummi.ai and Acadyk.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      'Learn more',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: hasSelection ? _onSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C81),
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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
