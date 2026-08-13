import 'package:flutter/material.dart';
import '../../common/providers/auth_provider.dart';

class RouteGuards {
  static bool isAuthenticated(AuthProvider authProvider) {
    return authProvider.isAuthenticated;
  }
}
