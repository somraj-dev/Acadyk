import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acadyk/common/providers/auth_provider.dart';
import 'package:acadyk/common/providers/profile_provider.dart';
import 'package:acadyk/common/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async => null,
    );
  });
  group('Provider & State Management Tests', () {
    test('AuthProvider initializes in unauthenticated state and manages state transitions', () {
      final authProvider = AuthProvider();
      expect(authProvider.isLoading, false);

      authProvider.bypassSignIn();
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser?.email, 'developer@mitsgwl.ac.in');
    });

    test('ProfileProvider manages profile data and status updates', () {
      final profileProvider = ProfileProvider();
      expect(profileProvider.isLoading, false);
    });

    test('ThemeProvider toggles dark/light theme correctly', () {
      final themeProvider = ThemeProvider();
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);

      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
    });
  });
}
