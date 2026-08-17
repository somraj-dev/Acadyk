import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/auth/firebase_auth_service.dart';
import '../../features/profile/presentation/services/profile_manager.dart';

class AuthUser {
  final String id;
  final String email;
  final String? fullName;
  final String? username;
  final String? enrollmentNumber;
  final String? collegeEmail;
  final String? degree;
  final String? branch;
  final int? joiningYear;
  final bool isFirstLogin;
  final List<String> roles;

  AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.enrollmentNumber,
    this.collegeEmail,
    this.degree,
    this.branch,
    this.joiningYear,
    this.isFirstLogin = false,
    this.roles = const ['STUDENT'],
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rolesList = json['roles'] is List
        ? (json['roles'] as List).map((e) => e.toString()).toList()
        : ['STUDENT'];
    final enrollment = json['enrollmentNumber'] ?? json['enrollment_number'] ?? json['username'];
    return AuthUser(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? json['collegeEmail']?.toString() ?? '',
      fullName: json['fullName'] ?? json['full_name'],
      username: enrollment?.toString() ?? json['username']?.toString(),
      enrollmentNumber: enrollment?.toString(),
      collegeEmail: json['collegeEmail']?.toString() ?? json['college_email']?.toString(),
      degree: json['degree']?.toString() ?? 'B.Tech',
      branch: json['branch']?.toString() ?? json['major']?.toString(),
      joiningYear: json['joiningYear'] is int ? json['joiningYear'] : int.tryParse(json['joiningYear']?.toString() ?? ''),
      isFirstLogin: json['isFirstLogin'] == true,
      roles: rolesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'username': username,
      'enrollmentNumber': enrollmentNumber,
      'collegeEmail': collegeEmail,
      'degree': degree,
      'branch': branch,
      'joiningYear': joiningYear,
      'isFirstLogin': isFirstLogin,
      'roles': roles,
    };
  }
}

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static AuthUser? _currentUser;
  static const int _sessionDurationDays = 15;

  static AuthUser? get currentUser => _currentUser;
  static bool get isAuthenticated => _currentUser != null;

  static Future<void> init() async {
    await FirebaseAuthService.init();

    // 1. Verify 15-day login session duration
    final loginTimestampStr = await _storage.read(key: 'login_timestamp');
    if (loginTimestampStr != null) {
      final loginTimestamp = int.tryParse(loginTimestampStr);
      if (loginTimestamp != null) {
        final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
        final daysPassed = DateTime.now().difference(loginDate).inDays;
        if (daysPassed >= _sessionDurationDays) {
          // Session expired after 15 days, require fresh login
          await signOut();
          return;
        }
      }
    }

    // 2. Restore cached user profile if present
    final userJson = await _storage.read(key: 'user_profile');
    if (userJson != null) {
      try {
        _currentUser = AuthUser.fromJson(jsonDecode(userJson));
        if (_currentUser != null) {
          _syncProfileManager(_currentUser!);
          return;
        }
      } catch (_) {}
    }

    // 3. Fallback to active Firebase Auth credentials if session is active
    final fbUser = FirebaseAuthService.currentFirebaseUser;
    if (fbUser != null) {
      final email = fbUser.email ?? '';
      _currentUser = AuthUser(
        id: fbUser.uid,
        email: email,
        fullName: fbUser.displayName ?? 'Acadyk Member',
        username: email.isNotEmpty ? email.split('@').first : 'user',
        roles: const ['STUDENT'],
      );
      _syncProfileManager(_currentUser!);
      await _storage.write(key: 'user_profile', value: jsonEncode(_currentUser!.toJson()));
      await _storage.write(key: 'login_timestamp', value: DateTime.now().millisecondsSinceEpoch.toString());
    }
  }

  static Future<void> saveSession(AuthUser user) async {
    _currentUser = user;
    _syncProfileManager(user);
    await _storage.write(key: 'user_profile', value: jsonEncode(user.toJson()));
    await _storage.write(key: 'login_timestamp', value: DateTime.now().millisecondsSinceEpoch.toString());
  }

  static void _syncProfileManager(AuthUser user) {
    final extractedBranch = user.branch ?? _extractBranch(user.enrollmentNumber);
    ProfileManager.setAuthenticatedUser(
      authenticatedName: user.fullName ?? 'Somraj Lodhi',
      authenticatedUsername: user.enrollmentNumber ?? user.username ?? 'somrajlodhi',
      authenticatedBio: user.branch != null ? '${user.degree ?? "B.Tech"} in ${user.branch}' : null,
      authenticatedBranch: extractedBranch,
      authenticatedDegree: user.degree ?? 'B.Tech',
      authenticatedEnrollment: user.enrollmentNumber ?? 'BTAM25O1080',
    );
  }

  static String _extractBranch(String? enrollment) {
    if (enrollment == null || enrollment.isEmpty) return 'AIML';
    final upper = enrollment.toUpperCase();
    if (upper.contains('AM') || upper.contains('AIML')) return 'AIML';
    if (upper.contains('CS') || upper.contains('CSE')) return 'CSE';
    if (upper.contains('IT')) return 'IT';
    if (upper.contains('EC') || upper.contains('ECE')) return 'ECE';
    if (upper.contains('EE')) return 'EE';
    if (upper.contains('ME')) return 'ME';
    if (upper.contains('CE')) return 'Civil';
    return 'AIML';
  }

  static Future<AuthUser?> signInWithEmail(String email, String password) async {
    final data = await FirebaseAuthService.signInWithEmail(email, password);
    final userMap = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    _currentUser = AuthUser.fromJson({
      ...userMap,
      if (data['enrollmentNumber'] != null) 'enrollmentNumber': data['enrollmentNumber'],
      if (data['isFirstLogin'] != null) 'isFirstLogin': data['isFirstLogin'],
      if (data['degree'] != null) 'degree': data['degree'],
      if (data['branch'] != null) 'branch': data['branch'],
      if (data['joiningYear'] != null) 'joiningYear': data['joiningYear'],
    });
    _syncProfileManager(_currentUser!);
    await _storage.write(key: 'user_profile', value: jsonEncode(_currentUser!.toJson()));
    await _storage.write(key: 'login_timestamp', value: DateTime.now().millisecondsSinceEpoch.toString());
    return _currentUser;
  }

  static Future<AuthUser?> signUpWithEmail(String email, String password, {String? fullName}) async {
    final data = await FirebaseAuthService.signUpWithEmail(email, password, fullName: fullName);
    final userMap = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    _currentUser = AuthUser.fromJson({
      ...userMap,
      if (data['enrollmentNumber'] != null) 'enrollmentNumber': data['enrollmentNumber'],
      if (data['isFirstLogin'] != null) 'isFirstLogin': data['isFirstLogin'],
      if (data['degree'] != null) 'degree': data['degree'],
      if (data['branch'] != null) 'branch': data['branch'],
      if (data['joiningYear'] != null) 'joiningYear': data['joiningYear'],
    });
    _syncProfileManager(_currentUser!);
    await _storage.write(key: 'user_profile', value: jsonEncode(_currentUser!.toJson()));
    await _storage.write(key: 'login_timestamp', value: DateTime.now().millisecondsSinceEpoch.toString());
    return _currentUser;
  }

  static Future<AuthUser?> signInWithGoogle() async {
    final data = await FirebaseAuthService.signInWithGoogle();
    if (data == null) return null;
    final userMap = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;
    _currentUser = AuthUser.fromJson({
      ...userMap,
      if (data['enrollmentNumber'] != null) 'enrollmentNumber': data['enrollmentNumber'],
      if (data['isFirstLogin'] != null) 'isFirstLogin': data['isFirstLogin'],
      if (data['degree'] != null) 'degree': data['degree'],
      if (data['branch'] != null) 'branch': data['branch'],
      if (data['joiningYear'] != null) 'joiningYear': data['joiningYear'],
    });
    _syncProfileManager(_currentUser!);
    await _storage.write(key: 'user_profile', value: jsonEncode(_currentUser!.toJson()));
    await _storage.write(key: 'login_timestamp', value: DateTime.now().millisecondsSinceEpoch.toString());
    return _currentUser;
  }

  static Future<void> sendPasswordReset(String email) async {
    await FirebaseAuthService.sendPasswordReset(email);
  }

  static Future<void> sendEmailVerification() async {
    await FirebaseAuthService.sendEmailVerification();
  }

  static Future<void> signOut() async {
    await FirebaseAuthService.signOut();
    try {
      await _storage.deleteAll();
    } catch (_) {}
    _currentUser = null;
  }

  static Future<void> deleteAccount() async {
    await FirebaseAuthService.deleteAccount();
    try {
      await _storage.deleteAll();
    } catch (_) {}
    _currentUser = null;
  }
}
