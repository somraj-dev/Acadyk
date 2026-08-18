import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../common/services/profile_service.dart';
import '../../../../common/services/auth_service.dart';

class ProfileManager {
  static String name = '';
  static String username = '';
  static String email = '';
  static String enrollmentNumber = '';
  static String branch = '';
  static String degree = '';
  static String bio = '';
  static String summary = '';
  static String location = '';
  static String website = '';
  static String dateOfBirth = '';
  static String avatarUrl = '';
  static String bannerUrl = '';
  static Uint8List? avatarBytes;
  static Uint8List? bannerBytes;
  static bool isVerified = false;

  static int followersCount = 0;
  static int followingCount = 0;
  static int postsCount = 0;

  static List<Map<String, dynamic>> experiences = [];
  static List<Map<String, dynamic>> projects = [];
  static List<Map<String, String>> skills = [];
  static List<Map<String, dynamic>> clubs = [];
  static List<Map<String, dynamic>> education = [];

  static final ValueNotifier<bool> profileUpdateNotifier = ValueNotifier<bool>(false);

  static void setVerified(bool value) {
    isVerified = value;
    profileUpdateNotifier.value = !profileUpdateNotifier.value;
  }

  static void updateProfile({
    required String newName,
    required String newBio,
    required String newLocation,
    required String newWebsite,
    required String newDateOfBirth,
    String? newAvatar,
    String? newBanner,
    Uint8List? newAvatarBytes,
    Uint8List? newBannerBytes,
  }) {
    name = newName;
    bio = newBio;
    location = newLocation;
    website = newWebsite;
    dateOfBirth = newDateOfBirth;
    if (newAvatar != null) avatarUrl = newAvatar;
    if (newBanner != null) bannerUrl = newBanner;
    if (newAvatarBytes != null) avatarBytes = newAvatarBytes;
    if (newBannerBytes != null) bannerBytes = newBannerBytes;
    
    // Trigger listeners across the app
    profileUpdateNotifier.value = !profileUpdateNotifier.value;

    // Synchronize to PostgreSQL via Spring Boot REST backend
    final currentUserId = AuthService.currentUser?.id;
    if (currentUserId != null) {
      ProfileService.updateProfile(currentUserId, {
        'fullName': newName,
        'bio': newBio,
        'location': newLocation,
        'website': newWebsite,
        if (newAvatar != null) 'profilePhotoUrl': newAvatar,
        if (newBanner != null) 'coverPhotoUrl': newBanner,
      }).catchError((e) {
        debugPrint('[ProfileManager] Backend profile sync warning: $e');
      });
    }
  }

  static void setAuthenticatedUser({
    required String authenticatedName,
    required String authenticatedUsername,
    String? authenticatedEmail,
    String? authenticatedAvatar,
    String? authenticatedBio,
    String? authenticatedLocation,
    String? authenticatedBranch,
    String? authenticatedDegree,
    String? authenticatedEnrollment,
  }) {
    if (authenticatedName.isNotEmpty) name = authenticatedName;
    if (authenticatedUsername.isNotEmpty) username = authenticatedUsername;
    if (authenticatedEmail != null && authenticatedEmail.isNotEmpty) email = authenticatedEmail;
    if (authenticatedAvatar != null && authenticatedAvatar.isNotEmpty) avatarUrl = authenticatedAvatar;
    if (authenticatedBio != null && authenticatedBio.isNotEmpty) bio = authenticatedBio;
    if (authenticatedLocation != null && authenticatedLocation.isNotEmpty) location = authenticatedLocation;
    if (authenticatedBranch != null && authenticatedBranch.isNotEmpty) branch = authenticatedBranch;
    if (authenticatedDegree != null && authenticatedDegree.isNotEmpty) degree = authenticatedDegree;
    if (authenticatedEnrollment != null && authenticatedEnrollment.isNotEmpty) enrollmentNumber = authenticatedEnrollment;
    profileUpdateNotifier.value = !profileUpdateNotifier.value;
  }

  /// Populate all profile fields from a backend profile response map.
  static void loadFromProfileData(Map<String, dynamic> data) {
    if (data['full_name'] != null && data['full_name'].toString().isNotEmpty) name = data['full_name'].toString();
    if (data['fullName'] != null && data['fullName'].toString().isNotEmpty) name = data['fullName'].toString();
    if (data['username'] != null && data['username'].toString().isNotEmpty) username = data['username'].toString();
    if (data['email'] != null && data['email'].toString().isNotEmpty) email = data['email'].toString();
    if (data['bio'] != null && data['bio'].toString().isNotEmpty) bio = data['bio'].toString();
    if (data['summary'] != null && data['summary'].toString().isNotEmpty) summary = data['summary'].toString();
    if (data['location'] != null && data['location'].toString().isNotEmpty) location = data['location'].toString();
    if (data['website'] != null && data['website'].toString().isNotEmpty) website = data['website'].toString();
    if (data['date_of_birth'] != null && data['date_of_birth'].toString().isNotEmpty) dateOfBirth = data['date_of_birth'].toString();
    if (data['dateOfBirth'] != null && data['dateOfBirth'].toString().isNotEmpty) dateOfBirth = data['dateOfBirth'].toString();
    if (data['profile_photo_url'] != null && data['profile_photo_url'].toString().isNotEmpty) avatarUrl = data['profile_photo_url'].toString();
    if (data['profilePhotoUrl'] != null && data['profilePhotoUrl'].toString().isNotEmpty) avatarUrl = data['profilePhotoUrl'].toString();
    if (data['cover_photo_url'] != null && data['cover_photo_url'].toString().isNotEmpty) bannerUrl = data['cover_photo_url'].toString();
    if (data['coverPhotoUrl'] != null && data['coverPhotoUrl'].toString().isNotEmpty) bannerUrl = data['coverPhotoUrl'].toString();
    if (data['enrollment_number'] != null && data['enrollment_number'].toString().isNotEmpty) enrollmentNumber = data['enrollment_number'].toString();
    if (data['enrollmentNumber'] != null && data['enrollmentNumber'].toString().isNotEmpty) enrollmentNumber = data['enrollmentNumber'].toString();
    if (data['branch'] != null && data['branch'].toString().isNotEmpty) branch = data['branch'].toString();
    if (data['major'] != null && data['major'].toString().isNotEmpty) branch = data['major'].toString();
    if (data['degree'] != null && data['degree'].toString().isNotEmpty) degree = data['degree'].toString();
    if (data['is_verified'] == true || data['isVerified'] == true) isVerified = true;

    if (data['followers_count'] is int) followersCount = data['followers_count'];
    if (data['followersCount'] is int) followersCount = data['followersCount'];
    if (data['following_count'] is int) followingCount = data['following_count'];
    if (data['followingCount'] is int) followingCount = data['followingCount'];
    if (data['posts_count'] is int) postsCount = data['posts_count'];
    if (data['postsCount'] is int) postsCount = data['postsCount'];

    // List fields
    if (data['experiences'] is List) {
      experiences = List<Map<String, dynamic>>.from(
        (data['experiences'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    if (data['projects'] is List) {
      projects = List<Map<String, dynamic>>.from(
        (data['projects'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    if (data['skills'] is List) {
      final rawSkills = data['skills'] as List;
      skills = rawSkills.map((s) {
        if (s is Map) {
          return Map<String, String>.from(s.map((k, v) => MapEntry(k.toString(), v.toString())));
        }
        return <String, String>{'name': s.toString(), 'association': ''};
      }).toList();
    }
    if (data['clubs'] is List) {
      clubs = List<Map<String, dynamic>>.from(
        (data['clubs'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    if (data['education'] is List) {
      education = List<Map<String, dynamic>>.from(
        (data['education'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }

    profileUpdateNotifier.value = !profileUpdateNotifier.value;
  }

  /// Reset all profile fields to empty defaults (called on sign-out).
  static void resetToDefaults() {
    name = '';
    username = '';
    email = '';
    enrollmentNumber = '';
    branch = '';
    degree = '';
    bio = '';
    summary = '';
    location = '';
    website = '';
    dateOfBirth = '';
    avatarUrl = '';
    bannerUrl = '';
    avatarBytes = null;
    bannerBytes = null;
    isVerified = false;
    followersCount = 0;
    followingCount = 0;
    postsCount = 0;
    experiences = [];
    projects = [];
    skills = [];
    clubs = [];
    education = [];
    profileUpdateNotifier.value = !profileUpdateNotifier.value;
  }
}
