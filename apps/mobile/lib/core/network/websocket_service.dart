import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../auth/firebase_auth_service.dart';

class WebSocketService {
  static const String _defaultWsUrl = 'ws://localhost:8080/ws';
  static WebSocketChannel? _channel;
  static bool _isConnected = false;
  static bool _isConnecting = false;
  static int _reconnectAttempts = 0;
  static Timer? _heartbeatTimer;
  static Timer? _reconnectTimer;

  static final StreamController<dynamic> _globalController = StreamController<dynamic>.broadcast();
  static final Map<String, List<Function(dynamic)>> _topicSubscriptions = {};
  static final List<Map<String, dynamic>> _offlineMessageQueue = [];

  static bool get isConnected => _isConnected;
  static Stream<dynamic> get stream => _globalController.stream;

  /// Connect to Spring Boot WebSocket STOMP endpoint
  static Future<void> connect([String? token]) async {
    if (_isConnected || _isConnecting) return;
    _isConnecting = true;

    try {
      final authToken = token ?? await FirebaseAuthService.getIdToken();
      final uri = Uri.parse(_defaultWsUrl);
      _channel = WebSocketChannel.connect(uri);

      // Send STOMP CONNECT frame
      _sendStompConnect(authToken);

      _channel?.stream.listen(
        _onMessageReceived,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _startHeartbeat();
      _flushOfflineQueue();

      // Re-establish active subscriptions
      for (final topic in _topicSubscriptions.keys) {
        _sendStompSubscribe(topic);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  static void _onMessageReceived(dynamic rawData) {
    final messageStr = rawData.toString();

    // Check for STOMP frame
    if (messageStr.startsWith('CONNECTED')) {
      _isConnected = true;
      debugPrint('[WebSocket] STOMP session connected.');
      return;
    }

    if (messageStr.startsWith('MESSAGE')) {
      try {
        final bodyIndex = messageStr.indexOf('\n\n');
        if (bodyIndex != -1) {
          final body = messageStr.substring(bodyIndex + 2).replaceAll('\x00', '').trim();
          final parsed = jsonDecode(body);
          _globalController.add(parsed);

          // Extract destination header if present
          final destHeader = _extractHeader(messageStr, 'destination');
          if (destHeader != null && _topicSubscriptions.containsKey(destHeader)) {
            for (final callback in _topicSubscriptions[destHeader]!) {
              callback(parsed);
            }
          }
        }
      } catch (e) {
        _globalController.add(messageStr);
      }
      return;
    }

    // Standard JSON message fallback
    try {
      final decoded = jsonDecode(messageStr);
      _globalController.add(decoded);
    } catch (_) {
      _globalController.add(messageStr);
    }
  }

  static String? _extractHeader(String frame, String headerName) {
    final lines = frame.split('\n');
    for (final line in lines) {
      if (line.startsWith('$headerName:')) {
        return line.substring(headerName.length + 1).trim();
      }
    }
    return null;
  }

  static void _sendStompConnect(String? authToken) {
    final headers = StringBuffer();
    headers.writeln('CONNECT');
    headers.writeln('accept-version:1.2,1.1,1.0');
    headers.writeln('heart-beat:10000,10000');
    if (authToken != null) {
      headers.writeln('Authorization:Bearer $authToken');
    }
    headers.writeln();
    headers.write('\x00');
    _channel?.sink.add(headers.toString());
  }

  static void _sendStompSubscribe(String destination) {
    final subFrame = StringBuffer();
    subFrame.writeln('SUBSCRIBE');
    subFrame.writeln('id:sub-${destination.hashCode}');
    subFrame.writeln('destination:$destination');
    subFrame.writeln();
    subFrame.write('\x00');
    _channel?.sink.add(subFrame.toString());
  }

  /// Subscribe to a specific conversation or notification topic
  static void subscribe(String destination, Function(dynamic) onData) {
    _topicSubscriptions.putIfAbsent(destination, () => []).add(onData);
    if (_isConnected) {
      _sendStompSubscribe(destination);
    }
  }

  /// Unsubscribe from topic
  static void unsubscribe(String destination) {
    _topicSubscriptions.remove(destination);
  }

  /// Send message over WebSocket / STOMP
  static void send(Map<String, dynamic> payload, {String destination = '/app/chat.send'}) {
    if (!_isConnected) {
      _offlineMessageQueue.add(payload);
      return;
    }

    final frame = StringBuffer();
    frame.writeln('SEND');
    frame.writeln('destination:$destination');
    frame.writeln('content-type:application/json');
    frame.writeln();
    frame.write(jsonEncode(payload));
    frame.write('\x00');

    try {
      _channel?.sink.add(frame.toString());
    } catch (_) {
      _offlineMessageQueue.add(payload);
    }
  }

  static void _flushOfflineQueue() {
    while (_offlineMessageQueue.isNotEmpty && _isConnected) {
      final msg = _offlineMessageQueue.removeAt(0);
      send(msg);
    }
  }

  static void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 15), (_) {
      if (_isConnected) {
        _channel?.sink.add('\n');
      }
    });
  }

  static void _handleError(dynamic error) {
    debugPrint('[WebSocket Error] $error');
    _scheduleReconnect();
  }

  static void _handleDone() {
    debugPrint('[WebSocket Done] Connection closed.');
    _scheduleReconnect();
  }

  /// Exponential backoff reconnection
  static void _scheduleReconnect() {
    _isConnected = false;
    _isConnecting = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    _reconnectAttempts++;
    final delaySeconds = min(pow(2, _reconnectAttempts).toInt(), 30);
    final safeDelay = (delaySeconds > 0 && !delaySeconds.isNaN) ? delaySeconds : 5;
    debugPrint('[WebSocket] Scheduling reconnection in $safeDelay seconds (attempt $_reconnectAttempts)');

    _reconnectTimer = Timer(Duration(seconds: safeDelay), () {
      connect();
    });
  }

  static void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _isConnected = false;
    _isConnecting = false;
    _channel?.sink.close();
  }
}
