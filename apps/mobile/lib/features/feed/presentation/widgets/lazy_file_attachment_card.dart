import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../common/services/file_cache_service.dart';
import '../../../file_viewer/services/file_viewer_service.dart';

/// WhatsApp-style On-Demand (Lazy) File & Document Card for College Feed Posts.
///
/// Designed to be embedded directly within post cards and community feed items.
/// Adheres strictly to the WhatsApp lazy download architecture:
/// - ZERO auto-download: Browsing feed posts never downloads attached documents.
/// - Shows file details (Name, Size, Extension badge) + prominent download button.
/// - On tap: Streams on-demand via Dio with progress indicator into local sandbox cache.
/// - Subsequent taps: Opens the cached local file instantly with zero network consumption.
class LazyFileAttachmentCard extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final int fileSizeBytes;
  final String? mimeType;
  final String? label; // e.g. "Lecture Notes", "Assignment Sheet"

  const LazyFileAttachmentCard({
    super.key,
    required this.fileUrl,
    required this.fileName,
    required this.fileSizeBytes,
    this.mimeType,
    this.label,
  });

  @override
  State<LazyFileAttachmentCard> createState() => _LazyFileAttachmentCardState();
}

class _LazyFileAttachmentCardState extends State<LazyFileAttachmentCard> {
  FileDownloadState _state = FileDownloadState.notDownloaded;
  double _downloadProgress = 0.0;
  File? _localFile;

  @override
  void initState() {
    super.initState();
    _checkCacheStatus();
  }

  @override
  void didUpdateWidget(covariant LazyFileAttachmentCard oldWidget) {
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
            localFilePath: _localFile?.path,
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
        localFilePath: _localFile?.path,
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
      : 'DOC';

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
      case 'zip':
      case 'rar':
        return Icons.folder_zip_rounded;
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
      case 'zip':
      case 'rar':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF0284C7); // Sky Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorder, width: 1.0),
        ),
        child: Row(
          children: [
            // Left badge: Document icon with soft neutral background
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _fileIcon,
                color: _fileAccentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Middle: File name & formatted size
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.fileName,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$_fileExtension${_formattedSize.isNotEmpty ? " • $_formattedSize" : ""}',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right: Download Action Button
            _buildActionButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    switch (_state) {
      case FileDownloadState.notDownloaded:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          child: Icon(
            Icons.arrow_downward_rounded,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF475569),
            size: 18,
          ),
        );

      case FileDownloadState.downloading:
        return SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                strokeWidth: 3.2,
                valueColor: AlwaysStoppedAnimation<Color>(_fileAccentColor),
                backgroundColor: _fileAccentColor.withValues(alpha: 0.15),
              ),
              Icon(
                Icons.close_rounded,
                size: 16,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ],
          ),
        );

      case FileDownloadState.downloaded:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.25 : 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.file_open_rounded,
                color: Color(0xFF3B82F6),
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Open',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );

      case FileDownloadState.failed:
        return Container(
          width: 40,
          height: 40,
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
}
