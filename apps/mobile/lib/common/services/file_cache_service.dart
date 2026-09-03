import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/file_viewer/services/file_viewer_service.dart';

/// Enum representing the download state of a file in the app (WhatsApp model).
enum FileDownloadState {
  notDownloaded,
  downloading,
  downloaded,
  failed,
}

/// Singleton service managing on-demand (lazy) file downloads and local disk caching.
///
/// Follows the WhatsApp architecture:
/// 1. Files are NEVER automatically downloaded upon receiving or rendering in feed/chat.
/// 2. Files are downloaded ONLY when the user explicitly taps to view/download them.
/// 3. Downloaded files are cached locally in the sandbox temporary directory and reopened
///    instantly on subsequent taps without re-downloading or consuming network data.
class FileCacheService {
  FileCacheService._internal();
  static final FileCacheService instance = FileCacheService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );

  /// In-memory cache directory reference
  Directory? _cacheDir;

  /// Map of active cancel tokens for ongoing downloads
  final Map<String, CancelToken> _activeDownloads = {};

  /// Cache directory initialization: `<systemTemp>/acadyk_media_cache`
  Future<Directory> _getCacheDirectory() async {
    if (_cacheDir != null && await _cacheDir!.exists()) {
      return _cacheDir!;
    }
    final tempDir = Directory.systemTemp;
    final dir = Directory('${tempDir.path}/acadyk_media_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  /// Generate a deterministic, sanitized file name for caching based on URL and original name.
  String _getCacheKey(String fileUrl, String fileName) {
    final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final urlHash = fileUrl.hashCode.abs().toRadixString(36);
    return '${urlHash}_$sanitizedName';
  }

  /// Synchronously or asynchronously check if a file already exists in local disk cache.
  Future<bool> isFileDownloaded(String fileUrl, String fileName) async {
    if (kIsWeb) return false;
    if (fileUrl.isEmpty) return false;
    try {
      final file = await getLocalFile(fileUrl, fileName);
      return await file.exists() && (await file.length()) > 0;
    } catch (_) {
      return false;
    }
  }

  /// Get the [File] handle for the cached file (may or may not exist yet on disk).
  Future<File> getLocalFile(String fileUrl, String fileName) async {
    final dir = await _getCacheDirectory();
    final cacheKey = _getCacheKey(fileUrl, fileName);
    return File('${dir.path}/$cacheKey');
  }

  /// Download a file on-demand with progress tracking.
  ///
  /// Returns the cached [File] on success, or `null` if cancelled or failed.
  Future<File?> downloadFile(
    String fileUrl,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    if (fileUrl.isEmpty) return null;

    // Data URI (base64) handling
    if (fileUrl.startsWith('data:') && fileUrl.contains(';base64,')) {
      try {
        final base64Str = fileUrl.split(';base64,').last;
        final bytes = base64Decode(base64Str);
        final localFile = await getLocalFile(fileUrl, fileName);
        if (!await localFile.parent.exists()) {
          await localFile.parent.create(recursive: true);
        }
        await localFile.writeAsBytes(bytes);
        onProgress?.call(1.0);
        return localFile;
      } catch (e) {
        debugPrint('[FileCacheService] Error decoding data URI: $e');
        return null;
      }
    }

    // Web fallback: open directly
    if (kIsWeb) {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return null;
    }

    final localFile = await getLocalFile(fileUrl, fileName);

    // If already downloaded and valid, return immediately
    if (await localFile.exists() && (await localFile.length()) > 0) {
      onProgress?.call(1.0);
      return localFile;
    }

    final cancelToken = CancelToken();
    final cacheKey = _getCacheKey(fileUrl, fileName);
    _activeDownloads[cacheKey] = cancelToken;

    final tempFilePath = '${localFile.path}.tmp';
    final tempFile = File(tempFilePath);

    try {
      await _dio.download(
        fileUrl,
        tempFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            onProgress?.call(progress);
          } else {
            // Indeterminate progress
            onProgress?.call(-1.0);
          }
        },
      );

      // Atomically move temp file to destination cache file
      if (await tempFile.exists()) {
        if (await localFile.exists()) {
          await localFile.delete();
        }
        await tempFile.rename(localFile.path);
      }

      _activeDownloads.remove(cacheKey);
      onProgress?.call(1.0);
      return localFile;
    } catch (e) {
      _activeDownloads.remove(cacheKey);
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      if (CancelToken.isCancel(e as DioException)) {
        debugPrint('[FileCacheService] Download cancelled for $fileName');
      } else {
        debugPrint('[FileCacheService] Error downloading $fileName: $e');
      }
      return null;
    }
  }

  /// Cancel an ongoing download
  void cancelDownload(String fileUrl, String fileName) {
    final cacheKey = _getCacheKey(fileUrl, fileName);
    _activeDownloads[cacheKey]?.cancel('User cancelled download');
    _activeDownloads.remove(cacheKey);
  }

  /// Open a locally cached file using native OS app chooser (WhatsApp model: ChatGPT, Drive, Word, etc.)
  Future<bool> openLocalFile(File file, [String? mimeType]) async {
    try {
      if (!await file.exists()) return false;
      final result = await OpenFilex.open(file.path, type: mimeType);
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('[FileCacheService] Error opening local file with OpenFilex: $e');
      try {
        final uri = Uri.file(file.path);
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        return false;
      }
    }
  }

  /// Convenience method: checks cache -> opens if present, else triggers on-demand download and opens.
  Future<bool> openOrDownloadFile(
    String fileUrl,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    final isCached = await isFileDownloaded(fileUrl, fileName);
    if (isCached) {
      final file = await getLocalFile(fileUrl, fileName);
      return await openLocalFile(file);
    }

    final downloadedFile = await downloadFile(fileUrl, fileName, onProgress: onProgress);
    if (downloadedFile != null) {
      return await openLocalFile(downloadedFile);
    }
    return false;
  }

  /// Open a file inside the Acadyk Universal In-App File Viewer.
  Future<void> openInUniversalViewer(
    BuildContext context, {
    required String fileUrl,
    required String fileName,
    int? fileSizeBytes,
    String? mimeType,
    String? uploadedBy,
    DateTime? uploadedAt,
  }) async {
    await FileViewerService.openFile(
      context,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      mimeType: mimeType,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt,
    );
  }
}
