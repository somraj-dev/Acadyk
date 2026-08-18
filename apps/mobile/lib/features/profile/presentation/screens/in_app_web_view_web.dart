// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredViews = <String>{};

Widget buildInAppWebView({required String url, required String viewId}) {
  if (!_registeredViews.contains(viewId)) {
    _registeredViews.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) {
        final iframe = html.IFrameElement()
          ..src = url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
  }

  return HtmlElementView(viewType: viewId);
}
