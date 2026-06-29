import 'package:flutter/material.dart';
import '../../../../common/widgets/logo_widget.dart';
import '../../../../common/widgets/google_logo.dart';
import '../../../feed/presentation/screens/home_feed_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isEmailNotEmpty = false;
  bool _usePassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular logo for acadyk matching unstop design format
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFF0F4C81), // Solid royal blue circle
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            'a',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'sans-serif',
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'acadyk',
          style: TextStyle(
            color: Color(0xFF0F4C81),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget logo,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF374151),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 16,
              child: logo,
            ),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final bool isActive = _isEmailNotEmpty && (!_usePassword || _passwordController.text.trim().isNotEmpty);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isActive
            ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeFeedScreen()),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F4C81),
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          _usePassword ? 'Login' : 'Continue with OTP',
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF9CA3AF),
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              children: [
                const SizedBox(height: 24.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildLogo(),
                ),
                const SizedBox(height: 28.0),
                const Text(
                  'Your Next Opportunity\nStarts Here',
                  style: TextStyle(
                    fontSize: 27.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Log in to discover competitions, jobs, and internships built for you.',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF4B5563),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 36.0),

                _buildSocialButton(
                  logo: const GoogleLogo(size: 20.0),
                  text: 'Login with Google',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeFeedScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12.0),
                _buildSocialButton(
                  logo: const LinkedInLogo(size: 20.0),
                  text: 'Continue with LinkedIn',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeFeedScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24.0),

                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24.0),

                Row(
                  children: const [
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Text(
                      ' *',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) {
                    setState(() {
                      _isEmailNotEmpty = val.trim().isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter Email',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14.5,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14.5, color: Colors.black),
                ),

                if (_usePassword) ...[
                  const SizedBox(height: 16.0),
                  Row(
                    children: const [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      Text(
                        ' *',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: (val) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14.5,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
                      ),
                    ),
                    style: const TextStyle(fontSize: 14.5, color: Colors.black),
                  ),
                ],

                const SizedBox(height: 6.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _usePassword = !_usePassword;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _usePassword ? 'Login via OTP' : 'Login via Password',
                      style: const TextStyle(
                        color: Color(0xFF0F4C81),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                _buildActionButton(),
                const SizedBox(height: 28.0),

                Text.rich(
                  TextSpan(
                    text: 'By signing in, you accept the ',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: Color(0xFF0F4C81),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' and acknowledge our '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: Color(0xFF0F4C81),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' .'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LinkedInLogo extends StatelessWidget {
  final double size;
  const LinkedInLogo({super.key, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2),
        borderRadius: BorderRadius.circular(4.0),
      ),
      alignment: Alignment.center,
      child: Text(
        'in',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.7,
          fontWeight: FontWeight.bold,
          fontFamily: 'sans-serif',
          height: 1.0,
        ),
      ),
    );
  }
}

