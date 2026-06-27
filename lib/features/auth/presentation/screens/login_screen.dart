import 'package:flutter/material.dart';
import '../../../../common/widgets/logo_widget.dart';
import '../../../../common/widgets/google_logo.dart';
import '../../../feed/presentation/screens/home_feed_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // Exact White Background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              constraints: BoxConstraints(
                maxWidth: 480, // Mobile device dimensions
                minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upper block: Logo and Slogan
                  Column(
                    children: [
                      SizedBox(height: size.height * 0.09), // Top margin space
                      const LogoWidget(fontSize: 34.0), // Smaller, compact logo
                      const SizedBox(height: 20.0),
                      Text(
                        'Join a trusted community of 1B\nprofessionals',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF191919), // LinkedIn primary text color
                          fontSize: 18.0, // Slimmer font size matching original layout
                          fontWeight: FontWeight.w300, // Lighter typography weight
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),

                  // Middle space buffer to simulate white empty canvas
                  SizedBox(height: size.height * 0.16),

                  // Lower block: Action Buttons & Footnotes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Google Authentication Trigger
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeFeedScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A66C2), // LinkedIn Blue
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12.0), // Slimmer button height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0), // Rounded corners
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            GoogleLogo(size: 20.0), // Vector multi-color G logo
                            SizedBox(width: 10),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500, // Matching font style
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14.0),

                      // Email Authentication Trigger
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeFeedScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF191919),
                          side: const BorderSide(color: Color(0xFF191919), width: 1.0), // Thin border
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.email_outlined, size: 18, color: Color(0xFF191919)),
                            SizedBox(width: 10),
                            Text(
                              'Sign in with Email',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Separator
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Color(0xFF5E5E5E),
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Registration Redirection Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New to Acadyk? ',
                            style: TextStyle(
                              color: Color(0xFF191919),
                              fontSize: 15.0,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Nav to Join now
                            },
                            child: const Text(
                              'Join now',
                              style: TextStyle(
                                color: Color(0xFF0A66C2), // LinkedIn Blue
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32.0),

                      // User Agreement & Cookie Consent Disclaimer
                      Text.rich(
                        TextSpan(
                          text: 'By clicking Agree & Join or Continue, you agree to the Acadyk ',
                          style: const TextStyle(
                            color: Color(0xFF5E5E5E), // Slate dark grey
                            fontSize: 10.5,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: 'User Agreement',
                              style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ', '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ', and '),
                            TextSpan(
                              text: 'Cookie Policy',
                              style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
