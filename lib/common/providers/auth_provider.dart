import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  ProfileModel? _currentProfile;
  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider() {
    try {
      _currentUser = AuthService.currentUser;
      if (_currentUser != null) {
        _fetchProfile(_currentUser!.id);
      }
      _setupAuthListener();
    } catch (e) {
      debugPrint('AuthProvider initialization error: $e');
    }
  }

  User? get currentUser => _currentUser;
  ProfileModel? get currentProfile => _currentProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void _setupAuthListener() {
    _authSubscription = AuthService.onAuthStateChange.listen((data) async {
      final session = data.session;
      _currentUser = session?.user;
      
      if (_currentUser != null) {
        await _fetchProfile(_currentUser!.id);
      } else {
        _currentProfile = null;
      }
      notifyListeners();
    });
  }

  void bypassSignIn() {
    // Generate mock credentials
    final mockUser = User(
      id: 'mock-dev-user-id-999',
      appMetadata: {},
      userMetadata: {
        'full_name': 'Somraj Lodhi',
        'user_name': 'somraj-dev',
      },
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final mockProfile = ProfileModel.fromJson({
      'id': 'mock-dev-user-id-999',
      'email': 'developer@acadyk.com',
      'full_name': 'Somraj Lodhi',
      'username': 'somraj-dev',
    });

    _currentUser = mockUser;
    _currentProfile = mockProfile;
    notifyListeners();
  }

  Future<void> _fetchProfile(String userId) async {
    final profileData = await ProfileService.getProfile(userId);
    if (profileData != null) {
      _currentProfile = ProfileModel.fromJson(profileData);
    } else {
      try {
        final email = _currentUser?.email ?? 'user@example.com';
        final meta = _currentUser?.userMetadata ?? {};
        
        // Extract real username from OAuth metadata (GitHub nickname/user_name)
        String username = meta['user_name'] ?? meta['preferred_username'] ?? '';
        if (username.trim().isEmpty) {
          username = email.split('@')[0].replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '').toLowerCase();
        }
        
        final name = meta['full_name'] ?? meta['name'] ?? email.split('@')[0];
        final avatar = meta['avatar_url'] ?? '';

        final newProfile = {
          'id': userId,
          'email': email,
          'full_name': name,
          'username': username,
          'profile_photo_url': avatar,
        };

        try {
          await ProfileService.createProfile(newProfile);
        } catch (e) {
          // If first insert fails (e.g. duplicate username constraint), append suffix and retry
          final errMsg = e.toString();
          if (errMsg.contains('profiles_username_key') || errMsg.contains('duplicate') || errMsg.contains('409') || errMsg.contains('already exists')) {
            final suffix = userId.substring(0, 5);
            newProfile['username'] = "${username}_$suffix";
            await ProfileService.createProfile(newProfile);
          } else {
            rethrow;
          }
        }

        final createdData = await ProfileService.getProfile(userId);
        if (createdData != null) {
          _currentProfile = ProfileModel.fromJson(createdData);
        }
      } catch (e) {
        print("Error in _fetchProfile auto-creation: $e");
      }
    }
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_currentUser != null) {
      await _fetchProfile(_currentUser!.id);
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _setLoading(true);
    try {
      await AuthService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await AuthService.signInWithEmail(
        email: email,
        password: password,
      );
    } finally {
      _setLoading(false);
    }
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
