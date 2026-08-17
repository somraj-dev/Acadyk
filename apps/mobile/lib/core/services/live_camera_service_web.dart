// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'live_camera_service.dart';

class LiveCameraWebPlatform implements LiveCameraPlatform {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;

  @override
  Future<bool> requestCameraPermission() async {
    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      });

      if (stream != null) {
        // Permission was granted! Release test stream
        for (final track in stream.getTracks()) {
          track.stop();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[LiveCameraWeb] Camera permission request error: $e');
      return false;
    }
  }

  @override
  Future<Widget?> startCameraFeed(String uniqueId) async {
    try {
      stopCameraFeed();

      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      });

      if (stream == null) return null;
      _mediaStream = stream;

      final video = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.transform = 'scaleX(-1)' // Mirror for front selfie camera
        ..srcObject = stream;

      _videoElement = video;

      final viewType = 'web-cam-stream-$uniqueId';

      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int id) => video,
      );

      return HtmlElementView(viewType: viewType);
    } catch (e) {
      debugPrint('[LiveCameraWeb] startCameraFeed error: $e');
      return null;
    }
  }

  @override
  Future<Uint8List?> capturePhoto() async {
    try {
      if (_videoElement == null) return null;

      final int w = _videoElement!.videoWidth > 0 ? _videoElement!.videoWidth : 640;
      final int h = _videoElement!.videoHeight > 0 ? _videoElement!.videoHeight : 480;

      final canvas = html.CanvasElement(width: w, height: h);
      final ctx = canvas.context2D;

      // Mirror canvas to match the mirrored selfie video preview
      ctx.translate(w, 0);
      ctx.scale(-1, 1);
      ctx.drawImage(_videoElement!, 0, 0);

      final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);
      final commaIndex = dataUrl.indexOf(',');
      if (commaIndex != -1) {
        final base64String = dataUrl.substring(commaIndex + 1);
        return base64Decode(base64String);
      }
      return null;
    } catch (e) {
      debugPrint('[LiveCameraWeb] capturePhoto error: $e');
      return null;
    }
  }

  @override
  void stopCameraFeed() {
    try {
      if (_mediaStream != null) {
        for (final track in _mediaStream!.getTracks()) {
          track.stop();
        }
        _mediaStream = null;
      }
      if (_videoElement != null) {
        _videoElement!.pause();
        _videoElement!.srcObject = null;
        _videoElement = null;
      }
    } catch (e) {
      debugPrint('[LiveCameraWeb] stopCameraFeed error: $e');
    }
  }
}

LiveCameraPlatform getLiveCameraPlatform() => LiveCameraWebPlatform();
