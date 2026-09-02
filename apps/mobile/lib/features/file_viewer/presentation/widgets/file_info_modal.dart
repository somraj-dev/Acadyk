import 'package:flutter/material.dart';
import '../../domain/file_type.dart';
import '../../domain/file_viewer_metadata.dart';

/// Bottom sheet presenting file properties, upload provenance, and storage status.
class FileInfoModal extends StatelessWidget {
  final FileViewerMetadata metadata;

  const FileInfoModal({super.key, required this.metadata});

  static void show(BuildContext context, FileViewerMetadata metadata) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FileInfoModal(metadata: metadata),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Title
            Row(
              children: [
                Icon(metadata.fileType.icon, color: metadata.fileType.accentColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'File Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 12),

            _buildDetailRow('File Name', metadata.fileName, textPrimary, textSecondary),
            _buildDetailRow('Category', metadata.fileType.displayName, textPrimary, textSecondary),
            _buildDetailRow('Format Extension', '.${metadata.extensionUpper.toLowerCase()}', textPrimary, textSecondary),
            _buildDetailRow('File Size', metadata.formattedSize, textPrimary, textSecondary),
            if (metadata.uploadedBy != null)
              _buildDetailRow('Uploaded By', metadata.uploadedBy!, textPrimary, textSecondary),
            _buildDetailRow('Uploaded Date', metadata.formattedDate, textPrimary, textSecondary),
            _buildDetailRow(
              'Storage Status',
              metadata.isDownloaded ? 'Cached (Offline Ready)' : 'Remote / Streaming',
              metadata.isDownloaded ? const Color(0xFF10B981) : textPrimary,
              textSecondary,
            ),
            if (metadata.localPath != null)
              _buildDetailRow('Cache Location', metadata.localPath!, textPrimary, textSecondary),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 12.5, color: labelColor)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: valueColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
