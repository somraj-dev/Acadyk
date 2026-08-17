import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'live_camera_service.dart';

class LiveCameraMobilePlatform implements LiveCameraPlatform {
  CameraController? _controller;

  @override
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    } catch (e) {
      debugPrint('[LiveCameraMobile] Permission error: $e');
      return false;
    }
  }

  @override
  Future<Widget?> startCameraFeed(String uniqueId) async {
    try {
      stopCameraFeed();

      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      _controller = controller;

      return ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.previewSize?.height ?? 240,
              height: controller.value.previewSize?.width ?? 280,
              child: CameraPreview(controller),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('[LiveCameraMobile] startCameraFeed error: $e');
      return null;
    }
  }

  @override
  Future<Uint8List?> capturePhoto() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return null;
      final file = await _controller!.takePicture();
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('[LiveCameraMobile] capturePhoto error: $e');
      return null;
    }
  }

  @override
  void stopCameraFeed() {
    try {
      _controller?.dispose();
      _controller = null;
    } catch (e) {
      debugPrint('[LiveCameraMobile] stopCameraFeed error: $e');
    }
  }
}

LiveCameraPlatform getLiveCameraPlatform() => LiveCameraMobilePlatform();
