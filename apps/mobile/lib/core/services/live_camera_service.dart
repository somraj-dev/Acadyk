import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'live_camera_service_stub.dart'
    if (dart.library.html) 'live_camera_service_web.dart'
    if (dart.library.io) 'live_camera_service_mobile.dart';

abstract class LiveCameraPlatform {
  Future<bool> requestCameraPermission();
  Future<Widget?> startCameraFeed(String uniqueId);
  Future<Uint8List?> capturePhoto();
  void stopCameraFeed();
}

class LiveCameraService {
  static final LiveCameraPlatform _platform = getLiveCameraPlatform();

  /// Requests real camera permission (triggers browser prompt on Web, system dialog on Mobile)
  static Future<bool> requestCameraPermission() => _platform.requestCameraPermission();

  /// Starts the live camera feed and returns the interactive camera preview widget
  static Future<Widget?> startCameraFeed(String uniqueId) => _platform.startCameraFeed(uniqueId);

  /// Captures a live picture directly from the active camera stream
  static Future<Uint8List?> capturePhoto() => _platform.capturePhoto();

  /// Stops camera stream and releases camera hardware
  static void stopCameraFeed() => _platform.stopCameraFeed();
}
