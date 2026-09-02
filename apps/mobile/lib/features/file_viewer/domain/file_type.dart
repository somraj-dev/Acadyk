import 'package:flutter/material.dart';

/// Categories of files recognized by the Acadyk Universal File Viewer.
enum AcadykFileType {
  pdf,
  image,
  docx,
  code,
  csv,
  json,
  text,
  archive,
  video,
  audio,
  executable,
  unknown,
}

extension AcadykFileTypeExtension on AcadykFileType {
  /// User-facing display title for the file type category
  String get displayName {
    switch (this) {
      case AcadykFileType.pdf:
        return 'PDF Document';
      case AcadykFileType.image:
        return 'Image File';
      case AcadykFileType.docx:
        return 'Word Document';
      case AcadykFileType.code:
        return 'Source Code';
      case AcadykFileType.csv:
        return 'Spreadsheet Data';
      case AcadykFileType.json:
        return 'JSON Data';
      case AcadykFileType.text:
        return 'Text Document';
      case AcadykFileType.archive:
        return 'Archive File';
      case AcadykFileType.video:
        return 'Video File';
      case AcadykFileType.audio:
        return 'Audio Recording';
      case AcadykFileType.executable:
        return 'Executable Program';
      case AcadykFileType.unknown:
        return 'Generic File';
    }
  }

  /// Category icon representation
  IconData get icon {
    switch (this) {
      case AcadykFileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case AcadykFileType.image:
        return Icons.image_rounded;
      case AcadykFileType.docx:
        return Icons.article_rounded;
      case AcadykFileType.code:
        return Icons.code_rounded;
      case AcadykFileType.csv:
        return Icons.table_chart_rounded;
      case AcadykFileType.json:
        return Icons.data_object_rounded;
      case AcadykFileType.text:
        return Icons.description_rounded;
      case AcadykFileType.archive:
        return Icons.folder_zip_rounded;
      case AcadykFileType.video:
        return Icons.movie_rounded;
      case AcadykFileType.audio:
        return Icons.audiotrack_rounded;
      case AcadykFileType.executable:
        return Icons.warning_amber_rounded;
      case AcadykFileType.unknown:
        return Icons.insert_drive_file_rounded;
    }
  }

  /// Theme accent color for viewer headers and badges
  Color get accentColor {
    switch (this) {
      case AcadykFileType.pdf:
        return const Color(0xFFE11D48); // Rose / Red
      case AcadykFileType.image:
        return const Color(0xFF8B5CF6); // Purple
      case AcadykFileType.docx:
        return const Color(0xFF2563EB); // Blue
      case AcadykFileType.code:
        return const Color(0xFF059669); // Emerald
      case AcadykFileType.csv:
        return const Color(0xFF10B981); // Green
      case AcadykFileType.json:
        return const Color(0xFFD97706); // Amber
      case AcadykFileType.text:
        return const Color(0xFF475569); // Slate
      case AcadykFileType.archive:
        return const Color(0xFFEA580C); // Orange
      case AcadykFileType.video:
        return const Color(0xFF0284C7); // Cyan / Blue
      case AcadykFileType.audio:
        return const Color(0xFFEC4899); // Pink
      case AcadykFileType.executable:
        return const Color(0xFFDC2626); // Alert Red
      case AcadykFileType.unknown:
        return const Color(0xFF64748B); // Slate
    }
  }

  /// Whether this file type is safe to execute or preview in-app
  bool get isExecutable => this == AcadykFileType.executable;
}
