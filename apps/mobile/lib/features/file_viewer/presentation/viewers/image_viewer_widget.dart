import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// In-App Image Viewer with pinch-to-zoom, pan, rotate, and reset controls.
class ImageViewerWidget extends StatefulWidget {
  final String fileUrl;
  final String? localFilePath;
  final String fileName;

  const ImageViewerWidget({
    super.key,
    required this.fileUrl,
    this.localFilePath,
    required this.fileName,
  });

  @override
  State<ImageViewerWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  final TransformationController _transformController = TransformationController();
  int _rotationQuarterTurns = 0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _rotate() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
    });
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLocal = !kIsWeb && widget.localFilePath != null && File(widget.localFilePath!).existsSync();

    Widget imageContent;
    if (hasLocal) {
      imageContent = Image.file(
        File(widget.localFilePath!),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildError(isDark),
      );
    } else {
      imageContent = CachedNetworkImage(
        imageUrl: widget.fileUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        errorWidget: (_, __, ___) => _buildError(isDark),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 6.0,
              child: RotatedBox(
                quarterTurns: _rotationQuarterTurns,
                child: imageContent,
              ),
            ),
          ),

          // Floating bottom controls: Rotate & Reset Zoom
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.rotate_right_rounded, color: Colors.white, size: 22),
                      tooltip: 'Rotate 90°',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: _rotate,
                    ),
                    const SizedBox(width: 8),
                    Container(height: 16, width: 1, color: Colors.white24),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 22),
                      tooltip: 'Reset Zoom',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: _resetZoom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.broken_image_rounded, color: Color(0xFFEF4444), size: 48),
          SizedBox(height: 12),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
