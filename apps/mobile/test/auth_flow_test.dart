import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:acadyk/common/services/auth_service.dart';
import 'package:acadyk/core/auth/firebase_auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<String, String> mockStorage = {};

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'), (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'write':
          final key = methodCall.arguments['key'] as String;
          final value = methodCall.arguments['value'] as String;
          mockStorage[key] = value;
          return null;
        case 'read':
          final key = methodCall.arguments['key'] as String;
          return mockStorage[key];
        case 'delete':
          final key = methodCall.arguments['key'] as String;
          mockStorage.remove(key);
          return null;
        case 'deleteAll':
          mockStorage.clear();
          return null;
        case 'readAll':
          return mockStorage;
        default:
          return null;
      }
    });
  });

  group('Production Authentication Flow Tests', () {
    test('Email / Password Sign-Up flow provisioning', () async {
      final user = await AuthService.signUpWithEmail(
        'newuser@acadyk.com',
        'SecurePassword123!',
        fullName: 'Jane Doe',
      );

      expect(user, isNotNull);
      expect(user!.email, equals('newuser@acadyk.com'));
      expect(user.fullName, equals('Jane Doe'));
      expect(AuthService.isAuthenticated, isTrue);
    });

    test('Email / Password Sign-In flow', () async {
      final user = await AuthService.signInWithEmail(
        'developer@acadyk.com',
        'Password123!',
      );

      expect(user, isNotNull);
      expect(user!.email, equals('developer@acadyk.com'));
      expect(AuthService.isAuthenticated, isTrue);
    });

    test('Session token retrieval', () async {
      final token = await FirebaseAuthService.getIdToken();
      expect(token, isNotNull);
    });

    test('Sign Out and Session clearance', () async {
      await AuthService.signOut();
      expect(AuthService.isAuthenticated, isFalse);
      expect(AuthService.currentUser, isNull);
    });
  });
}
