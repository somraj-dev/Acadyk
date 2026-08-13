import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:acadyk/app/app.dart';
import 'package:acadyk/common/providers/auth_provider.dart';
import 'package:acadyk/common/providers/profile_provider.dart';
import 'package:acadyk/common/providers/theme_provider.dart';

void main() {
  testWidgets('Acadyk App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: legacy_provider.MultiProvider(
          providers: [
            legacy_provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => ProfileProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const AcadykApp(),
        ),
      ),
    );
    expect(find.byType(AcadykApp), findsOneWidget);
  });
}
