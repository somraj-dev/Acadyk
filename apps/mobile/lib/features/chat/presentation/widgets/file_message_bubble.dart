import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../common/services/file_cache_service.dart';
import '../../../file_viewer/services/file_viewer_service.dart';

/// WhatsApp-style on-demand (lazy) file & document message bubble.
///
/// Features:
/// 1. ZERO auto-download: On render, only metadata is shown.
/// 2. Interactive state:
///    - `notDownloaded`: Shows file metadata + circular download button with size (`↓ 4.8 MB`).
///    - `downloading`: Shows radial progress indicator with live percentage and cancel capability.
///    - `downloaded`: Shows "Open" status. Subsequent taps open the local cached file instantly.
class FileMessageBubble extends StatefulWidget {
  final String fileName;
  final int fileSizeBytes;
  final String mimeType;
  final String fileUrl;
  final String? thumbnailUrl;
  final bool isMe;

  const FileMessageBubble({
    super.key,
    required this.fileName,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.fileUrl,
    this.thumbnailUrl,
    this.isMe = false,
  });

  @override
  State<FileMessageBubble> createState() => _FileMessageBubbleState();
}

class _FileMessageBubbleState extends State<FileMessageBubble> {
  FileDownloadState _state = FileDownloadState.notDownloaded;
  double _downloadProgress = 0.0;
  File? _localFile;

  @override
  void initState() {
    super.initState();
    _checkCacheStatus();
  }

  @override
  void didUpdateWidget(covariant FileMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileUrl != widget.fileUrl) {
      _checkCacheStatus();
    }
  }

  Future<void> _checkCacheStatus() async {
    final isCached = await FileCacheService.instance.isFileDownloaded(
      widget.fileUrl,
      widget.fileName,
    );
    if (mounted) {
      if (isCached) {
        final file = await FileCacheService.instance.getLocalFile(
          widget.fileUrl,
          widget.fileName,
        );
        setState(() {
          _state = FileDownloadState.downloaded;
          _localFile = file;
        });
      } else {
        setState(() {
          _state = FileDownloadState.notDownloaded;
        });
      }
    }
  }

  Future<void> _startDownload() async {
    if (_state == FileDownloadState.downloading) return;

    setState(() {
      _state = FileDownloadState.downloading;
      _downloadProgress = 0.0;
    });

    final file = await FileCacheService.instance.downloadFile(
      widget.fileUrl,
      widget.fileName,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      },
    );

    if (mounted) {
      if (file != null) {
        setState(() {
          _state = FileDownloadState.downloaded;
          _localFile = file;
        });
        // Automatically open inside Acadyk once download completes
        if (mounted) {
          await FileViewerService.openFile(
            context,
            fileUrl: widget.fileUrl,
            fileName: widget.fileName,
            fileSizeBytes: widget.fileSizeBytes,
            mimeType: widget.mimeType,
          );
        }
      } else {
        setState(() {
          _state = FileDownloadState.notDownloaded;
        });
      }
    }
  }

  void _cancelDownload() {
    FileCacheService.instance.cancelDownload(widget.fileUrl, widget.fileName);
    if (mounted) {
      setState(() {
        _state = FileDownloadState.notDownloaded;
        _downloadProgress = 0.0;
      });
    }
  }

  Future<void> _handleTap() async {
    if (_state == FileDownloadState.downloaded) {
      await FileViewerService.openFile(
        context,
        fileUrl: widget.fileUrl,
        fileName: widget.fileName,
        fileSizeBytes: widget.fileSizeBytes,
        mimeType: widget.mimeType,
      );
    } else if (_state == FileDownloadState.notDownloaded) {
      if (kIsWeb) {
        // On Web, open directly in universal in-app viewer
        await FileViewerService.openFile(
          context,
          fileUrl: widget.fileUrl,
          fileName: widget.fileName,
          fileSizeBytes: widget.fileSizeBytes,
          mimeType: widget.mimeType,
        );
      } else {
        await _startDownload();
      }
    } else if (_state == FileDownloadState.downloading) {
      _cancelDownload();
    }
  }

  String get _formattedSize {
    if (widget.fileSizeBytes <= 0) return '';
    if (widget.fileSizeBytes < 1024) return '${widget.fileSizeBytes} B';
    if (widget.fileSizeBytes < 1024 * 1024) {
      return '${(widget.fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(widget.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get _fileExtension => widget.fileName.contains('.')
      ? widget.fileName.split('.').last.toUpperCase()
      : 'FILE';

  IconData get _fileIcon {
    final ext = widget.fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'txt':
      case 'csv':
        return Icons.article_rounded;
      case 'mp4':
      case 'mov':
        return Icons.videocam_rounded;
      case 'mp3':
      case 'aac':
        return Icons.audiotrack_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get _fileAccentColor {
    final ext = widget.fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return const Color(0xFFE53935); // Red
      case 'doc':
      case 'docx':
        return const Color(0xFF1E88E5); // Blue
      case 'xls':
      case 'xlsx':
        return const Color(0xFF43A047); // Green
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF7043); // Orange
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'gif':
        return const Color(0xFF8E24AA); // Purple
      case 'mp4':
      case 'mov':
        return const Color(0xFF5C6BC0); // Indigo
      case 'mp3':
      case 'aac':
        return const Color(0xFFEC407A); // Pink
      default:
        return const Color(0xFF78909C); // Blue Grey
    }
  }

  bool get _isImage => widget.mimeType.startsWith('image/');

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return _buildImageBubble();
    }
    return _buildDocumentBubble();
  }

  /// WhatsApp-style document bubble with lazy on-demand download button
  Widget _buildDocumentBubble() {
    final bgColor = widget.isMe ? const Color(0xFF3B82F6) : const Color(0xFFF3F4F6);
    final textColor = widget.isMe ? Colors.white : const Color(0xFF111827);
    final subtitleColor = widget.isMe ? Colors.white70 : const Color(0xFF6B7280);
    final iconBg = widget.isMe
        ? Colors.white.withValues(alpha: 0.15)
        : _fileAccentColor.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // File type badge icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _fileIcon,
                color: widget.isMe ? Colors.white : _fileAccentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // File name and metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fileName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formattedSize.isNotEmpty
                        ? '$_formattedSize · $_fileExtension'
                        : _fileExtension,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // WhatsApp-style action button (Download / Progress / Open)
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  /// WhatsApp-style Action Button:
  /// - Not Downloaded: Circular button with downward arrow [↓]
  /// - Downloading: Radial progress ring with percentage / cancel icon
  /// - Downloaded: Document view / Open icon
  Widget _buildActionButton() {
    switch (_state) {
      case FileDownloadState.notDownloaded:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isMe
                ? Colors.white.withValues(alpha: 0.2)
                : const Color(0xFFE5E7EB),
          ),
          child: Icon(
            Icons.arrow_downward_rounded,
            color: widget.isMe ? Colors.white : const Color(0xFF374151),
            size: 20,
          ),
        );

      case FileDownloadState.downloading:
        return SizedBox(
          width: 38,
          height: 38,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isMe ? Colors.white : _fileAccentColor,
                ),
                backgroundColor: widget.isMe
                    ? Colors.white24
                    : _fileAccentColor.withValues(alpha: 0.15),
              ),
              Icon(
                Icons.close_rounded,
                size: 16,
                color: widget.isMe ? Colors.white : const Color(0xFF374151),
              ),
            ],
          ),
        );

      case FileDownloadState.downloaded:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isMe
                ? Colors.white.withValues(alpha: 0.25)
                : const Color(0xFFE0E7FF),
          ),
          child: Icon(
            Icons.file_open_rounded,
            color: widget.isMe ? Colors.white : const Color(0xFF3B82F6),
            size: 20,
          ),
        );

      case FileDownloadState.failed:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.1),
          ),
          child: const Icon(
            Icons.refresh_rounded,
            color: Colors.red,
            size: 20,
          ),
        );
    }
  }

  /// WhatsApp-style Image Bubble with on-demand download overlay
  Widget _buildImageBubble() {
    // If already downloaded and available locally, display from file
    if (_state == FileDownloadState.downloaded && _localFile != null) {
      return GestureDetector(
        onTap: _handleTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 240, maxHeight: 300),
            child: Image.file(
              _localFile!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    // Lazy state: Show placeholder or thumbnail with WhatsApp-style download overlay
    return GestureDetector(
      onTap: _handleTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 240,
          height: 200,
          color: const Color(0xFF1E293B),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Optional thumbnail preview if available
              if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
                Image.network(
                  widget.thumbnailUrl!,
                  width: 240,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              // Dark translucent backdrop
              Container(color: Colors.black.withValues(alpha: 0.35)),
              // Centered WhatsApp-style circular download button
              _buildActionButton(),
              // Bottom size badge
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formattedSize,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Upload progress indicator for file messages currently being sent by sender
class FileUploadProgressBubble extends StatelessWidget {
  final String fileName;
  final double progress; // 0.0 to 1.0

  const FileUploadProgressBubble({
    super.key,
    required this.fileName,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 3,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress > 0 ? progress : null,
                    minHeight: 3,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
