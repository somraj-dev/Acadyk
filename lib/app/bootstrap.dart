import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    debugPrint('Supabase initialization error: ');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AcadykApp(),
    ),
  );
}
