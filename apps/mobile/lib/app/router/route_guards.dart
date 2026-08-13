import 'package:flutter/material.dart';
import '../../common/services/supabase_service.dart';

class RouteGuards {
  static bool isAuthenticated() {
    return SupabaseService.client.auth.currentUser != null;
  }

  static String? checkAuthRedirect(BuildContext context, String currentPath) {
    final bool loggedIn = isAuthenticated();
    final bool isAuthRoute = currentPath == '/login';

    if (!loggedIn && !isAuthRoute) {
      return '/login';
    }
    if (loggedIn && isAuthRoute) {
      return '/home';
    }
    return null;
  }
}
