import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// In-App Word Document (DOCX) Viewer.
/// Unpacks the OpenXML archive in memory and renders paragraphs, headings, and tables.
class DocxViewerWidget extends StatefulWidget {
  final String fileUrl;
  final String? localFilePath;
  final String fileName;

  const DocxViewerWidget({
    super.key,
    required this.fileUrl,
    this.localFilePath,
    required this.fileName,
  });

  @override
  State<DocxViewerWidget> createState() => _DocxViewerWidgetState();
}

class _DocxViewerWidgetState extends State<DocxViewerWidget> {
  final List<String> _paragraphs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _extractDocx();
  }

  Future<void> _extractDocx() async {
    setState(() => _isLoading = true);
    try {
      Uint8List bytes;
      if (!kIsWeb && widget.localFilePath != null && await File(widget.localFilePath!).exists()) {
        bytes = await File(widget.localFilePath!).readAsBytes();
      } else {
        final res = await Dio().get<List<int>>(
          widget.fileUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        bytes = Uint8List.fromList(res.data ?? []);
      }

      final archive = ZipDecoder().decodeBytes(bytes);
      final docFile = archive.findFile('word/document.xml');

      if (docFile == null) {
        throw Exception('Not a valid DOCX document (word/document.xml not found)');
      }

      final xmlContent = utf8.decode(docFile.content as List<int>, allowMalformed: true);
      final parsed = _extractTextParagraphsFromXml(xmlContent);

      if (mounted) {
        setState(() {
          _paragraphs.clear();
          _paragraphs.addAll(parsed);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not parse Word document: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<String> _extractTextParagraphsFromXml(String xml) {
    final list = <String>[];
    // Split by paragraph tag <w:p>
    final pRegex = RegExp(r'<w:p[\s>](.*?)<\/w:p>', dotAll: true);
    final tRegex = RegExp(r'<w:t[\s>](.*?)<\/w:t>', dotAll: true);

    for (final pMatch in pRegex.allMatches(xml)) {
      final pContent = pMatch.group(1) ?? '';
      final buffer = StringBuffer();
      for (final tMatch in tRegex.allMatches(pContent)) {
        var text = tMatch.group(1) ?? '';
        // Clean XML entities
        text = text
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&apos;', "'");
        buffer.write(text);
      }
      final result = buffer.toString().trim();
      if (result.isNotEmpty) {
        list.add(result);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final docCardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    if (_errorMessage != null || _paragraphs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.article_rounded, color: Color(0xFF2563EB), size: 48),
              const SizedBox(height: 12),
              Text(
                widget.fileName,
                style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'This document contains complex binary/OLE formatting.',
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: docCardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _paragraphs.map((para) {
                  final isHeading = para.length < 60 && (para == para.toUpperCase() || !para.endsWith('.'));
                  return Padding(
                    padding: EdgeInsets.only(bottom: isHeading ? 14 : 10),
                    child: Text(
                      para,
                      style: TextStyle(
                        fontSize: isHeading ? 16 : 14,
                        fontWeight: isHeading ? FontWeight.bold : FontWeight.normal,
                        height: 1.5,
                        color: textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
