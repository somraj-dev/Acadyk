import 'file_type.dart';

/// Metadata associated with a file opened in the Acadyk Universal File Viewer.
class FileViewerMetadata {
  final String fileName;
  final int fileSizeBytes;
  final String? mimeType;
  final String fileUrl;
  final String? localPath;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final bool isDownloaded;
  final AcadykFileType fileType;

  const FileViewerMetadata({
    required this.fileName,
    required this.fileSizeBytes,
    this.mimeType,
    required this.fileUrl,
    this.localPath,
    this.uploadedBy,
    this.uploadedAt,
    this.isDownloaded = false,
    required this.fileType,
  });

  /// Extension of the file in uppercase without dot (e.g., 'PDF')
  String get extensionUpper {
    if (!fileName.contains('.')) return 'FILE';
    return fileName.split('.').last.toUpperCase();
  }

  /// Human-readable file size (e.g., '4.2 MB', '850 KB')
  String get formattedSize {
    if (fileSizeBytes <= 0) return '0 B';
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Human-readable upload date string
  String get formattedDate {
    if (uploadedAt == null) return 'Recent';
    final dt = uploadedAt!;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
