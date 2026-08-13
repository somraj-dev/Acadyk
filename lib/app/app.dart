import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/providers/auth_provider.dart';
import '../common/providers/profile_provider.dart';
import '../common/providers/theme_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/feed/presentation/screens/home_feed_screen.dart';

class AcadykApp extends StatefulWidget {
  const AcadykApp({super.key});

  @override
  State<AcadykApp> createState() => _AcadykAppState();
}

class _AcadykAppState extends State<AcadykApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
          if (authProvider.currentProfile != profileProvider.profile) {
            profileProvider.setProfile(authProvider.currentProfile);
          }
        });

        // Safely access ThemeProvider with fallback if hot-reloaded
        ThemeProvider? themeProvider;
        try {
          themeProvider = Provider.of<ThemeProvider>(context, listen: true);
        } catch (_) {
          themeProvider = null;
        }

        Widget initialScreen = const LoginScreen();
        if (authProvider.isAuthenticated && authProvider.currentProfile != null) {
          initialScreen = const HomeFeedScreen();
        }

        return MaterialApp(
          title: 'Acadyk',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider?.themeMode ?? ThemeMode.system,
          theme: themeProvider?.lightThemeData ?? ThemeData.light(useMaterial3: true),
          darkTheme: themeProvider?.darkThemeData ?? ThemeData.dark(useMaterial3: true),
          home: initialScreen,
        );
      },
    );
  }
}
