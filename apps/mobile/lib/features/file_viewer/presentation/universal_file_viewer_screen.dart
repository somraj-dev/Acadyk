import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/file_type.dart';
import '../domain/file_viewer_metadata.dart';
import 'viewers/archive_viewer_widget.dart';
import 'viewers/code_viewer_widget.dart';
import 'viewers/data_viewer_widget.dart';
import 'viewers/docx_viewer_widget.dart';
import 'viewers/image_viewer_widget.dart';
import 'viewers/media_player_widget.dart';
import 'viewers/pdf_viewer_widget.dart';
import 'viewers/unsupported_viewer_widget.dart';
import 'widgets/file_info_modal.dart';

/// Central host screen for the Acadyk Universal In-App File Viewer.
/// Keeps users inside Acadyk with dedicated viewers, clean header, and contextual options.
class UniversalFileViewerScreen extends StatelessWidget {
  final FileViewerMetadata metadata;

  const UniversalFileViewerScreen({
    super.key,
    required this.metadata,
  });

  Future<void> _openExternally() async {
    if (metadata.localPath != null && metadata.localPath!.isNotEmpty) {
      final res = await OpenFilex.open(metadata.localPath!, type: metadata.mimeType);
      if (res.type == ResultType.done) return;
    }
    final uri = Uri.parse(metadata.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareFile(BuildContext context) {
    Clipboard.setData(ClipboardData(text: metadata.fileUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File link copied for sharing'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveOffline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${metadata.fileName} is cached for offline access.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: appBarBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: textPrimary,
          tooltip: 'Back to Acadyk',
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metadata.fileName,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Row(
              children: [
                Text(
                  metadata.fileType.displayName,
                  style: TextStyle(fontSize: 11, color: metadata.fileType.accentColor, fontWeight: FontWeight.w600),
                ),
                if (metadata.formattedSize.isNotEmpty) ...[
                  Text(' • ', style: TextStyle(fontSize: 11, color: textSecondary)),
                  Text(metadata.formattedSize, style: TextStyle(fontSize: 11, color: textSecondary)),
                ],
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: textPrimary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (action) {
              switch (action) {
                case 'info':
                  FileInfoModal.show(context, metadata);
                  break;
                case 'offline':
                  _saveOffline(context);
                  break;
                case 'share':
                  _shareFile(context);
                  break;
                case 'external':
                  _openExternally();
                  break;
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('File Information'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'offline',
                child: Row(
                  children: [
                    Icon(Icons.download_done_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Save Offline'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Share Link'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'external',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Open with External App'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildViewer(context),
    );
  }

  Widget _buildViewer(BuildContext context) {
    switch (metadata.fileType) {
      case AcadykFileType.pdf:
        return PdfViewerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
        );

      case AcadykFileType.image:
        return ImageViewerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
        );

      case AcadykFileType.code:
        return CodeViewerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
        );

      case AcadykFileType.csv:
        return DataViewerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
          isCsv: true,
        );

      case AcadykFileType.json:
        return DataViewerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
          isJson: true,
        );

      case AcadykFileType.text:
        return DataViewerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
        );

      case AcadykFileType.docx:
        return DocxViewerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
        );

      case AcadykFileType.archive:
        return ArchiveViewerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
        );

      case AcadykFileType.video:
        return MediaPlayerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
          isAudio: false,
        );

      case AcadykFileType.audio:
        return MediaPlayerWidget(
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileName: metadata.fileName,
          isAudio: true,
        );

      case AcadykFileType.executable:
        return UnsupportedViewerWidget(
          fileName: metadata.fileName,
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileSizeBytes: metadata.fileSizeBytes,
          isExecutable: true,
        );

      case AcadykFileType.unknown:
        return UnsupportedViewerWidget(
          fileName: metadata.fileName,
          fileUrl: metadata.fileUrl,
          localFilePath: metadata.localPath,
          fileSizeBytes: metadata.fileSizeBytes,
          isExecutable: false,
        );
    }
  }
}
