import 'package:flutter_test/flutter_test.dart';
import 'package:acadyk/main.dart';

void main() {
  testWidgets('Acadyk Login Screen Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AcadykApp());

    // Verify that our branding and action triggers are present.
    expect(find.text('Acad'), findsOneWidget);
    expect(find.text('YK'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign in with Email'), findsOneWidget);
  });
}
