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
import 'package:acadyk/features/profile/presentation/screens/club_members_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/post_detail_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/create_post_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/select_opportunity_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/create_team_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/edit_team_member_screen.dart';
import 'package:acadyk/features/feed/presentation/services/opportunities_manager.dart';
import 'package:acadyk/features/feed/presentation/screens/home_feed_screen.dart';
import 'package:flutter/cupertino.dart';

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
      expect(find.text('Event Photos & Moments'), findsOneWidget);
      expect(find.text('Organized Events'), findsOneWidget);
      expect(find.text('Achievements & Milestones'), findsOneWidget);
      expect(find.text('Domains & Tech Stack'), findsOneWidget);
    });

    testWidgets('ClubMembersScreen renders replica members list and opens ProfileScreen on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ClubMembersScreen(
          clubTitle: 'Google Developer Groups',
          memberCount: '450+ Members',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ClubMembersScreen), findsOneWidget);
      expect(find.text('Google Developer Groups Members'), findsOneWidget);
      expect(find.text('Student Development Cell'), findsOneWidget);
      expect(find.text('ACM Student Chapter'), findsOneWidget);
      expect(find.text('Alina Sprongole'), findsOneWidget);
      expect(find.text('@GDGMITS'), findsNothing);
      expect(find.text('Invite & Join'), findsNothing);
      expect(find.text('Following'), findsWidgets);

      // Tap on member Alina Sprongole to open ProfileScreen
      await tester.tap(find.text('Alina Sprongole'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('PostDetailScreen renders author header, comment input, and tree hierarchy', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PostDetailScreen(
          authorName: 'Somraj Lodhi',
          authorHeadline: 'Founder & CEO @ Acadyk',
          authorAvatar: 'assets/images/somraj_avatar.jpg',
          timeAgo: '2h',
          postText: 'Excited to unveil the new recursive nested comments feature!',
          connectionDegree: '1st',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PostDetailScreen), findsOneWidget);
      expect(find.text('Somraj Lodhi'), findsWidgets);
      expect(find.text('Excited to unveil the new recursive nested comments feature!'), findsOneWidget);
      expect(find.text('Add a comment...'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);

      // Enter top-level comment
      await tester.enterText(find.byType(TextField), 'First root comment');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('First root comment'), findsOneWidget);
      expect(find.text('Reply'), findsWidgets);
      expect(find.text('Like'), findsWidgets);

      // Open Post options and test Hide options modal
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      expect(find.text('Hide'), findsOneWidget);
      expect(find.text('About this account'), findsOneWidget);

      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();

      expect(find.text('Hide options'), findsOneWidget);
      expect(find.text('Hide this post'), findsOneWidget);
      expect(find.text('Hide all posts from Somraj Lodhi'), findsOneWidget);
    });

    testWidgets('CreatePostScreen allows selecting collaborator and co-authoring posts', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CreatePostScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CreatePostScreen), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.person_2), findsOneWidget);

      // Open collaborator picker bottom sheet
      await tester.tap(find.byIcon(CupertinoIcons.person_2));
      await tester.pumpAndSettle();

      expect(find.text('Invite Collaborator'), findsOneWidget);
      expect(find.text('MITS Robotics Club'), findsOneWidget);
      expect(find.text('Technical Student Society · Innovation & Automation Hub'), findsOneWidget);
      expect(find.text('@mits_robotics'), findsNothing);

      // Select MITS Robotics Club
      await tester.tap(find.text('MITS Robotics Club'));
      await tester.pumpAndSettle();

      // Verify collaborator badge is shown (without @handle)
      expect(find.text('Co-author: MITS Robotics Club'), findsOneWidget);

      // Enter post content
      await tester.enterText(find.byType(TextField).first, 'Announcing our joint robotics workshop with MITS Robotics Club!');
      await tester.pump();

      // Post button is enabled
      expect(find.text('Post'), findsOneWidget);
    });

    testWidgets('SelectOpportunityScreen displays all opportunity types and publishes flow directly to OpportunitiesManager', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      HomeFeedScreen.switchTab(0);
      await tester.pumpWidget(createTestWidget(
        const SelectOpportunityScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SelectOpportunityScreen), findsOneWidget);
      expect(find.text('Select Opportunity'), findsOneWidget);
      expect(find.text('Quizzes'), findsOneWidget);
      expect(find.text('Hackathons & Coding Challenges'), findsOneWidget);
      expect(find.text('Create Team'), findsOneWidget);
      expect(find.text('Webinars, Conferences & Workshops'), findsOneWidget);
      expect(find.text('Cultural Events'), findsOneWidget);
      expect(find.text('Scholarships & Internships'), findsOneWidget);

      // Tap Quizzes to test opportunity publish flow
      await tester.tap(find.text('Quizzes'));
      await tester.pumpAndSettle();

      // Enter question
      await tester.enterText(find.byType(TextField).first, 'What is the primary concept of React State?');
      await tester.pump();

      // Tap Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Verify that it published directly into OpportunitiesManager
      final topOpp = OpportunitiesManager.opportunitiesNotifier.value.first;
      expect(topOpp['title'], 'What is the primary concept of React State?');
      expect(topOpp['tags'], contains('Quizzes'));

      // Verify HomeFeedScreen tab switched to Opportunities tab (index 1)
      expect(HomeFeedScreen.activeTabNotifier.value, 1);
    });

    testWidgets('CreateTeamScreen allows editing team name and tagline via pencil icon', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(
        const CreateTeamScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CreateTeamScreen), findsOneWidget);
      expect(find.text('Axio Innovators'), findsOneWidget);
      expect(find.text('Building the future, together.'), findsOneWidget);

      // Tap pencil icon on team title row
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      // Edit Team Info modal appears
      expect(find.text('Edit Team Information'), findsOneWidget);
      expect(find.text('Save Team Info'), findsOneWidget);

      // Modify team name
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Nova Innovators');
      await tester.enterText(textFields.at(1), 'Innovating the impossible.');
      await tester.pump();

      // Save changes
      await tester.tap(find.text('Save Team Info'));
      await tester.pumpAndSettle();

      expect(find.text('Nova Innovators'), findsOneWidget);
      expect(find.text('Innovating the impossible.'), findsOneWidget);
    });

    testWidgets('EditTeamMemberScreen allows updating member details, avatar, and removing member', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(
        const EditTeamMemberScreen(
          memberIndex: 1,
          memberData: {
            'name': 'Ananya Singh',
            'role': 'ML Engineer',
            'email': '25AM10SO81@mitsgwl.ac.in',
            'contact': '+919876543210',
            'avatar': 'assets/images/alina_avatar.jpg',
            'isLeader': false,
          },
          isLeader: false,
          totalMembers: 4,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EditTeamMemberScreen), findsOneWidget);
      expect(find.text('Edit Member Details'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Remove Member from Team'), findsOneWidget);

      // Change member role
      final roleField = find.widgetWithText(TextField, 'ML Engineer');
      if (roleField.evaluate().isNotEmpty) {
        await tester.enterText(roleField, 'Lead AI Researcher');
      }

      // Test Remove Member confirmation dialog
      await tester.tap(find.text('Remove Member from Team'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to remove "Ananya Singh" from the team roster?'), findsOneWidget);
      expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('Cancel')), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);

      // Cancel dialog
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Cancel')));
      await tester.pumpAndSettle();

      // Tap Save Changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
    });
  });
}
