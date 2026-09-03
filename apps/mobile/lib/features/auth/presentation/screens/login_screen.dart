import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acadyk/common/providers/auth_provider.dart';
import 'package:acadyk/common/providers/theme_provider.dart';
import '../../../../common/widgets/logo_widget.dart';
import '../../../../shared/widgets/skeleton/login_loading_skeleton.dart';
import '../widgets/login_failure_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isUsernameNotEmpty = false;
  bool _isPasswordNotEmpty = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isButtonEnabled {
    return _isUsernameNotEmpty && _isPasswordNotEmpty;
  }

  Widget _buildHeaderLogos() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Acadyk Logo
          const LogoWidget(size: 32, text: 'Acadyk'),

          const SizedBox(width: 16.0),

          // MITS-DU Logo + Text
          Image.asset(
            'assets/images/mits_logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.school_rounded,
              size: 32,
              color: Color(0xFF0F4C81),
            ),
          ),
          const SizedBox(width: 8.0),
          const Text(
            'MITS-DU',
            style: TextStyle(
              color: Color(0xFF0F4C81),
              fontWeight: FontWeight.w900,
              fontSize: 23.0,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget logo,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1E293B),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            logo,
            const SizedBox(width: 10.0),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '© 2026 MITS Gwalior Acadyk - Social networking',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5.0),
        Text.rich(
          const TextSpan(
            text: 'Made by ',
            style: TextStyle(
              fontSize: 12.0,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: 'Quantaforze',
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Powered by ',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
            Image.asset(
              'assets/images/mits_logo.png',
              width: 17,
              height: 17,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(width: 17),
            ),
          ],
        ),
      ],
    );
  }

  LoginFailureType _classifyLoginError(dynamic error, String input) {
    final err = error.toString().toLowerCase();

    // 1. Non-institutional / Wrong email domain used
    if (err.contains('mitsgwl.ac.in') ||
        err.contains('institutional email') ||
        err.contains('college email') ||
        (input.contains('@') && !input.endsWith('@mitsgwl.ac.in') && !input.endsWith('@mits.ac.in'))) {
      return LoginFailureType.invalidEmailDomain;
    }

    // 2. Server-side delay / API verification timeout / connection failure
    if (err.contains('timeout') ||
        err.contains('timed out') ||
        err.contains('delay') ||
        err.contains('socket') ||
        err.contains('connection') ||
        err.contains('network') ||
        err.contains('handshake') ||
        err.contains('503') ||
        err.contains('504') ||
        err.contains('server')) {
      return LoginFailureType.serverTimeout;
    }

    // 3. Username mismatch / Enrollment not found in campus database
    if (err.contains('user-not-found') ||
        err.contains('not found') ||
        err.contains('no user') ||
        err.contains('mismatch') ||
        err.contains('does not exist')) {
      return LoginFailureType.usernameMismatch;
    }

    // 4. Password wrong / Invalid credentials
    if (err.contains('wrong-password') ||
        err.contains('invalid-credential') ||
        err.contains('password') ||
        err.contains('credential')) {
      return LoginFailureType.wrongPassword;
    }

    return LoginFailureType.wrongPassword;
  }

  Future<void> _handlePasswordAction() async {
    final usernameInput = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Pre-flight check: Non-institutional personal email entered
    if (usernameInput.contains('@')) {
      final domain = usernameInput.toLowerCase().split('@').last.trim();
      if (domain != 'mitsgwl.ac.in' && domain != 'mits.ac.in') {
        LoginFailureDialog.show(
          context,
          failureType: LoginFailureType.invalidEmailDomain,
          attemptedAccount: usernameInput,
          onPrimaryAction: () {
            _handleGoogleSignIn();
          },
        );
        return;
      }
    }

    // Support both raw username (e.g. 0901CS221001 or somraj.lodhi) and full email
    final email = usernameInput.contains('@') ? usernameInput : '$usernameInput@mitsgwl.ac.in';

    setState(() {
      _isLoading = true;
    });

    try {
      await authProvider.signIn(
        email: email,
        password: password,
      );
      if (!mounted) return;
      try {
        themeProvider.setThemeMode(ThemeMode.light);
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final failureType = _classifyLoginError(e, usernameInput);
      LoginFailureDialog.show(
        context,
        failureType: failureType,
        attemptedAccount: usernameInput,
        onPrimaryAction: () {
          if (failureType == LoginFailureType.wrongPassword) {
            _handleForgotPassword();
          } else if (failureType == LoginFailureType.serverTimeout) {
            _handlePasswordAction();
          } else if (failureType == LoginFailureType.invalidEmailDomain) {
            _handleGoogleSignIn();
          }
        },
      );
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await authProvider.signInWithGoogle();
      if (!mounted) return;
      if (success) {
        try {
          themeProvider.setThemeMode(ThemeMode.light);
        } catch (_) {}
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final failureType = _classifyLoginError(e, '');
      LoginFailureDialog.show(
        context,
        failureType: failureType,
        onPrimaryAction: () {
          _handleGoogleSignIn();
        },
      );
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final input = _usernameController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (input.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter your username or email to reset password.')),
      );
      return;
    }

    final email = input.contains('@') ? input : '$input@mitsgwl.ac.in';

    try {
      await authProvider.sendPasswordReset(email);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your institutional email!')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildActionButton() {
    final bool isActive = _isButtonEnabled;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (isActive && !_isLoading) ? _handlePasswordAction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F4C81),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Login',
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoginLoadingSkeleton(
        statusText: 'Verifying campus credentials...',
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16.0 : 24.0,
              vertical: 20.0,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8.0),
                  Center(
                    child: _buildHeaderLogos(),
                  ),
                  const SizedBox(height: 28.0),
                  Text(
                    'Your Next Opportunity\nStarts Here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isCompact ? 23.0 : 26.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Log in to discover competitions, jobs, and internships built for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFF4B5563),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  _buildSocialButton(
                    logo: const MitsDuLogo(size: 22.0),
                    text: 'Continue with MITS-DU',
                    onTap: _handleGoogleSignIn,
                  ),
                  const SizedBox(height: 20.0),

                  Row(
                    children: const [
                      Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
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
                  const SizedBox(height: 20.0),

                  // Username Label
                  Row(
                    children: const [
                      Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      Text(
                        ' *',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7.0),
                  TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    onChanged: (val) {
                      setState(() {
                        _isUsernameNotEmpty = val.trim().isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Username',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14.0,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
                      ),
                    ),
                    style: const TextStyle(fontSize: 14.5, color: Colors.black),
                  ),

                  const SizedBox(height: 16.0),
                  // Password Label
                  Row(
                    children: const [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      Text(
                        ' *',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: (val) {
                      setState(() {
                        _isPasswordNotEmpty = val.trim().isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14.0,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
                      ),
                    ),
                    style: const TextStyle(fontSize: 14.5, color: Colors.black),
                  ),

                  const SizedBox(height: 10.0),
                  // Forgot Password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF0F4C81),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  _buildActionButton(),
                  const SizedBox(height: 32.0),
                  _buildFooter(),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16.0),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Provider.of<AuthProvider>(context, listen: false).bypassSignIn();
                          try {
                            Provider.of<ThemeProvider>(context, listen: false).setThemeMode(ThemeMode.light);
                          } catch (_) {}
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        ),
                        child: const Text(
                          '[DEV] Bypass Login',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MitsDuLogo extends StatelessWidget {
  final double size;
  const MitsDuLogo({super.key, this.size = 22.0});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mits_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.school_rounded,
        size: size,
        color: const Color(0xFF0F4C81),
      ),
    );
  }
}
