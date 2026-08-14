import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool privateAccount;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.privateAccount = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? privateAccount,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      privateAccount: privateAccount ?? this.privateAccount,
    );
  }
}

final settingsStateProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleTheme(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void togglePushNotifications(bool enabled) {
    state = state.copyWith(pushNotificationsEnabled: enabled);
  }

  void toggleEmailNotifications(bool enabled) {
    state = state.copyWith(emailNotificationsEnabled: enabled);
  }

  void togglePrivateAccount(bool enabled) {
    state = state.copyWith(privateAccount: enabled);
  }
}
