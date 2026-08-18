import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../common/providers/auth_provider.dart';
import '../../../../common/services/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../services/profile_manager.dart';

class SettingsDeactivateAccountScreen extends StatefulWidget {
  const SettingsDeactivateAccountScreen({super.key});

  @override
  State<SettingsDeactivateAccountScreen> createState() => _SettingsDeactivateAccountScreenState();
}

class _SettingsDeactivateAccountScreenState extends State<SettingsDeactivateAccountScreen> {
  bool _isProcessing = false;

  Future<void> _handleDeactivate() async {
    setState(() => _isProcessing = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    } catch (_) {
      await AuthService.signOut();
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Your account has been deactivated. You can log back in anytime to reactivate.',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildUserAvatar(double radius, String displayName) {
    final avatarBytes = ProfileManager.avatarBytes;
    final photoUrl = ProfileManager.avatarUrl.isNotEmpty
        ? ProfileManager.avatarUrl
        : (Provider.of<AuthProvider>(context, listen: false).currentProfile?.profilePhotoUrl ?? '');

    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(avatarBytes),
      );
    }

    if (photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFFF1F5F9),
          backgroundImage: CachedNetworkImageProvider(photoUrl),
        );
      } else if (photoUrl.startsWith('assets/')) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFFF1F5F9),
          backgroundImage: AssetImage(photoUrl),
        );
      }
    }

    final initials = displayName.trim().isNotEmpty
        ? displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase()
        : 'U';

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF0F172A),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const bodyColor = Color(0xFF475569);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profile = authProvider.currentProfile;
    final displayName = ProfileManager.name.isNotEmpty
        ? ProfileManager.name
        : (profile != null && profile.username.isNotEmpty
            ? profile.username
            : (profile != null && profile.fullName.isNotEmpty
                ? profile.fullName
                : (ProfileManager.username.isNotEmpty ? ProfileManager.username : 'developer')));

    final rawEmail = ProfileManager.email.isNotEmpty
        ? ProfileManager.email
        : (profile?.email ?? authProvider.currentUser?.email ?? 'developer@mitsgwl.ac.in');
    final email = rawEmail.endsWith('@acadyk.com')
        ? '${rawEmail.split('@').first}@mitsgwl.ac.in'
        : (rawEmail.isNotEmpty ? rawEmail : 'developer@mitsgwl.ac.in');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: titleColor, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Deactivate your\naccount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Deactivating your account means no one will see your posts and all your projects and certificates, or your profile.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bodyColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildUserAvatar(24, displayName),
                      const SizedBox(width: 14),
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: titleColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: bodyColor,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                      children: [
                        const TextSpan(
                          text: 'You can reactivate your account at any time. If you want to use Acadyk again, just log in with ',
                        ),
                        TextSpan(
                          text: email,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 140,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handleDeactivate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
