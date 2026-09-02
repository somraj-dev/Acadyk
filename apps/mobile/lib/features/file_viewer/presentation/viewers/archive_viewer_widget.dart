import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// In-App Archive (ZIP) Inspector displaying entry hierarchy, sizes, and file metadata.
class ArchiveViewerWidget extends StatefulWidget {
  final String fileUrl;
  final String? localFilePath;
  final String fileName;

  const ArchiveViewerWidget({
    super.key,
    required this.fileUrl,
    this.localFilePath,
    required this.fileName,
  });

  @override
  State<ArchiveViewerWidget> createState() => _ArchiveViewerWidgetState();
}

class _ArchiveViewerWidgetState extends State<ArchiveViewerWidget> {
  final List<ArchiveFile> _entries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _inspectArchive();
  }

  Future<void> _inspectArchive() async {
    setState(() => _isLoading = true);
    try {
      Uint8List bytes;
      if (!kIsWeb && widget.localFilePath != null && await File(widget.localFilePath!).exists()) {
        bytes = await File(widget.localFilePath!).readAsBytes();
      } else {
        final res = await Dio().get<List<int>>(
          widget.fileUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        bytes = Uint8List.fromList(res.data ?? []);
      }

      final archive = ZipDecoder().decodeBytes(bytes);
      if (mounted) {
        setState(() {
          _entries.clear();
          _entries.addAll(archive.files);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not inspect archive: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_zip_rounded, color: Color(0xFFEA580C), size: 48),
              const SizedBox(height: 12),
              Text(
                'Archive Preview Unavailable',
                style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(_errorMessage!, style: TextStyle(color: textSecondary, fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final totalUncompressed = _entries.fold<int>(0, (sum, f) => sum + f.size);

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header summary
          Container(
            padding: const EdgeInsets.all(16),
            color: cardBg,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_zip_rounded, color: Color(0xFFEA580C), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fileName,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_entries.length} items • ${_formatBytes(totalUncompressed)} uncompressed',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),

          // File entries list
          Expanded(
            child: ListView.separated(
              itemCount: _entries.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 56,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, idx) {
                final entry = _entries[idx];
                final isDir = entry.name.endsWith('/');
                final isExe = entry.name.endsWith('.exe') || entry.name.endsWith('.apk') || entry.name.endsWith('.bat');

                return ListTile(
                  dense: true,
                  leading: Icon(
                    isDir
                        ? Icons.folder_rounded
                        : (isExe ? Icons.warning_amber_rounded : Icons.insert_drive_file_rounded),
                    color: isDir
                        ? const Color(0xFFF59E0B)
                        : (isExe ? const Color(0xFFDC2626) : const Color(0xFF3B82F6)),
                    size: 22,
                  ),
                  title: Text(
                    entry.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isDir ? FontWeight.w600 : FontWeight.normal,
                      color: isExe ? const Color(0xFFDC2626) : textPrimary,
                    ),
                  ),
                  subtitle: isDir ? null : Text(_formatBytes(entry.size), style: TextStyle(fontSize: 11, color: textSecondary)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
