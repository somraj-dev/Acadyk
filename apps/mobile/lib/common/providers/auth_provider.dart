import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthUser? _currentUser;
  ProfileModel? _currentProfile;
  bool _isLoading = false;

  AuthProvider() {
    try {
      _currentUser = AuthService.currentUser;
      if (_currentUser != null) {
        final fallbackUsername = _currentUser!.email.isNotEmpty ? _currentUser!.email.split('@').first : 'user';
        _currentProfile = ProfileModel.fromJson({
          'id': _currentUser!.id,
          'email': _currentUser!.email,
          'full_name': _currentUser!.fullName ?? '',
          'username': _currentUser!.enrollmentNumber ?? _currentUser!.username ?? fallbackUsername,
          'major': _currentUser!.branch ?? '',
          'degree': _currentUser!.degree ?? '',
        });
        _fetchProfile(_currentUser!.id);
      }
    } catch (e) {
      debugPrint('AuthProvider initialization error: $e');
    }
  }

  AuthUser? get currentUser => _currentUser;
  ProfileModel? get currentProfile => _currentProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void bypassSignIn() {
    final mockUser = AuthUser(
      id: 'mock-dev-user-id-999',
      email: 'developer@mitsgwl.ac.in',
      fullName: 'Developer',
      roles: ['STUDENT'],
    );

    final mockProfile = ProfileModel.fromJson({
      'id': 'mock-dev-user-id-999',
      'email': 'developer@mitsgwl.ac.in',
      'full_name': 'Developer',
      'username': 'developer',
      'major': 'Computer Science',
      'degree': 'B.Tech',
    });

    _currentUser = mockUser;
    _currentProfile = mockProfile;
    AuthService.saveSession(mockUser);
    notifyListeners();
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final profileData = await ProfileService.getMyProfile() ?? await ProfileService.getProfile(userId);
      if (profileData != null) {
        _currentProfile = ProfileModel.fromJson(profileData);
        notifyListeners();
        return;
      }
    } catch (_) {}

    if (_currentProfile == null) {
      final fallbackUsername = _currentUser?.email.isNotEmpty == true ? _currentUser!.email.split('@').first : 'user';
      final cleanProfile = ProfileModel.fromJson({
        'id': userId,
        'email': _currentUser?.email ?? '',
        'full_name': _currentUser?.fullName ?? '',
        'username': _currentUser?.enrollmentNumber ?? _currentUser?.username ?? fallbackUsername,
        'major': _currentUser?.branch ?? '',
        'degree': _currentUser?.degree ?? '',
      });
      _currentProfile = cleanProfile;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    if (_currentUser != null) {
      await _fetchProfile(_currentUser!.id);
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _setLoading(true);
    try {
      final user = await AuthService.signUpWithEmail(
        email,
        password,
        fullName: fullName,
      );
      if (user != null) {
        _currentUser = user;
        await _fetchProfile(user.id);
        return true;
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final user = await AuthService.signInWithEmail(email, password);
      if (user != null) {
        _currentUser = user;
        await _fetchProfile(user.id);
        return true;
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        await _fetchProfile(user.id);
        return true;
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await AuthService.sendPasswordReset(email);
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await AuthService.signOut();
      _currentUser = null;
      _currentProfile = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    _setLoading(true);
    try {
      await AuthService.deleteAccount();
      _currentUser = null;
      _currentProfile = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
