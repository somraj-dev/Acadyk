import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acadyk/shared/widgets/skeleton/skeleton.dart';

void main() {
  group('Skeleton Loading Widgets Tests', () {
    testWidgets('AppShimmer and primitive skeleton components render properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppShimmer(
              child: Column(
                children: [
                  SkeletonCircle(size: 40),
                  SkeletonLine(width: 100, height: 14),
                  SkeletonContainer(width: 200, height: 50),
                  SkeletonCard(width: 200, height: 100),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppShimmer), findsOneWidget);
      expect(find.byType(SkeletonCircle), findsOneWidget);
      expect(find.byType(SkeletonLine), findsOneWidget);
      expect(find.byType(SkeletonContainer), findsWidgets);
      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('FeedSkeleton renders post placeholders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedSkeleton(itemCount: 2),
          ),
        ),
      );

      expect(find.byType(FeedSkeleton), findsOneWidget);
      expect(find.byType(SkeletonCircle), findsWidgets);
      expect(find.byType(SkeletonLine), findsWidgets);
    });

    testWidgets('NotificationSkeleton renders notification placeholders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationSkeleton(itemCount: 3),
          ),
        ),
      );

      expect(find.byType(NotificationSkeleton), findsOneWidget);
      expect(find.byType(SkeletonCircle), findsWidgets);
    });

    testWidgets('MessageSkeleton renders conversation placeholders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageSkeleton(itemCount: 3),
          ),
        ),
      );

      expect(find.byType(MessageSkeleton), findsOneWidget);
      expect(find.byType(SkeletonCircle), findsWidgets);
    });

    testWidgets('ChatSkeleton renders alternating message bubbles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatSkeleton(itemCount: 4),
          ),
        ),
      );

      expect(find.byType(ChatSkeleton), findsOneWidget);
      expect(find.byType(SkeletonLine), findsWidgets);
    });

    testWidgets('ProfileSkeleton renders cover, avatar, and cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileSkeleton(),
          ),
        ),
      );

      expect(find.byType(ProfileSkeleton), findsOneWidget);
      expect(find.byType(SkeletonCircle), findsWidgets);
    });

    testWidgets('SettingsListSkeleton renders section and switch placeholders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsListSkeleton(sectionCount: 2),
          ),
        ),
      );

      expect(find.byType(SettingsListSkeleton), findsOneWidget);
      expect(find.byType(SkeletonCircle), findsWidgets);
    });
  });
}
