import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/feed/presentation/screens/home_feed_screen.dart';
import 'common/services/supabase_service.dart';
import 'common/providers/auth_provider.dart';
import 'common/providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const AcadykApp(),
    ),
  );
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class AcadykApp extends StatefulWidget {
  const AcadykApp({super.key});

  @override
  State<AcadykApp> createState() => _AcadykAppState();
}

class _AcadykAppState extends State<AcadykApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncProfile();
  }

  void _syncProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    if (authProvider.currentProfile != profileProvider.profile) {
      profileProvider.setProfile(authProvider.currentProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Sync profile when auth changes without triggering infinite rebuilds
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
          if (authProvider.currentProfile != profileProvider.profile) {
            profileProvider.setProfile(authProvider.currentProfile);
          }
        });

        Widget initialScreen = const LoginScreen();
        if (authProvider.isAuthenticated && authProvider.currentProfile != null) {
          initialScreen = const HomeFeedScreen();
        }

        return MaterialApp(
          title: 'Acadyk',
          debugShowCheckedModeBanner: false,
          scrollBehavior: MyCustomScrollBehavior(),
          themeMode: ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A66C2),
              secondary: Color(0xFF004182),
              surface: Colors.white,
              error: Color(0xFFD93025),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Color(0xFF191919),
            ),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Inter',
            dividerTheme: const DividerThemeData(
              color: Color(0xFFE0E0E0),
              thickness: 1.0,
            ),
          ),
          home: initialScreen,
        );
      },
    );
  }
}


