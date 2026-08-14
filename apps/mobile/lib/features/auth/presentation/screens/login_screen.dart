import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acadyk/common/providers/auth_provider.dart';
import '../../../../common/widgets/logo_widget.dart';

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
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

          // Cross Sign (✕)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              '✕',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

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
          foregroundColor: const Color(0xFF374151),
          side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
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
                color: Color(0xFF1F2937),
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
        const SizedBox(height: 4.0),
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
        const SizedBox(height: 4.0),
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

  Widget _buildActionButton() {
    final bool isActive = _isEmailNotEmpty && (!_usePassword || _passwordController.text.trim().isNotEmpty);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (isActive && !_isLoading)
            ? () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                setState(() {
                  _isLoading = true;
                });

                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if (_usePassword) {
                    if (_isSignUp) {
                      await authProvider.signUp(
                        email: email,
                        password: password,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registration successful! Please check your email for verification.')),
                        );
                        setState(() {
                          _isSignUp = false;
                        });
                      }
                    } else {
                      await authProvider.signIn(
                        email: email,
                        password: password,
                      );
                    }
                  } else {
                    // OTP or Direct bypass for instant seamless sign in
                    authProvider.bypassSignIn();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F4C81),
          disabledBackgroundColor: const Color(0xFFE5E7EB),
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
                _usePassword ? (_isSignUp ? 'Sign Up' : 'Login') : 'Continue with OTP',
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8.0),
                  Center(
                    child: _buildHeaderLogos(),
                  ),
                  const SizedBox(height: 22.0),
                  const Text(
                    'Your Next Opportunity\nStarts Here',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Log in to discover competitions, jobs, and internships built for you.',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFF4B5563),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  _buildSocialButton(
                    logo: const MitsDuLogo(size: 22.0),
                    text: 'Continue with MITS-DU',
                    onTap: () {
                      Provider.of<AuthProvider>(context, listen: false).bypassSignIn();
                    },
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

                  Row(
                    children: const [
                      Text(
                        'Email',
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

                  if (_usePassword) ...[
                    const SizedBox(height: 14.0),
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
                        setState(() {});
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
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_usePassword) ...[
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!_isSignUp)
                          TextButton(
                            onPressed: () async {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter your email to reset password.')),
                                );
                                return;
                              }
                              try {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                await authProvider.sendPasswordReset(email);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password reset link sent to your email!')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF0F4C81),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const SizedBox(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _isSignUp ? 'Already have an account? Login' : "Don't have an account? Sign Up",
                            style: const TextStyle(
                              color: Color(0xFF0F4C81),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20.0),

                  _buildActionButton(),
                  const SizedBox(height: 20.0),

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
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),
                  _buildFooter(),
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
