import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../common/services/supabase_service.dart';
import '../common/providers/auth_provider.dart';
import '../common/providers/profile_provider.dart';
import '../common/providers/theme_provider.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  runApp(
    ProviderScope(
      child: legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => ProfileProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const AcadykApp(),
      ),
    ),
  );
}
