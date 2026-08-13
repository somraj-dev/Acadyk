import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/feed/presentation/screens/home_feed_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/appearance_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/chat/presentation/screens/message_center_screen.dart';
import 'route_names.dart';
import 'route_guards.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.initial,
  redirect: (context, state) {
    return RouteGuards.checkAuthRedirect(context, state.uri.path);
  },
  routes: [
    GoRoute(
      path: RouteNames.initial,
      builder: (context, state) => const HomeFeedScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeFeedScreen(),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RouteNames.appearance,
      builder: (context, state) => const AppearanceScreen(),
    ),
    GoRoute(
      path: RouteNames.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: RouteNames.messages,
      builder: (context, state) => const MessageCenterScreen(),
    ),
  ],
);
