import 'package:flutter/material.dart';

/// The 4 distinct failure scenarios for institutional login.
enum LoginFailureType {
  /// User used a personal/external email (Gmail, Yahoo, etc.) instead of @mitsgwl.ac.in
  invalidEmailDomain,

  /// Username or enrollment number not found in campus database
  usernameMismatch,

  /// Password is wrong or credentials failed authentication
  wrongPassword,

  /// Campus verification server delay, connection timeout, or API error
  serverTimeout,
}

/// A modal popup styled after the iOS/Cupertino alert dialog (matching the provided design)
/// providing contextual error explanations and clear next actions for login failures.
class LoginFailureDialog extends StatelessWidget {
  final LoginFailureType failureType;
  final String? attemptedAccount;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  const LoginFailureDialog({
    super.key,
    required this.failureType,
    this.attemptedAccount,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  /// Static helper to display the dialog easily from any screen
  static Future<void> show(
    BuildContext context, {
    required LoginFailureType failureType,
    String? attemptedAccount,
    VoidCallback? onPrimaryAction,
    VoidCallback? onSecondaryAction,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => LoginFailureDialog(
        failureType: failureType,
        attemptedAccount: attemptedAccount,
        onPrimaryAction: onPrimaryAction,
        onSecondaryAction: onSecondaryAction,
      ),
    );
  }

  String get _title {
    switch (failureType) {
      case LoginFailureType.invalidEmailDomain:
        return 'Institutional Email Required';
      case LoginFailureType.usernameMismatch:
        return 'Username Not Found';
      case LoginFailureType.wrongPassword:
        return 'Incorrect Password';
      case LoginFailureType.serverTimeout:
        return 'Server Verification Delay';
    }
  }

  String get _bodyContent {
    switch (failureType) {
      case LoginFailureType.invalidEmailDomain:
        return 'You cannot use personal email addresses (Gmail, Yahoo, etc.) to access Acadyk.\n\nIn order to log in, you must sign in with your official MITS-DU institutional email ending with:\n\n@mitsgwl.ac.in\n\nWould you like to select your college email now?';

      case LoginFailureType.usernameMismatch:
        return 'We could not find an active student or faculty profile matching this enrollment or username.\n\nPlease check your spelling or enrollment number format (e.g. 0901CS221001).\n\nWould you like to re-enter your username?';

      case LoginFailureType.wrongPassword:
        return 'The password you entered does not match our campus authentication records.\n\nPlease re-check your password. If you have forgotten your password, you can reset it via college email.\n\nWould you like to reset your password now?';

      case LoginFailureType.serverTimeout:
        return 'The campus authentication system is experiencing high network traffic or server-side delay.\n\nWe were unable to verify your institutional credentials at this moment.\n\nWould you like to retry the login now?';
    }
  }

  String get _secondaryButtonText {
    switch (failureType) {
      case LoginFailureType.invalidEmailDomain:
        return 'Cancel';
      case LoginFailureType.usernameMismatch:
        return 'Cancel';
      case LoginFailureType.wrongPassword:
        return 'Try Again';
      case LoginFailureType.serverTimeout:
        return 'Dismiss';
    }
  }

  String get _primaryButtonText {
    switch (failureType) {
      case LoginFailureType.invalidEmailDomain:
        return 'Use College Email';
      case LoginFailureType.usernameMismatch:
        return 'Try Again';
      case LoginFailureType.wrongPassword:
        return 'Reset Password';
      case LoginFailureType.serverTimeout:
        return 'Retry Now';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0F4C81);
    const borderColor = Color(0xFFE5E7EB);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 24.0),
      elevation: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog Header & Body
              Padding(
                padding: const EdgeInsets.fromLTRB(22.0, 24.0, 22.0, 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      _bodyContent,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF4B5563),
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider separating content from action buttons
              const Divider(
                height: 1,
                thickness: 0.8,
                color: borderColor,
              ),

              // Action Buttons Row (iOS/Cupertino alert button style)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Secondary Button (No / Cancel / Dismiss)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          onSecondaryAction?.call();
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          alignment: Alignment.center,
                          child: Text(
                            _secondaryButtonText,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Vertical divider between buttons
                    const VerticalDivider(
                      width: 1,
                      thickness: 0.8,
                      color: borderColor,
                    ),

                    // Primary Button (Yes / Use College Email / Retry / Reset)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          onPrimaryAction?.call();
                        },
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          alignment: Alignment.center,
                          child: Text(
                            _primaryButtonText,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
