import 'dart:io';
import 'dart:typed_data';
import 'file_type.dart';

/// Robust multi-stage file type detector for Acadyk.
/// Priority order:
/// 1. Security Check (Flag dangerous executables)
/// 2. MIME Type matching
/// 3. File Extension matching
/// 4. Magic Bytes signature detection
class FileTypeDetector {
  static const Set<String> _executableExtensions = {
    'exe', 'apk', 'bat', 'cmd', 'sh', 'command', 'jar', 'msi', 'vbs', 'ps1', 'bin', 'deb', 'rpm'
  };

  static const Set<String> _imageExtensions = {
    'jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'svg', 'heic', 'heif', 'tiff', 'tif', 'ico', 'avif'
  };

  static const Set<String> _docxExtensions = {
    'doc', 'docx', 'dot', 'dotx', 'odt', 'rtf'
  };

  static const Set<String> _codeExtensions = {
    'dart', 'js', 'ts', 'tsx', 'jsx', 'py', 'java', 'kt', 'kts', 'cpp', 'c', 'h', 'hpp',
    'cs', 'go', 'rs', 'php', 'rb', 'swift', 'html', 'htm', 'css', 'scss', 'sass', 'sql'
  };

  static const Set<String> _csvExtensions = {
    'csv', 'tsv', 'xls', 'xlsx', 'xlsm', 'ods'
  };

  static const Set<String> _jsonExtensions = {
    'json', 'jsonl', 'geojson'
  };

  static const Set<String> _textExtensions = {
    'txt', 'md', 'markdown', 'xml', 'yaml', 'yml', 'toml', 'log', 'ini', 'env', 'conf'
  };

  static const Set<String> _archiveExtensions = {
    'zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz'
  };

  static const Set<String> _videoExtensions = {
    'mp4', 'mkv', 'mov', 'avi', 'webm', 'm4v', '3gp', 'mpeg', 'mpg'
  };

  static const Set<String> _audioExtensions = {
    'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', 'wma', 'opus'
  };

  /// Detect file type from filename, mimeType, and optional header bytes
  static AcadykFileType detect({
    required String fileName,
    String? mimeType,
    Uint8List? headerBytes,
  }) {
    final ext = _extractExtension(fileName);

    // 1. Security Check: Never treat executables as normal files
    if (_executableExtensions.contains(ext)) {
      return AcadykFileType.executable;
    }

    // 2. Explicit MIME Type inspection
    if (mimeType != null && mimeType.isNotEmpty) {
      final cleanMime = mimeType.toLowerCase().trim();
      if (cleanMime == 'application/pdf') return AcadykFileType.pdf;
      if (cleanMime.startsWith('image/')) return AcadykFileType.image;
      if (cleanMime.startsWith('video/')) return AcadykFileType.video;
      if (cleanMime.startsWith('audio/')) return AcadykFileType.audio;
      if (cleanMime == 'text/csv' || cleanMime == 'application/vnd.ms-excel') return AcadykFileType.csv;
      if (cleanMime == 'application/json' || cleanMime == 'text/json') return AcadykFileType.json;
      if (cleanMime.contains('wordprocessingml') || cleanMime == 'application/msword') return AcadykFileType.docx;
      if (cleanMime == 'application/zip' || cleanMime == 'application/x-zip-compressed' || cleanMime.contains('compressed')) {
        // If extension is docx/xlsx, prefer specific document type
        if (_docxExtensions.contains(ext)) return AcadykFileType.docx;
        if (_csvExtensions.contains(ext)) return AcadykFileType.csv;
        return AcadykFileType.archive;
      }
      if (cleanMime.startsWith('text/')) {
        if (_codeExtensions.contains(ext)) return AcadykFileType.code;
        return AcadykFileType.text;
      }
    }

    // 3. File Extension Matching
    if (ext == 'pdf') return AcadykFileType.pdf;
    if (_imageExtensions.contains(ext)) return AcadykFileType.image;
    if (_docxExtensions.contains(ext)) return AcadykFileType.docx;
    if (_codeExtensions.contains(ext)) return AcadykFileType.code;
    if (_csvExtensions.contains(ext)) return AcadykFileType.csv;
    if (_jsonExtensions.contains(ext)) return AcadykFileType.json;
    if (_textExtensions.contains(ext)) return AcadykFileType.text;
    if (_archiveExtensions.contains(ext)) return AcadykFileType.archive;
    if (_videoExtensions.contains(ext)) return AcadykFileType.video;
    if (_audioExtensions.contains(ext)) return AcadykFileType.audio;

    // 4. Magic Bytes signature fallback
    if (headerBytes != null && headerBytes.length >= 4) {
      // PDF: %PDF- (0x25, 0x50, 0x44, 0x46)
      if (headerBytes[0] == 0x25 && headerBytes[1] == 0x50 && headerBytes[2] == 0x44 && headerBytes[3] == 0x46) {
        return AcadykFileType.pdf;
      }
      // PNG: 0x89, 'P', 'N', 'G'
      if (headerBytes[0] == 0x89 && headerBytes[1] == 0x50 && headerBytes[2] == 0x4E && headerBytes[3] == 0x47) {
        return AcadykFileType.image;
      }
      // JPEG: 0xFF, 0xD8, 0xFF
      if (headerBytes[0] == 0xFF && headerBytes[1] == 0xD8 && headerBytes[2] == 0xFF) {
        return AcadykFileType.image;
      }
      // GIF: 'G', 'I', 'F', '8'
      if (headerBytes[0] == 0x47 && headerBytes[1] == 0x49 && headerBytes[2] == 0x46 && headerBytes[3] == 0x38) {
        return AcadykFileType.image;
      }
      // ZIP / DOCX: 'P', 'K', 0x03, 0x04
      if (headerBytes[0] == 0x50 && headerBytes[1] == 0x4B && headerBytes[2] == 0x03 && headerBytes[3] == 0x04) {
        if (_docxExtensions.contains(ext)) return AcadykFileType.docx;
        return AcadykFileType.archive;
      }
    }

    return AcadykFileType.unknown;
  }

  /// Detect file type from a local [File] handle
  static Future<AcadykFileType> detectFromFile(File file, {String? mimeType}) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    Uint8List? headerBytes;
    try {
      if (await file.exists()) {
        final raf = await file.open();
        headerBytes = await raf.read(16);
        await raf.close();
      }
    } catch (_) {}
    return detect(fileName: fileName, mimeType: mimeType, headerBytes: headerBytes);
  }

  static String _extractExtension(String fileName) {
    if (!fileName.contains('.')) return '';
    final clean = fileName.split('?').first.split('#').first;
    return clean.split('.').last.toLowerCase().trim();
  }
}
