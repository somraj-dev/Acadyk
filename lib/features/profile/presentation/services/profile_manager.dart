import 'package:flutter/material.dart';

class ProfileManager {
  static String name = 'Somraj Lodhi';
  static String bio = 'Founder | Thinker | Quant Engineer. Covering worldwide action. DM for collabs.';
  static String location = 'India';
  static String website = 'http://www.quantaforze.com';
  static String dateOfBirth = 'June 1, 2006';
  static String avatarUrl = 'assets/images/somraj_avatar.jpg';
  static String bannerUrl = 'assets/images/young_entrepreneur.jpg'; // Default banner asset

  static final ValueNotifier<bool> profileUpdateNotifier = ValueNotifier<bool>(false);

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
  }
}
