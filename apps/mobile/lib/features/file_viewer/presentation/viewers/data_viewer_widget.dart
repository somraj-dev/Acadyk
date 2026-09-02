import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// In-App Data Viewer for CSV tables, formatted JSON, and Markdown/Plain Text files.
class DataViewerWidget extends StatefulWidget {
  final String fileUrl;
  final String? localFilePath;
  final String fileName;
  final bool isCsv;
  final bool isJson;

  const DataViewerWidget({
    super.key,
    required this.fileUrl,
    this.localFilePath,
    required this.fileName,
    this.isCsv = false,
    this.isJson = false,
  });

  @override
  State<DataViewerWidget> createState() => _DataViewerWidgetState();
}

class _DataViewerWidgetState extends State<DataViewerWidget> {
  String _rawText = '';
  List<List<String>> _csvRows = [];
  String _formattedJson = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      String text = '';
      if (!kIsWeb && widget.localFilePath != null && await File(widget.localFilePath!).exists()) {
        text = await File(widget.localFilePath!).readAsString();
      } else {
        final res = await Dio().get<String>(
          widget.fileUrl,
          options: Options(responseType: ResponseType.plain),
        );
        text = res.data ?? '';
      }

      _rawText = text;

      if (widget.isCsv) {
        _csvRows = _parseCsv(text);
      } else if (widget.isJson) {
        try {
          final decoded = jsonDecode(text);
          _formattedJson = const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (_) {
          _formattedJson = text;
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to parse file: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<List<String>> _parseCsv(String text) {
    final lines = text.split('\n');
    final rows = <List<String>>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      // Simple robust CSV line splitter honoring commas and quotes
      final cells = <String>[];
      final buffer = StringBuffer();
      bool inQuotes = false;
      for (int i = 0; i < trimmed.length; i++) {
        final char = trimmed[i];
        if (char == '"') {
          inQuotes = !inQuotes;
        } else if (char == ',' && !inQuotes) {
          cells.add(buffer.toString().trim());
          buffer.clear();
        } else {
          buffer.write(char);
        }
      }
      cells.add(buffer.toString().trim());
      rows.add(cells);
    }
    return rows;
  }

  void _copyContent() {
    Clipboard.setData(ClipboardData(text: _formattedJson.isNotEmpty ? _formattedJson : _rawText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.table_chart_outlined, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: textPrimary, fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    Widget content;
    if (widget.isCsv && _csvRows.isNotEmpty) {
      content = _buildCsvGrid(isDark);
    } else if (widget.isJson) {
      content = _buildJsonView(isDark);
    } else {
      content = _buildTextReader(isDark);
    }

    return Container(color: bg, child: content);
  }

  Widget _buildCsvGrid(bool isDark) {
    final headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: borderColor, width: 1),
            children: List.generate(_csvRows.length, (rowIdx) {
              final row = _csvRows[rowIdx];
              final isHeader = rowIdx == 0;
              return TableRow(
                decoration: BoxDecoration(color: isHeader ? headerBg : Colors.transparent),
                children: row.map((cell) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      cell,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                        color: textColor,
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildJsonView(bool isDark) {
    final codeBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    return Container(
      color: codeBg,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            child: Row(
              children: [
                const Icon(Icons.data_object_rounded, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                const Text('Formatted JSON', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF3B82F6)),
                  onPressed: _copyContent,
                  tooltip: 'Copy JSON',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectionArea(
                child: Text(
                  _formattedJson,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextReader(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: SelectionArea(
        child: Text(
          _rawText,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}
