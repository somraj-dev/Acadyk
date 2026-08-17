import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'live_camera_service.dart';

class LiveCameraStubPlatform implements LiveCameraPlatform {
  @override
  Future<bool> requestCameraPermission() async => true;

  @override
  Future<Widget?> startCameraFeed(String uniqueId) async => null;

  @override
  Future<Uint8List?> capturePhoto() async => null;

  @override
  void stopCameraFeed() {}
}

LiveCameraPlatform getLiveCameraPlatform() => LiveCameraStubPlatform();
