import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../common/services/file_cache_service.dart';
import '../domain/file_type_detector.dart';
import '../domain/file_viewer_metadata.dart';
import '../presentation/universal_file_viewer_screen.dart';

/// Central service for opening any academic or user file inside the Acadyk In-App Viewer.
class FileViewerService {
  FileViewerService._();
  static final FileViewerService instance = FileViewerService._();

  /// Open a file inside the Acadyk Universal File Viewer.
  /// Follows the WhatsApp model:
  /// - Checks local sandbox cache first.
  /// - If available: opens instantly.
  /// - If not downloaded: runs on-demand download, then opens.
  /// - Keeps the user inside Acadyk with back navigation.
  static Future<void> openFile(
    BuildContext context, {
    required String fileUrl,
    required String fileName,
    int? fileSizeBytes,
    String? localFilePath,
    String? mimeType,
    String? uploadedBy,
    DateTime? uploadedAt,
  }) async {
    if (fileUrl.isEmpty) return;

    File? localFile;
    bool isCached = false;

    if (!kIsWeb) {
      if (localFilePath != null && File(localFilePath).existsSync()) {
        localFile = File(localFilePath);
        isCached = true;
      } else {
        isCached = await FileCacheService.instance.isFileDownloaded(fileUrl, fileName);
        if (isCached) {
          localFile = await FileCacheService.instance.getLocalFile(fileUrl, fileName);
        }
      }
    }

    final detectedType = FileTypeDetector.detect(
      fileName: fileName,
      mimeType: mimeType,
    );

    final metadata = FileViewerMetadata(
      fileName: fileName,
      fileSizeBytes: fileSizeBytes ?? (localFile != null && localFile.existsSync() ? localFile.lengthSync() : 0),
      mimeType: mimeType,
      fileUrl: fileUrl,
      localPath: localFile?.path,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt ?? DateTime.now(),
      isDownloaded: isCached,
      fileType: detectedType,
    );

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => UniversalFileViewerScreen(metadata: metadata),
      ),
    );
  }
}
