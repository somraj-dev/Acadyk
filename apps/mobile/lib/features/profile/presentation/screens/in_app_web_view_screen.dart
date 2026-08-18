import 'package:flutter/material.dart';
import 'in_app_web_view_platform.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const InAppWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late final String _viewId;
  int _reloadKey = 0;

  @override
  void initState() {
    super.initState();
    _viewId = 'webview-${widget.url.hashCode}';
  }

  void _reload() {
    setState(() {
      _reloadKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: titleColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B), size: 22),
            tooltip: 'Reload',
            onPressed: _reload,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            color: Colors.white,
            child: KeyedSubtree(
              key: ValueKey('$_viewId-$_reloadKey'),
              child: getPlatformWebView(url: widget.url, viewId: '$_viewId-$_reloadKey'),
            ),
          ),
        ),
      ),
    );
  }
}
