import 'dart:ui';
import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const AcadykApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class AcadykApp extends StatelessWidget {
  const AcadykApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acadyk',
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      themeMode: ThemeMode.light, // Change to light mode as in the template image
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0A66C2), // LinkedIn Blue
          secondary: Color(0xFF004182),
          surface: Colors.white, // Plain White Background
          error: Color(0xFFD93025),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF191919), // Dark Grey/Black text
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE0E0E0), // Light grey dividers
          thickness: 1.0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

