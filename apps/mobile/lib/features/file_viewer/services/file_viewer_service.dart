import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/services/file_cache_service.dart';
import '../domain/file_type_detector.dart';
import '../domain/file_viewer_metadata.dart';
import '../presentation/universal_file_viewer_screen.dart';

/// Central service for opening any academic or user file.
///
/// Follows the WhatsApp model:
/// - Checks or downloads the file into local cache first.
/// - Opens the native OS "Open with" chooser popup so the user can open it with
///   any installed application (ChatGPT, Drive PDF Viewer, Files by Google, Word, etc.).
/// - Gracefully falls back to the in-app viewer if no third-party app is installed.
class FileViewerService {
  FileViewerService._();
  static final FileViewerService instance = FileViewerService._();

  /// Resolve MIME type based on file name or extension
  static String resolveMimeType(String fileName) {
    final clean = fileName.toLowerCase().split('?').first;
    final ext = clean.contains('.') ? clean.split('.').last : '';
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      default:
        return '*/*';
    }
  }

  /// Open a file with the native OS "Open with" system chooser popup (WhatsApp style: ChatGPT, Drive, Files by Google, Word, etc.).
  static Future<void> openFile(
    BuildContext context, {
    required String fileUrl,
    required String fileName,
    int? fileSizeBytes,
    String? localFilePath,
    String? mimeType,
    String? uploadedBy,
    DateTime? uploadedAt,
    bool preferInApp = false,
  }) async {
    if (fileUrl.isEmpty) return;

    final resolvedMime = mimeType ?? resolveMimeType(fileName);

    // 1. Web Platform
    if (kIsWeb) {
      if (preferInApp) {
        _openInApp(
          context,
          fileUrl: fileUrl,
          fileName: fileName,
          fileSizeBytes: fileSizeBytes,
          mimeType: resolvedMime,
          uploadedBy: uploadedBy,
          uploadedAt: uploadedAt,
        );
      } else {
        final uri = Uri.parse(fileUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else if (context.mounted) {
          _openInApp(
            context,
            fileUrl: fileUrl,
            fileName: fileName,
            fileSizeBytes: fileSizeBytes,
            mimeType: resolvedMime,
            uploadedBy: uploadedBy,
            uploadedAt: uploadedAt,
          );
        }
      }
      return;
    }

    // 2. Mobile / Desktop Native Platform
    File? localFile;
    if (localFilePath != null && File(localFilePath).existsSync()) {
      localFile = File(localFilePath);
    } else {
      final isCached = await FileCacheService.instance.isFileDownloaded(fileUrl, fileName);
      if (isCached) {
        localFile = await FileCacheService.instance.getLocalFile(fileUrl, fileName);
      } else {
        localFile = await FileCacheService.instance.downloadFile(fileUrl, fileName);
      }
    }

    if (localFile == null || !localFile.existsSync()) {
      debugPrint('[FileViewerService] Local file not available for $fileName');
      return;
    }

    if (preferInApp) {
      if (context.mounted) {
        _openInApp(
          context,
          fileUrl: fileUrl,
          fileName: fileName,
          fileSizeBytes: fileSizeBytes ?? (localFile.existsSync() ? localFile.lengthSync() : 0),
          localFilePath: localFile.path,
          mimeType: resolvedMime,
          uploadedBy: uploadedBy,
          uploadedAt: uploadedAt,
        );
      }
      return;
    }

    // 3. Trigger Native OS "Open with" System Chooser (WhatsApp Experience)
    try {
      final result = await OpenFilex.open(
        localFile.path,
        type: resolvedMime,
      );

      debugPrint('[FileViewerService] OpenFilex result: ${result.type} - ${result.message}');

      // If no external app is installed or an error occurred, fallback to in-app viewer gracefully
      if (result.type == ResultType.noAppToOpen && context.mounted) {
        _openInApp(
          context,
          fileUrl: fileUrl,
          fileName: fileName,
          fileSizeBytes: fileSizeBytes ?? (localFile.existsSync() ? localFile.lengthSync() : 0),
          localFilePath: localFile.path,
          mimeType: resolvedMime,
          uploadedBy: uploadedBy,
          uploadedAt: uploadedAt,
        );
      }
    } catch (e) {
      debugPrint('[FileViewerService] Failed to open with OpenFilex: $e');
      if (context.mounted) {
        _openInApp(
          context,
          fileUrl: fileUrl,
          fileName: fileName,
          fileSizeBytes: fileSizeBytes ?? (localFile.existsSync() ? localFile.lengthSync() : 0),
          localFilePath: localFile.path,
          mimeType: resolvedMime,
          uploadedBy: uploadedBy,
          uploadedAt: uploadedAt,
        );
      }
    }
  }

  /// Open explicitly in the Acadyk Universal In-App Viewer
  static void openFileInApp(
    BuildContext context, {
    required String fileUrl,
    required String fileName,
    int? fileSizeBytes,
    String? localFilePath,
    String? mimeType,
    String? uploadedBy,
    DateTime? uploadedAt,
  }) {
    _openInApp(
      context,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      localFilePath: localFilePath,
      mimeType: mimeType ?? resolveMimeType(fileName),
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt,
    );
  }

  static void _openInApp(
    BuildContext context, {
    required String fileUrl,
    required String fileName,
    int? fileSizeBytes,
    String? localFilePath,
    String? mimeType,
    String? uploadedBy,
    DateTime? uploadedAt,
  }) {
    final detectedType = FileTypeDetector.detect(
      fileName: fileName,
      mimeType: mimeType,
    );

    final metadata = FileViewerMetadata(
      fileName: fileName,
      fileSizeBytes: fileSizeBytes ?? 0,
      mimeType: mimeType,
      fileUrl: fileUrl,
      localPath: localFilePath,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt ?? DateTime.now(),
      isDownloaded: localFilePath != null && File(localFilePath).existsSync(),
      fileType: detectedType,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => UniversalFileViewerScreen(metadata: metadata),
      ),
    );
  }
}
