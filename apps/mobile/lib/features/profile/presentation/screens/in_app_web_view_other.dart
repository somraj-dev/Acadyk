import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildInAppWebView({required String url, required String viewId}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.language, size: 48, color: Color(0xFF2563EB)),
          const SizedBox(height: 16),
          Text(
            url,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Open in App Browser'),
          ),
        ],
      ),
    ),
  );
}
