import 'package:flutter/widgets.dart';
import 'in_app_web_view_other.dart'
    if (dart.library.js_interop) 'in_app_web_view_web.dart'
    if (dart.library.html) 'in_app_web_view_web.dart';

Widget getPlatformWebView({required String url, required String viewId}) {
  return buildInAppWebView(url: url, viewId: viewId);
}
