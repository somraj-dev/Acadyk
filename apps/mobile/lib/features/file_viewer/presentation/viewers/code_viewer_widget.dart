import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// In-App Code & Development File Viewer with line numbers, copy, and search.
class CodeViewerWidget extends StatefulWidget {
  final String fileUrl;
  final String? localFilePath;
  final String fileName;

  const CodeViewerWidget({
    super.key,
    required this.fileUrl,
    this.localFilePath,
    required this.fileName,
  });

  @override
  State<CodeViewerWidget> createState() => _CodeViewerWidgetState();
}

class _CodeViewerWidgetState extends State<CodeViewerWidget> {
  String _codeContent = '';
  List<String> _lines = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearchOpen = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCode() async {
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
      if (mounted) {
        setState(() {
          _codeContent = text;
          _lines = text.split('\n');
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load text content: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _codeContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final gutterBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
    final gutterTextColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

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
              const Icon(Icons.code_off_rounded, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: textColor, fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bg,
      child: Column(
        children: [
          // Toolbar: Lines count, Copy, Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: gutterBg,
              border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
            ),
            child: Row(
              children: [
                Icon(Icons.code_rounded, size: 16, color: gutterTextColor),
                const SizedBox(width: 8),
                Text(
                  '${_lines.length} lines',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gutterTextColor),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isSearchOpen ? Icons.close : Icons.search_rounded, size: 18, color: gutterTextColor),
                  tooltip: _isSearchOpen ? 'Close Search' : 'Find in file',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    setState(() {
                      _isSearchOpen = !_isSearchOpen;
                      if (!_isSearchOpen) _searchQuery = '';
                    });
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  color: const Color(0xFF3B82F6),
                  tooltip: 'Copy all code',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: _copyAll,
                ),
              ],
            ),
          ),

          // Optional search bar
          if (_isSearchOpen)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: TextStyle(color: textColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search in file...',
                  hintStyle: TextStyle(color: gutterTextColor, fontSize: 13),
                  isDense: true,
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),

          // Scrollable code with line numbers
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectionArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line Numbers Gutter
                      Container(
                        color: gutterBg,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(_lines.length, (idx) {
                            return Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12.5,
                                color: gutterTextColor,
                                height: 1.5,
                              ),
                            );
                          }),
                        ),
                      ),

                      // Code Lines
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _lines.map((line) {
                            final isHighlighted = _searchQuery.isNotEmpty && line.toLowerCase().contains(_searchQuery);
                            return Container(
                              color: isHighlighted ? const Color(0xFFFDE047).withValues(alpha: 0.3) : Colors.transparent,
                              child: Text(
                                line.isEmpty ? ' ' : line,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                  color: _highlightLine(line, textColor),
                                  height: 1.5,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _highlightLine(String line, Color defaultColor) {
    final trimmed = line.trim();
    if (trimmed.startsWith('//') || trimmed.startsWith('#') || trimmed.startsWith('/*')) {
      return const Color(0xFF64748B); // Comments
    }
    if (trimmed.startsWith('import ') || trimmed.startsWith('from ') || trimmed.startsWith('package ') || trimmed.startsWith('export ')) {
      return const Color(0xFF8B5CF6); // Imports
    }
    return defaultColor;
  }
}
