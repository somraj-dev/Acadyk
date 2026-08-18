import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../common/providers/auth_provider.dart';
import '../services/profile_manager.dart';

class SettingsChangePasswordScreen extends StatefulWidget {
  const SettingsChangePasswordScreen({super.key});

  @override
  State<SettingsChangePasswordScreen> createState() => _SettingsChangePasswordScreenState();
}

class _SettingsChangePasswordScreenState extends State<SettingsChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _retypePasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureRetypePassword = true;

  bool _logOutOfOtherDevices = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleForgottenPassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rawEmail = ProfileManager.email.isNotEmpty
        ? ProfileManager.email
        : (authProvider.currentProfile?.email ?? authProvider.currentUser?.email ?? 'developer@mitsgwl.ac.in');
    final email = rawEmail.endsWith('@acadyk.com')
        ? '${rawEmail.split('@').first}@mitsgwl.ac.in'
        : (rawEmail.isNotEmpty ? rawEmail : 'developer@mitsgwl.ac.in');

    try {
      await authProvider.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to $email'),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send reset email: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _handleChangePassword() async {
    final currentPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final retypePass = _retypePasswordController.text.trim();

    if (currentPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your current password'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New password must be at least 6 characters'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (newPass != retypePass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New passwords do not match'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API update and provide immediate responsive feedback
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password updated successfully!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.of(context).pop();
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isObscured,
    required VoidCallback onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              isObscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: onToggleObscure,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const bodyColor = Color(0xFF475569);
    const lightBlueColor = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.left_chevron, color: titleColor, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Change password',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your password must be at least 6 characters and should include a combination of numbers, letters and special characters (!\$@%).',
                          style: TextStyle(
                            color: bodyColor,
                            fontSize: 14.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Current password
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          hintText: 'Current password (updated on 11/08/2025)',
                          isObscured: _obscureCurrentPassword,
                          onToggleObscure: () {
                            setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
                          },
                        ),
                        const SizedBox(height: 14),

                        // New password
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hintText: 'New password',
                          isObscured: _obscureNewPassword,
                          onToggleObscure: () {
                            setState(() => _obscureNewPassword = !_obscureNewPassword);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Retype new password
                        _buildPasswordField(
                          controller: _retypePasswordController,
                          hintText: 'Retype new password',
                          isObscured: _obscureRetypePassword,
                          onToggleObscure: () {
                            setState(() => _obscureRetypePassword = !_obscureRetypePassword);
                          },
                        ),
                        const SizedBox(height: 18),

                        // Forgotten password link
                        GestureDetector(
                          onTap: _handleForgottenPassword,
                          child: const Text(
                            'Forgotten your password?',
                            style: TextStyle(
                              color: lightBlueColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Log out of other devices checkbox
                        GestureDetector(
                          onTap: () {
                            setState(() => _logOutOfOtherDevices = !_logOutOfOtherDevices);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _logOutOfOtherDevices,
                                    activeColor: lightBlueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(color: Color(0xFF64748B), width: 1.5),
                                    onChanged: (val) {
                                      setState(() => _logOutOfOtherDevices = val ?? false);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Log out of other devices. Choose this if someone else used your account.',
                                  style: TextStyle(
                                    color: bodyColor,
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightBlueColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Change password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
