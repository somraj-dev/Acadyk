import 'package:flutter/foundation.dart';
import 'environment.dart';

class AppConfig {
  static const String appName = 'Acadyk';
  static const String appVersion = '1.0.0';

  // Active Environment configured via --dart-define=APP_ENV=production|staging|development
  static const String _envName = String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static final Environment currentEnvironment = Environment.fromString(_envName);

  // Development endpoints (auto-adapts for Android emulator loopback vs web/localhost)
  static String get _devApiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }
    return 'http://35.154.243.7:8080/api/v1';
  }

  static String get _devWsBaseUrl {
    if (kIsWeb) {
      return 'ws://localhost:8080/ws';
    }
    return 'ws://35.154.243.7:8080/ws';
  }

  // Staging endpoints (HTTPS/WSS)
  static const String _stagingApiBaseUrl = 'https://staging.acadyk.com/api/v1';
  static const String _stagingWsBaseUrl = 'wss://staging.acadyk.com/ws';

  // Production endpoints (HTTPS/WSS)
  static const String _prodApiBaseUrl = 'http://35.154.243.7:8080/api/v1';
  static const String _prodWsBaseUrl = 'ws://35.154.243.7:8080/ws';

  /// Centralized API Base URL.
  /// Overridable at compile-time/run-time via --dart-define=API_BASE_URL=... without source-code changes.
  static String get apiBaseUrl {
    const overrideUrl = String.fromEnvironment('API_BASE_URL');
    if (overrideUrl.isNotEmpty) {
      return overrideUrl;
    }
    switch (currentEnvironment) {
      case Environment.production:
        return _prodApiBaseUrl;
      case Environment.staging:
        return _stagingApiBaseUrl;
      case Environment.development:
      default:
        return _devApiBaseUrl;
    }
  }

  /// Centralized WebSocket STOMP Base URL.
  /// Overridable at compile-time/run-time via --dart-define=WS_BASE_URL=... without source-code changes.
  static String get wsBaseUrl {
    const overrideUrl = String.fromEnvironment('WS_BASE_URL');
    if (overrideUrl.isNotEmpty) {
      return overrideUrl;
    }
    switch (currentEnvironment) {
      case Environment.production:
        return _prodWsBaseUrl;
      case Environment.staging:
        return _stagingWsBaseUrl;
      case Environment.development:
      default:
        return _devWsBaseUrl;
    }
  }

  static bool get isProduction => currentEnvironment == Environment.production;
  static bool get isDevelopment => currentEnvironment == Environment.development;
}
