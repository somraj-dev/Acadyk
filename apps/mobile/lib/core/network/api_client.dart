import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app/config/app_config.dart';
import '../auth/firebase_auth_service.dart';

class ApiClient {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Keep BaseOptions baseUrl in sync with AppConfig
          options.baseUrl = AppConfig.apiBaseUrl;

          // Obtain current Firebase ID token (with automatic refresh)
          String? token;
          try {
            token = await FirebaseAuthService.getIdToken();
          } catch (_) {}

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            // Unauthenticated/public requests must not attach invalid auth headers
            options.headers.remove('Authorization');
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          debugPrint('[ApiClient Error] ${error.response?.statusCode}: ${error.message}');
          // If 401 Unauthorized, force-refresh the Firebase ID token and retry the request once
          if (error.response?.statusCode == 401 && error.requestOptions.extra['retry_attempted'] != true) {
            try {
              final freshToken = await FirebaseAuthService.getIdToken(forceRefresh: true);
              if (freshToken != null && freshToken.isNotEmpty) {
                final retryOptions = error.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $freshToken';
                retryOptions.extra['retry_attempted'] = true;
                final response = await _dio.fetch(retryOptions);
                return handler.resolve(response);
              }
            } catch (_) {}
          }
          return handler.next(error);
        },
      ),
    );

  static Dio get instance => _dio;

  static Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  static Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  static Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters);
  }

  static Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters);
  }
}
