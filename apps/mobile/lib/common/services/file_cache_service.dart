import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enum representing the download state of a file in the app (WhatsApp model).
enum FileDownloadState {
  notDownloaded,
  downloading,
  downloaded,
  failed,
}

/// Singleton service managing on-demand (lazy) file downloads and persistent user storage.
///
/// Follows the complete WhatsApp storage architecture:
/// 1. Files are NEVER automatically downloaded upon receiving or rendering in feed/chat.
/// 2. Files are downloaded ONLY when the user explicitly taps to view/download them.
/// 3. Downloaded files are saved directly into the user's permanent device storage in organized
///    WhatsApp-style categorized directories:
///      - Internal Storage / Download / Acadyk / Acadyk Documents/ (PDFs, DOC, XLS, PPT, TXT)
///      - Internal Storage / Download / Acadyk / Acadyk Images/    (JPG, PNG, WEBP, GIF)
///      - Internal Storage / Download / Acadyk / Acadyk Video/     (MP4, MKV, MOV)
///      - Internal Storage / Download / Acadyk / Acadyk Audio/     (MP3, WAV, M4A)
/// 4. Files appear immediately in the user's File Manager (Files by Google, Samsung My Files),
///    Downloads folder, and Media Gallery with clean, original file names!
/// 5. Subsequent taps reopen the stored file instantly with zero network consumption.
class FileCacheService {
  FileCacheService._internal();
  static final FileCacheService instance = FileCacheService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );

  /// Map of active cancel tokens for ongoing downloads
  final Map<String, CancelToken> _activeDownloads = {};

  /// Determine the WhatsApp-style category subfolder for a given file name.
  static String getCategorySubfolder(String fileName) {
    final clean = fileName.toLowerCase().split('?').first;
    final ext = clean.contains('.') ? clean.split('.').last : '';
    switch (ext) {
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
      case 'txt':
      case 'csv':
      case 'json':
      case 'zip':
      case 'rar':
      case '7z':
      case 'epub':
        return 'Acadyk Documents';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'svg':
      case 'gif':
      case 'bmp':
        return 'Acadyk Images';
      case 'mp4':
      case 'mkv':
      case 'mov':
      case 'avi':
      case 'webm':
        return 'Acadyk Video';
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'aac':
      case 'ogg':
      case 'flac':
        return 'Acadyk Audio';
      default:
        return 'Acadyk Documents';
    }
  }

  /// Get or create the root storage directory for Acadyk media (WhatsApp architecture).
  ///
  /// On Android:
  /// Primary: `/storage/emulated/0/Download/Acadyk/$category` (visible in Files by Google, Downloads, File Manager)
  /// Secondary: `getDownloadsDirectory()/Acadyk/$category`
  /// Tertiary: `getExternalStorageDirectory()/Acadyk/$category`
  ///
  /// On iOS:
  /// `getApplicationDocumentsDirectory()/Acadyk/$category` (visible in Apple Files app via UIFileSharingEnabled)
  Future<Directory> getAcadykStorageDirectory(String category) async {
    if (!kIsWeb && Platform.isAndroid) {
      // 1. Android Public Download directory: universally visible in all File Managers & Files by Google
      final publicDownload = Directory('/storage/emulated/0/Download/Acadyk/$category');
      try {
        if (!await publicDownload.exists()) {
          await publicDownload.create(recursive: true);
        }
        return publicDownload;
      } catch (e) {
        debugPrint('[FileCacheService] Public download path not directly writable: $e');
      }

      // 2. path_provider getDownloadsDirectory
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final dir = Directory('${downloadsDir.path}/Acadyk/$category');
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          return dir;
        }
      } catch (_) {}

      // 3. path_provider getExternalStorageDirectory
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final dir = Directory('${extDir.path}/Acadyk/$category');
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          return dir;
        }
      } catch (_) {}
    }

    // 4. iOS / Desktop / Fallback
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${docDir.path}/Acadyk/$category');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (_) {}

    // 5. Ultimate Fallback to temp dir
    final tempDir = Directory.systemTemp;
    final dir = Directory('${tempDir.path}/Acadyk/$category');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Clean, sanitized original file name for user storage (e.g. "Lecture_Notes_Unit1.pdf")
  String _getSanitizedFileName(String fileName, String fileUrl) {
    var clean = fileName.replaceAll(RegExp(r'[/\\?%*:|"<>]+'), '_').trim();
    if (clean.isEmpty) {
      final urlHash = fileUrl.hashCode.abs().toRadixString(36);
      clean = 'acadyk_file_$urlHash';
    }
    return clean;
  }

  /// Check if a file already exists in the user's storage.
  Future<bool> isFileDownloaded(String fileUrl, String fileName) async {
    if (kIsWeb) return false;
    if (fileUrl.isEmpty) return false;
    try {
      final file = await getLocalFile(fileUrl, fileName);
      if (await file.exists() && (await file.length()) > 0) {
        return true;
      }
      // Check legacy temp cache for backwards compatibility
      final legacyFile = await _getLegacyCacheFile(fileUrl, fileName);
      if (await legacyFile.exists() && (await legacyFile.length()) > 0) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Legacy sandbox cache file handle for backward migration
  Future<File> _getLegacyCacheFile(String fileUrl, String fileName) async {
    final tempDir = Directory.systemTemp;
    final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final urlHash = fileUrl.hashCode.abs().toRadixString(36);
    return File('${tempDir.path}/acadyk_media_cache/${urlHash}_$sanitizedName');
  }

  /// Get the [File] handle in the user's permanent Acadyk storage directory.
  Future<File> getLocalFile(String fileUrl, String fileName) async {
    final category = getCategorySubfolder(fileName);
    final dir = await getAcadykStorageDirectory(category);
    final cleanName = _getSanitizedFileName(fileName, fileUrl);
    return File('${dir.path}/$cleanName');
  }

  /// Download a file on-demand into the user's storage (WhatsApp architecture).
  ///
  /// Returns the saved [File] on success, or `null` if cancelled or failed.
  Future<File?> downloadFile(
    String fileUrl,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    if (fileUrl.isEmpty) return null;

    final targetFile = await getLocalFile(fileUrl, fileName);

    // 1. Data URI (base64) handling
    if (fileUrl.startsWith('data:') && fileUrl.contains(';base64,')) {
      try {
        final base64Str = fileUrl.split(';base64,').last;
        final bytes = base64Decode(base64Str);
        if (!await targetFile.parent.exists()) {
          await targetFile.parent.create(recursive: true);
        }
        await targetFile.writeAsBytes(bytes);
        onProgress?.call(1.0);
        return targetFile;
      } catch (e) {
        debugPrint('[FileCacheService] Error decoding data URI: $e');
        return null;
      }
    }

    // 2. Web fallback: open directly
    if (kIsWeb) {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return null;
    }

    // 3. If already stored in user's Acadyk directory, return immediately
    if (await targetFile.exists() && (await targetFile.length()) > 0) {
      onProgress?.call(1.0);
      return targetFile;
    }

    // 4. If present in legacy temp cache, migrate to user's storage
    final legacyFile = await _getLegacyCacheFile(fileUrl, fileName);
    if (await legacyFile.exists() && (await legacyFile.length()) > 0) {
      try {
        if (!await targetFile.parent.exists()) {
          await targetFile.parent.create(recursive: true);
        }
        await legacyFile.copy(targetFile.path);
        onProgress?.call(1.0);
        return targetFile;
      } catch (_) {}
    }

    // 5. Download directly into the user's storage folder
    final cancelToken = CancelToken();
    _activeDownloads[fileUrl] = cancelToken;

    final tempFilePath = '${targetFile.path}.download';
    final tempFile = File(tempFilePath);

    try {
      if (!await targetFile.parent.exists()) {
        await targetFile.parent.create(recursive: true);
      }

      await _dio.download(
        fileUrl,
        tempFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            onProgress?.call(progress);
          } else {
            onProgress?.call(-1.0);
          }
        },
      );

      // Atomically rename temp file to permanent user storage file
      if (await tempFile.exists()) {
        if (await targetFile.exists()) {
          await targetFile.delete();
        }
        await tempFile.rename(targetFile.path);
      }

      _activeDownloads.remove(fileUrl);
      onProgress?.call(1.0);
      return targetFile;
    } catch (e) {
      _activeDownloads.remove(fileUrl);
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
    _activeDownloads[fileUrl]?.cancel('User cancelled download');
    _activeDownloads.remove(fileUrl);
  }

  /// Open a locally stored file using native OS app chooser (WhatsApp model: ChatGPT, Drive, Word, etc.)
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

  /// Convenience method: checks storage -> opens if present, else triggers on-demand download and opens.
  Future<bool> openOrDownloadFile(
    String fileUrl,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    final isCached = await isFileDownloaded(fileUrl, fileName);
    if (isCached) {
      final file = await getLocalFile(fileUrl, fileName);
      return await openLocalFile(file);
    } else {
      final file = await downloadFile(fileUrl, fileName, onProgress: onProgress);
      if (file != null) {
        return await openLocalFile(file);
      }
      return false;
    }
  }

  /// List all files saved in a specific Acadyk media category in user storage.
  Future<List<FileSystemEntity>> listCategoryFiles(String category) async {
    try {
      final dir = await getAcadykStorageDirectory(category);
      if (await dir.exists()) {
        return dir.listSync();
      }
    } catch (_) {}
    return [];
  }
}
