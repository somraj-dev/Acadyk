import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/providers/auth_provider.dart';
import '../common/providers/profile_provider.dart';
import '../common/providers/theme_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/feed/presentation/screens/home_feed_screen.dart';

class AcadykApp extends StatelessWidget {
  const AcadykApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Acadyk',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: themeProvider.lightThemeData,
          darkTheme: themeProvider.darkThemeData,
          home: const _AuthGate(),
        );
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _lastSyncedProfileId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final currentProfile = authProvider.currentProfile;
        if (currentProfile != null && currentProfile.id != _lastSyncedProfileId) {
          _lastSyncedProfileId = currentProfile.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
            if (profileProvider.profile?.id != currentProfile.id) {
              profileProvider.setProfile(currentProfile);
            }
          });
        }

        if (authProvider.isAuthenticated && authProvider.currentProfile != null) {
          return const HomeFeedScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
