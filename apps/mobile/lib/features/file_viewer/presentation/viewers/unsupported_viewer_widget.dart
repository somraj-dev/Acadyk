import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fallback viewer for unsupported file formats and security-flagged executables.
class UnsupportedViewerWidget extends StatelessWidget {
  final String fileName;
  final String fileUrl;
  final String? localFilePath;
  final int fileSizeBytes;
  final bool isExecutable;

  const UnsupportedViewerWidget({
    super.key,
    required this.fileName,
    required this.fileUrl,
    this.localFilePath,
    required this.fileSizeBytes,
    this.isExecutable = false,
  });

  String get _formattedSize {
    if (fileSizeBytes <= 0) return '';
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      color: bg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExecutable
                    ? const Color(0xFFDC2626).withValues(alpha: 0.4)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isExecutable
                        ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                  ),
                  child: Icon(
                    isExecutable ? Icons.security_rounded : Icons.insert_drive_file_rounded,
                    color: isExecutable ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_formattedSize.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(_formattedSize, style: TextStyle(fontSize: 13, color: textSecondary)),
                ],
                const SizedBox(height: 16),
                if (isExecutable)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Executable program. For your security, Acadyk will never execute application packages or scripts automatically.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFDC2626), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'In-app preview is not available for this proprietary file format.',
                    style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open with External Application'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _openExternally,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
