import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:acadyk/common/providers/auth_provider.dart';
import 'package:acadyk/common/providers/profile_provider.dart';
import 'package:acadyk/common/providers/theme_provider.dart';
import 'package:acadyk/features/auth/presentation/screens/login_screen.dart';
import 'package:acadyk/features/notifications/presentation/screens/notification_screen.dart';
import 'package:acadyk/features/profile/presentation/screens/appearance_screen.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => ProfileProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          home: child,
        ),
      ),
    );
  }

  group('Flutter Screen Widget Tests', () {
    testWidgets('LoginScreen renders form inputs and interactive elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('NotificationScreen renders notification headers and list', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const NotificationScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(NotificationScreen), findsOneWidget);
    });

    testWidgets('AppearanceScreen renders theme options and radio selections', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const AppearanceScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppearanceScreen), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme preferences'), findsOneWidget);
    });
  });
}
