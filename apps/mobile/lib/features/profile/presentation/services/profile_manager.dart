import 'package:flutter/material.dart';
import '../../../../common/services/profile_service.dart';
import '../../../../common/services/auth_service.dart';

class ProfileManager {
  static String name = 'Somraj Lodhi';
  static String username = 'somrajlodhi';
  static String enrollmentNumber = 'BTAM25O1080';
  static String branch = 'AIML';
  static String degree = 'B.Tech';
  static String bio = 'Founder | Thinker | Quant Engineer. Covering worldwide action. DM for collabs.';
  static String location = 'India';
  static String website = 'http://www.quantaforze.com';
  static String dateOfBirth = 'June 1, 2006';
  static String avatarUrl = 'assets/images/somraj_avatar.jpg';
  static String bannerUrl = 'assets/images/young_entrepreneur.jpg';
  static bool isVerified = false;

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
  }) {
    name = newName;
    bio = newBio;
    location = newLocation;
    website = newWebsite;
    dateOfBirth = newDateOfBirth;
    if (newAvatar != null) avatarUrl = newAvatar;
    if (newBanner != null) bannerUrl = newBanner;
    
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
    String? authenticatedAvatar,
    String? authenticatedBio,
    String? authenticatedLocation,
    String? authenticatedBranch,
    String? authenticatedDegree,
    String? authenticatedEnrollment,
  }) {
    if (authenticatedName.isNotEmpty) name = authenticatedName;
    if (authenticatedUsername.isNotEmpty) username = authenticatedUsername;
    if (authenticatedAvatar != null && authenticatedAvatar.isNotEmpty) avatarUrl = authenticatedAvatar;
    if (authenticatedBio != null && authenticatedBio.isNotEmpty) bio = authenticatedBio;
    if (authenticatedLocation != null && authenticatedLocation.isNotEmpty) location = authenticatedLocation;
    if (authenticatedBranch != null && authenticatedBranch.isNotEmpty) branch = authenticatedBranch;
    if (authenticatedDegree != null && authenticatedDegree.isNotEmpty) degree = authenticatedDegree;
    if (authenticatedEnrollment != null && authenticatedEnrollment.isNotEmpty) enrollmentNumber = authenticatedEnrollment;
    profileUpdateNotifier.value = !profileUpdateNotifier.value;
  }
}
