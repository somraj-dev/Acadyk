import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Specialized In-App PDF Viewer for Acadyk.
/// Features virtual page rendering, zoom/pinch, page counter, and full-screen controls.
class PdfViewerWidget extends StatefulWidget {
  final String fileUrl;
  final String? localFilePath;
  final String fileName;

  const PdfViewerWidget({
    super.key,
    required this.fileUrl,
    this.localFilePath,
    required this.fileName,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  final PdfViewerController _controller = PdfViewerController();
  int _currentPage = 1;
  int _pageCount = 0;
  bool _isReady = false;
  String? _errorMessage;

  @override
  void dispose() {
    super.dispose();
  }

  void _onDocumentLoaded(PdfDocument? document) {
    if (document != null && mounted) {
      setState(() {
        _pageCount = document.pages.length;
        _isReady = true;
      });
    }
  }

  void _onPageChanged(int? page) {
    if (page != null && page != _currentPage && mounted) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 12),
              Text(
                'Unable to render PDF',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Determine data source: local file if available on native, URI if on web
    final hasLocal = !kIsWeb && widget.localFilePath != null && File(widget.localFilePath!).existsSync();

    return Container(
      color: bg,
      child: Stack(
        children: [
          hasLocal
              ? PdfViewer.file(
                  widget.localFilePath!,
                  controller: _controller,
                  params: PdfViewerParams(
                    backgroundColor: bg,
                    onDocumentChanged: _onDocumentLoaded,
                    onViewerReady: (document, controller) {
                      _onDocumentLoaded(document);
                    },
                    onPageChanged: _onPageChanged,
                  ),
                )
              : PdfViewer.uri(
                  Uri.parse(widget.fileUrl),
                  controller: _controller,
                  params: PdfViewerParams(
                    backgroundColor: bg,
                    onDocumentChanged: _onDocumentLoaded,
                    onViewerReady: (document, controller) {
                      _onDocumentLoaded(document);
                    },
                    onPageChanged: _onPageChanged,
                  ),
                ),

          // Floating bottom controls: Page indicator & Zoom helpers
          if (_isReady && _pageCount > 0)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: _currentPage > 1
                            ? () => _controller.goToPage(pageNumber: _currentPage - 1)
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_currentPage / $_pageCount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: _currentPage < _pageCount
                            ? () => _controller.goToPage(pageNumber: _currentPage + 1)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Container(height: 16, width: 1, color: isDark ? Colors.white24 : Colors.black12),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.zoom_in_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () {
                          _controller.zoomUp();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.zoom_out_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () {
                          _controller.zoomDown();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
