import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../common/services/storage_service.dart';
import '../../../../core/network/api_client.dart';

class SettingsResumeScreen extends StatefulWidget {
  const SettingsResumeScreen({super.key});

  @override
  State<SettingsResumeScreen> createState() => _SettingsResumeScreenState();
}

class _SettingsResumeScreenState extends State<SettingsResumeScreen> {
  File? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickResume() async {
    final picked = await StorageService.pickImage(); // File picker fallback
    if (picked != null) {
      setState(() {
        _selectedFile = picked;
      });
    }
  }

  Future<void> _saveResume() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a resume file to upload')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final fileUrl = await StorageService.uploadFile(
        bucket: 'resumes',
        file: _selectedFile!,
        remotePath: 'resumes/${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (fileUrl != null) {
        await ApiClient.post('/me/resumes', data: {
          'title': 'My Latest Resume',
          'fileUrl': fileUrl,
          'isPrimary': true,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume uploaded successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading resume: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Resume',
          style: TextStyle(
            color: Color(0xFF191919),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF757575), size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Color(0xFF757575), size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Resume',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF191919),
                      ),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _pickResume,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Select File',
                      style: TextStyle(
                        color: Color(0xFF0073B1),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Remember that one pager that highlights how amazing you are? Time to let employers notice your potential through it.',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Color(0xFF737373),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              
              // Dashed upload container
              GestureDetector(
                onTap: _pickResume,
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: const Color(0xFFC4D9EC),
                    strokeWidth: 1.2,
                    borderRadius: 12.0,
                    dashLength: 6.0,
                    gap: 4.0,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F8FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE4F0FC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            color: Color(0xFF0073B1),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFile != null ? 'Selected: ${_selectedFile!.path.split(Platform.pathSeparator).last}' : 'Update Resume',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF0073B1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Supported file formats DOC, DOCX, PDF. File size limit 10 MB.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8E8E8E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Discard',
                      style: TextStyle(
                        color: Color(0xFF5E5E5E),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0073B1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: _isUploading ? null : _saveResume,
                    child: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dashLength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}
