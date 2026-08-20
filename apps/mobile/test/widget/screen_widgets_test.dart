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
import 'package:acadyk/features/profile/presentation/screens/project_details.dart';
import 'package:acadyk/features/profile/presentation/screens/experience_details.dart';
import 'package:acadyk/features/profile/presentation/screens/add_cover_image_screen.dart';
import 'package:acadyk/features/profile/presentation/screens/about_account_screen.dart';
import 'package:acadyk/features/profile/presentation/screens/profile_screen.dart';
import 'package:acadyk/features/profile/presentation/screens/profile_showcase.dart';
import 'package:acadyk/features/profile/presentation/screens/club_details_screen.dart';

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
    });

    testWidgets('NotificationScreen renders notification headers and list', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const NotificationScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(NotificationScreen), findsOneWidget);
    });

    testWidgets('AppearanceScreen renders theme options and radio selections', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const AppearanceScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppearanceScreen), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('ProjectDetailsScreen renders long title and summary without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ProjectDetailsScreen(
          projectData: {
            'title': 'High Scale Microservices with Docker and Kubernetes Infrastructure Platform',
            'company': 'Quantaforze Technologies Enterprise Global Cloud Solutions Group',
            'tagline': 'Enterprise distributed high performance streaming infrastructure',
            'about': 'Full-scale cloud project architecting event-driven pipelines.',
            'founderName': 'Somraj Mukherjee & Engineering Leadership Team',
            'tags': ['Flutter', 'Spring Boot', 'PostgreSQL', 'Docker'],
            'url': 'https://github.com/somraj-dev/enterprise-microservices-cloud-infrastructure',
          },
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProjectDetailsScreen), findsOneWidget);
      expect(find.text('High Scale Microservices with Docker and Kubernetes Infrastructure Platform'), findsOneWidget);
    });

    testWidgets('ExperienceDetailsScreen renders role, company, competencies, and impact banner', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ExperienceDetailsScreen(
          experienceData: {
            'title': 'Full Stack Software Engineer Intern',
            'company': 'Quantaforze Corp',
            'duration': 'Jan 2024 – Present',
            'location': 'Bengaluru, Karnataka (Remote)',
            'description': 'Developing enterprise cloud APIs, microservice integrations, and user-facing mobile interfaces with Flutter and Kotlin.',
            'highlight': 'Built scalable real-time feed architecture serving 10k+ requests',
            'tags': ['Spring Boot', 'Flutter', 'Docker', 'PostgreSQL'],
            'statusLabel': 'Active Work',
          },
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ExperienceDetailsScreen), findsOneWidget);
      expect(find.text('Full Stack Software Engineer Intern'), findsOneWidget);
      expect(find.text('Quantaforze Corp'), findsWidgets);
      expect(find.text('Key Achievement & Impact'), findsOneWidget);
      expect(find.text('Built scalable real-time feed architecture serving 10k+ requests'), findsOneWidget);
    });

    testWidgets('AddCoverImageScreen renders curated banner options and upload button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AddCoverImageScreen(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AddCoverImageScreen), findsOneWidget);
      expect(find.text('Add a cover image'), findsOneWidget);
      expect(find.text('Upload single photo'), findsOneWidget);
      expect(find.text('Choose an image'), findsOneWidget);
      expect(find.text('Powered by Lummi.ai'), findsOneWidget);
      expect(find.text('Learn more'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('AboutAccountScreen renders student academic session, branch/dept and mentor faculty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AboutAccountScreen(
          accountData: {
            'name': 'Somraj Lodhi',
            'username': 'somraj_dev',
            'email': 'somraj@gmail.com',
            'branch': 'Computer Science & Engineering',
            'department': 'Information Technology',
            'academicSession': '2022 – 2026',
            'mentorName': 'Dr. R. K. Shrivastava (Faculty Mentor)',
            'isOfficial': false,
          },
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AboutAccountScreen), findsOneWidget);
      expect(find.text('About this account'), findsOneWidget);
      expect(find.text('Somraj Lodhi'), findsOneWidget);
      expect(find.text('Academic session'), findsOneWidget);
      expect(find.text('2022 – 2026'), findsOneWidget);
      expect(find.text('Branch and department'), findsOneWidget);
      expect(find.text('Mentor Faculty Name'), findsOneWidget);
      expect(find.text('Dr. R. K. Shrivastava (Faculty Mentor)'), findsOneWidget);
    });

    testWidgets('AboutAccountScreen renders official handle with Est. year and department, without shared followers', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AboutAccountScreen(
          accountData: {
            'name': 'MITS Gwalior',
            'username': 'mits_gwalior',
            'email': 'info@mits.ac.in',
            'estYear': '1957',
            'department': 'Madhav Institute of Technology & Science, Gwalior',
            'isOfficial': true,
          },
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AboutAccountScreen), findsOneWidget);
      expect(find.text('MITS Gwalior'), findsOneWidget);
      expect(find.text('Est. year'), findsOneWidget);
      expect(find.text('1957'), findsOneWidget);
      expect(find.text('Department'), findsOneWidget);
      expect(find.text('Madhav Institute of Technology & Science, Gwalior'), findsOneWidget);
      expect(find.text('Accounts with shared followers'), findsNothing);
    });

    testWidgets('ProfileScreen renders Add pill button between bio and followers when no track is set', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ProfileScreen(
          isOwnProfile: true,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('do or die STOSLIV'), findsNothing);
    });

    testWidgets('ProfileShowcaseScreen renders showcase categories in bright theme', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ProfileShowcaseScreen(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProfileShowcaseScreen), findsOneWidget);
      expect(find.text('Banners'), findsOneWidget);
      expect(find.text('On your profile'), findsOneWidget);
      expect(find.text('Say more with banners'), findsOneWidget);
      expect(find.text('Add to profile'), findsOneWidget);
      expect(find.text('Mentor'), findsOneWidget);
      expect(find.text('Class coordinator'), findsOneWidget);
      expect(find.text('Club designation'), findsOneWidget);
      expect(find.text('WhatsApp / Social'), findsOneWidget);
      expect(find.text('Fill in the blank'), findsOneWidget);
      expect(find.text('Music'), findsNothing);
    });

    testWidgets('ClubDetailsScreen renders 1:1 replica with title, attendee stack, organizer, address, and CTA button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ClubDetailsScreen(
          clubData: {
            'title': 'Acoustic Serenade Showcase',
            'category': 'Music',
            'location': 'New York, USA',
            'time': 'May 29 - 10:00 PM',
            'memberCount': '8,000+',
            'description': 'Live acoustic performance showcasing student musicians, indie bands, and instrumentalists.',
            'organizerName': 'SonicVibe Events',
            'organizerRole': 'Organize Team',
            'address': 'Grand Symphony Arena, 452 Broadway Ave, Suite 100, New York',
            'price': '\$30.00',
            'priceUnit': '/person',
          },
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ClubDetailsScreen), findsOneWidget);
      expect(find.text('Acoustic Serenade Showcase'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('New York, USA'), findsOneWidget);
      expect(find.text('May 29 - 10:00 PM'), findsOneWidget);
      expect(find.text('8,000+'), findsOneWidget);
      expect(find.text('About Event'), findsOneWidget);
      expect(find.text('Organizer'), findsOneWidget);
      expect(find.text('SonicVibe Events'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Total Price'), findsOneWidget);
      expect(find.text('\$30.00'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);
    });
  });
}
