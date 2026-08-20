import 'package:flutter/material.dart';
import 'profile_manager.dart';

enum PinCategory {
  project,
  experience,
  education,
  club,
}

enum PinOriginStatus {
  posted, // Ever posted/created
  joined, // Joined / Participated
  completed, // Completed
  active, // Active / Ongoing
}

class ProfilePinItem {
  final String id;
  final PinCategory category;
  final String title;
  final String subtitle;
  final String? organization;
  final String? duration;
  final String? location;
  final String? description;
  final List<String> tags;
  final PinOriginStatus originStatus;
  final String statusLabel;
  final IconData icon;
  final Color iconBg;
  final String? imageAsset;
  final String? avatarUrl;
  final String? handle;
  final String? highlight;
  bool isPinned;
  bool isFollowing;
  final Map<String, dynamic> rawData;

  ProfilePinItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    this.organization,
    this.duration,
    this.location,
    this.description,
    this.tags = const [],
    this.originStatus = PinOriginStatus.active,
    required this.statusLabel,
    required this.icon,
    this.iconBg = const Color(0xFF0F4C81),
    this.imageAsset,
    this.avatarUrl,
    this.handle,
    this.highlight,
    this.isPinned = true,
    this.isFollowing = true,
    this.rawData = const {},
  });

  ProfilePinItem copyWith({
    bool? isPinned,
    bool? isFollowing,
  }) {
    return ProfilePinItem(
      id: id,
      category: category,
      title: title,
      subtitle: subtitle,
      organization: organization,
      duration: duration,
      location: location,
      description: description,
      tags: tags,
      originStatus: originStatus,
      statusLabel: statusLabel,
      icon: icon,
      iconBg: iconBg,
      imageAsset: imageAsset,
      avatarUrl: avatarUrl,
      handle: handle,
      highlight: highlight,
      isPinned: isPinned ?? this.isPinned,
      isFollowing: isFollowing ?? this.isFollowing,
      rawData: rawData,
    );
  }
}

class ProfilePinsManager {
  static final ValueNotifier<bool> pinsChangeNotifier = ValueNotifier<bool>(false);

  static final List<ProfilePinItem> _items = [
    // -------------------------------------------------------------
    // PROJECTS (Ever posted, created, or joined)
    // -------------------------------------------------------------
    ProfilePinItem(
      id: 'proj_1',
      category: PinCategory.project,
      title: 'Acadyk - College Social & Learning Network',
      subtitle: 'Lead Developer • Mobile & Web Platforms',
      organization: 'Quantaforze Corp',
      duration: 'Jan 2024 – Present',
      location: 'Gwalior, MP',
      description:
          'Engineered real-time collaboration tools, event discovery, campus communities, and high-performance feeds connecting students and organizations.',
      tags: ['Flutter', 'Dart', 'Spring Boot', 'PostgreSQL'],
      originStatus: PinOriginStatus.posted,
      statusLabel: 'Created & Posted',
      icon: Icons.code_rounded,
      iconBg: const Color(0xFF0284C7),
      imageAsset: 'assets/images/acadyk_logo.png',
      isPinned: true,
      rawData: {
        'title': 'Acadyk - College Social & Learning Network',
        'time': 'Jan 2024 – Present',
        'association': 'Quantaforze Corp',
        'description':
            'Engineered real-time collaboration tools, event discovery, campus communities, and high-performance feeds connecting students and organizations.',
        'skills': 'Flutter, Dart, Spring Boot, PostgreSQL',
      },
    ),
    ProfilePinItem(
      id: 'proj_2',
      category: PinCategory.project,
      title: 'AI Smart Campus Navigation System',
      subtitle: 'AR & Computer Vision Navigation for Institutes',
      organization: 'Madhav Institute of Technology and Science',
      duration: 'Aug 2023 – Dec 2023',
      location: 'MITS Campus',
      description:
          'Built an indoor augmented-reality navigation assistant mapping university labs, lecture halls, and facilities with step-by-step route guidance.',
      tags: ['Python', 'OpenCV', 'ARKit', 'Flutter'],
      originStatus: PinOriginStatus.completed,
      statusLabel: 'Completed',
      icon: Icons.map_rounded,
      iconBg: const Color(0xFF059669),
      imageAsset: 'assets/images/mits_logo.png',
      isPinned: true,
      rawData: {
        'title': 'AI Smart Campus Navigation System',
        'time': 'Aug 2023 – Dec 2023',
        'association': 'Madhav Institute of Technology and Science',
        'description':
            'Built an indoor augmented-reality navigation assistant mapping university labs, lecture halls, and facilities with step-by-step route guidance.',
        'skills': 'Python, OpenCV, ARKit, Flutter',
      },
    ),
    ProfilePinItem(
      id: 'proj_3',
      category: PinCategory.project,
      title: 'Autonomous Rover & Sensor Telemetry Hub',
      subtitle: 'Embedded Robotics & Live Telemetry Dashboard',
      organization: 'Robotics & Innovation Society',
      duration: 'May 2023 – Oct 2023',
      location: 'Robotics Lab',
      description:
          'Collaborated with a 6-member robotics team to develop automated obstacle avoidance, LiDAR point clouds, and live cloud telemetry.',
      tags: ['C++', 'ROS 2', 'LiDAR', 'MQTT'],
      originStatus: PinOriginStatus.joined,
      statusLabel: 'Joined & Contributed',
      icon: Icons.smart_toy_rounded,
      iconBg: const Color(0xFF7C3AED),
      imageAsset: 'assets/images/mits_logo.png',
      isPinned: true,
      rawData: {
        'title': 'Autonomous Rover & Sensor Telemetry Hub',
        'time': 'May 2023 – Oct 2023',
        'association': 'Robotics & Innovation Society',
        'description':
            'Collaborated with a 6-member robotics team to develop automated obstacle avoidance, LiDAR point clouds, and live cloud telemetry.',
        'skills': 'C++, ROS 2, LiDAR, MQTT',
      },
    ),

    // -------------------------------------------------------------
    // WORK EXPERIENCE (Ever held, posted, or active)
    // -------------------------------------------------------------
    ProfilePinItem(
      id: 'exp_1',
      category: PinCategory.experience,
      title: 'Full Stack Software Engineer Intern',
      subtitle: 'Quantaforze Corp',
      organization: 'Quantaforze Corp',
      duration: 'Jan 2024 – Present',
      location: 'Bengaluru, Karnataka (Remote)',
      description:
          'Developing enterprise cloud APIs, microservice integrations, and user-facing mobile interfaces with Flutter and Kotlin.',
      tags: ['Spring Boot', 'Flutter', 'Docker', 'PostgreSQL'],
      originStatus: PinOriginStatus.active,
      statusLabel: 'Active Work',
      highlight: 'Built scalable real-time feed architecture serving 10k+ requests',
      icon: Icons.business_center_rounded,
      iconBg: const Color(0xFF0F4C81),
      imageAsset: 'assets/images/quantaforze_logo.png',
      isPinned: true,
      rawData: {
        'title': 'Full Stack Software Engineer Intern',
        'company': 'Quantaforze Corp',
        'duration': 'Jan 2024 – Present',
        'location': 'Bengaluru, Karnataka (Remote)',
        'highlight': 'Built scalable real-time feed architecture serving 10k+ requests',
        'logo': 'assets/images/quantaforze_logo.png',
      },
    ),
    ProfilePinItem(
      id: 'exp_2',
      category: PinCategory.experience,
      title: 'Student Technical Lead & Mentor',
      subtitle: 'Developer Student Clubs - MITS Chapter',
      organization: 'Google Developer Student Clubs',
      duration: 'Aug 2023 – Jun 2024',
      location: 'Gwalior, MP',
      description:
          'Organized 12+ hands-on tech workshops on Flutter, Cloud, and Web Development for over 450 engineering undergraduates.',
      tags: ['Community', 'Mentorship', 'Workshops', 'Cloud'],
      originStatus: PinOriginStatus.completed,
      statusLabel: 'Completed Term',
      highlight: 'Mentored 150+ students in open-source hackathons',
      icon: Icons.workspace_premium_rounded,
      iconBg: const Color(0xFFD97706),
      imageAsset: 'assets/images/mits_logo.png',
      isPinned: true,
      rawData: {
        'title': 'Student Technical Lead & Mentor',
        'company': 'Developer Student Clubs - MITS Chapter',
        'duration': 'Aug 2023 – Jun 2024',
        'location': 'Gwalior, MP',
        'highlight': 'Mentored 150+ students in open-source hackathons',
        'logo': 'assets/images/mits_logo.png',
      },
    ),

    // -------------------------------------------------------------
    // EDUCATION (Ever attended or completed)
    // -------------------------------------------------------------
    ProfilePinItem(
      id: 'edu_1',
      category: PinCategory.education,
      title: 'Madhav Institute of Technology and Science, Gwalior',
      subtitle: 'Bachelor of Technology • Computer Science & Engineering',
      organization: 'MITS Gwalior',
      duration: '2025 – 2029',
      location: 'Gwalior, Madhya Pradesh',
      description: 'Majoring in Computer Science & Engineering with focus on Software Systems, Distributed Architectures, and AI.',
      tags: ['Data Structures', 'Algorithms', 'DBMS', 'OS'],
      originStatus: PinOriginStatus.active,
      statusLabel: 'Enrolled & In Progress',
      icon: Icons.school_rounded,
      iconBg: const Color(0xFF0F4C81),
      imageAsset: 'assets/images/mits_logo.png',
      isPinned: true,
      rawData: {
        'school': 'Madhav Institute of Technology and Science, Gwalior',
        'degree': 'Bachelor of Technology, Computer Science & Engineering',
        'duration': '2025 – 2029',
      },
    ),
    ProfilePinItem(
      id: 'edu_2',
      category: PinCategory.education,
      title: 'Delhi Public School',
      subtitle: 'Senior Secondary Education (Class XII - PCM with CS)',
      organization: 'CBSE Board',
      duration: '2023 – 2025',
      location: 'Gwalior, MP',
      description: 'Graduated with distinction in Physics, Chemistry, Mathematics, and Computer Science.',
      tags: ['Science', 'Computer Science', 'Mathematics'],
      originStatus: PinOriginStatus.completed,
      statusLabel: 'Completed',
      icon: Icons.history_edu_rounded,
      iconBg: const Color(0xFF475569),
      imageAsset: 'assets/images/mits_logo.png',
      isPinned: true,
      rawData: {
        'school': 'Delhi Public School',
        'degree': 'Senior Secondary Education (Class XII - PCM with CS)',
        'duration': '2023 – 2025',
      },
    ),

    // -------------------------------------------------------------
    // CLUBS & ORGANIZATIONS (Ever joined, created, or completed)
    // -------------------------------------------------------------
    ProfilePinItem(
      id: 'club_gdg',
      category: PinCategory.club,
      title: 'Google Developer Groups',
      subtitle: 'GDG on Campus MITS Chapter',
      handle: '@GDGMITS',
      organization: 'MITS Gwalior',
      duration: 'Active Chapter • Joined Aug 2023',
      location: 'MITS Campus',
      description: 'GDG on Campus · MITS Gwalior Chapter | Building for developers',
      tags: ['Android', 'Cloud', 'Flutter', 'AI/ML'],
      originStatus: PinOriginStatus.joined,
      statusLabel: 'Joined (Active)',
      icon: Icons.code_rounded,
      iconBg: const Color(0xFF0F4C81),
      avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=120',
      isPinned: true,
      isFollowing: true,
      rawData: {
        'name': 'Google Developer Groups',
        'handle': '@GDGMITS',
        'avatarUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=120',
        'isFollowing': true,
      },
    ),
    ProfilePinItem(
      id: 'club_sdc',
      category: PinCategory.club,
      title: 'Student Development Cell',
      subtitle: 'Official Student Council',
      handle: '@SDCMITS',
      organization: 'MITS-DU',
      duration: 'Active Council • Joined Oct 2023',
      location: 'Student Activity Center',
      description: 'Official Student Council for Innovation, Hackathons & Tech at MITS-DU',
      tags: ['Hackathons', 'Innovation', 'Student Council'],
      originStatus: PinOriginStatus.joined,
      statusLabel: 'Joined (Active)',
      icon: Icons.hub_rounded,
      iconBg: const Color(0xFF059669),
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120',
      isPinned: true,
      isFollowing: true,
      rawData: {
        'name': 'Student Development Cell',
        'handle': '@SDCMITS',
        'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120',
        'isFollowing': true,
      },
    ),
    ProfilePinItem(
      id: 'club_acm',
      category: PinCategory.club,
      title: 'ACM Student Chapter',
      subtitle: 'Association for Computing Machinery',
      handle: '@ACMMITS',
      organization: 'ACM International',
      duration: 'Active Chapter',
      location: 'Computer Science Dept',
      description: 'Association for Computing Machinery · Student Chapter at MITS Gwalior',
      tags: ['Algorithms', 'Research', 'ACM ICPC'],
      originStatus: PinOriginStatus.joined,
      statusLabel: 'Joined (Active)',
      icon: Icons.terminal_rounded,
      iconBg: const Color(0xFF6366F1),
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120',
      isPinned: true,
      isFollowing: true,
      rawData: {
        'name': 'ACM Student Chapter',
        'handle': '@ACMMITS',
        'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120',
        'isFollowing': true,
      },
    ),
    ProfilePinItem(
      id: 'club_alina',
      category: PinCategory.club,
      title: 'Alina Sprongole',
      subtitle: 'Software Engineer @ Google',
      handle: '@AlinaSprongole',
      organization: 'Google Developer Community',
      duration: 'Tech Lead & Mentor',
      location: 'Mountain View, CA',
      description: 'Software Engineer @ Google | Tech Lead',
      tags: ['Google', 'Mentorship', 'Cloud'],
      originStatus: PinOriginStatus.active,
      statusLabel: 'Active Mentor',
      icon: Icons.person_rounded,
      iconBg: const Color(0xFFD97706),
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=120',
      isPinned: false,
      isFollowing: true,
      rawData: {
        'name': 'Alina Sprongole',
        'handle': '@AlinaSprongole',
        'avatarUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=120',
        'isFollowing': true,
      },
    ),
    ProfilePinItem(
      id: 'club_1',
      category: PinCategory.club,
      title: 'MITS Coding & Open Source Club',
      subtitle: 'President & Founding Core Member',
      handle: '@MITS_OpenSource',
      organization: 'MITS Campus',
      duration: 'Joined Aug 2023 • Active',
      location: 'College Campus',
      description: 'Official student chapter fostering competitive programming, open source contributions, and internal college hackathons.',
      tags: ['Competitive Programming', 'Git', 'Hackathons'],
      originStatus: PinOriginStatus.joined,
      statusLabel: 'Joined (Active)',
      icon: Icons.terminal_rounded,
      iconBg: const Color(0xFF0F4C81),
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120',
      isPinned: false,
      isFollowing: true,
      rawData: {
        'name': 'MITS Coding & Open Source Club',
        'handle': '@MITS_OpenSource',
        'role': 'President & Founding Core Member',
        'membersCount': 340,
        'icon': Icons.terminal_rounded,
        'iconBg': const Color(0xFF0F4C81),
      },
    ),
  ];

  static List<ProfilePinItem> getAllItems([PinCategory? category]) {
    if (category == null) {
      return List.unmodifiable(_items);
    }
    return _items.where((item) => item.category == category).toList();
  }

  static List<ProfilePinItem> getPinnedItems([PinCategory? category]) {
    if (category == null) {
      return _items.where((item) => item.isPinned).toList();
    }
    return _items.where((item) => item.category == category && item.isPinned).toList();
  }

  static const int maxPinsAllowed = 10;

  static int get totalCount => _items.length;
  static int get pinnedCount => _items.where((item) => item.isPinned).length;

  static int countByCategory(PinCategory cat) => _items.where((item) => item.category == cat).length;
  static int pinnedByCategory(PinCategory cat) => _items.where((item) => item.category == cat && item.isPinned).length;

  static bool isPinned(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      return _items[index].isPinned;
    }
    return false;
  }

  static ProfilePinItem? getItemById(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    return index != -1 ? _items[index] : null;
  }

  static bool togglePin(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final willPin = !_items[index].isPinned;
      if (willPin && pinnedCount >= maxPinsAllowed) {
        return false;
      }
      _items[index].isPinned = willPin;
      _notify();
      return true;
    }
    return false;
  }

  static bool setPin(String id, bool pinned) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1 && _items[index].isPinned != pinned) {
      if (pinned && pinnedCount >= maxPinsAllowed) {
        return false;
      }
      _items[index].isPinned = pinned;
      _notify();
      return true;
    }
    return true;
  }

  static void pinAll([PinCategory? category]) {
    for (var item in _items) {
      if (category == null || item.category == category) {
        item.isPinned = true;
      }
    }
    _notify();
  }

  static void unpinAll([PinCategory? category]) {
    for (var item in _items) {
      if (category == null || item.category == category) {
        item.isPinned = false;
      }
    }
    _notify();
  }

  static void addCustomItem(ProfilePinItem item) {
    _items.insert(0, item);
    _notify();
  }

  static List<Map<String, dynamic>> getPinnedProjects() {
    final pinned = getPinnedItems(PinCategory.project);
    return pinned.map((p) => {
      'title': p.title,
      'time': p.duration ?? '',
      'duration': p.duration ?? '',
      'association': p.organization ?? p.subtitle,
      'organization': p.organization ?? '',
      'description': p.description ?? '',
      'skills': p.tags.join(', '),
      'highlight': p.highlight ?? '',
    }).toList();
  }

  static List<Map<String, dynamic>> getPinnedExperiences() {
    final pinned = getPinnedItems(PinCategory.experience);
    return pinned.map((e) => {
      'title': e.title,
      'company': e.organization ?? e.subtitle,
      'organization': e.organization ?? '',
      'duration': e.duration ?? '',
      'location': e.location ?? '',
      'highlight': e.highlight,
      'logo': e.imageAsset,
      'description': e.description ?? '',
    }).toList();
  }

  static List<Map<String, dynamic>> getPinnedEducation() {
    final pinned = getPinnedItems(PinCategory.education);
    return pinned.map((edu) => {
      'school': edu.title,
      'degree': edu.subtitle,
      'duration': edu.duration ?? '',
      'location': edu.location ?? '',
      'description': edu.description ?? '',
    }).toList();
  }

  static List<Map<String, dynamic>> getPinnedClubs() {
    final pinned = getPinnedItems(PinCategory.club);
    return pinned.map((c) => {
      'name': c.title,
      'title': c.title,
      'role': c.subtitle,
      'subtitle': c.subtitle,
      'handle': c.handle ?? '@${c.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase()}',
      'avatarUrl': c.avatarUrl ?? c.imageAsset,
      'organization': c.organization ?? '',
      'duration': c.duration ?? '',
      'description': c.description ?? '',
      'membersCount': 100,
      'isFollowing': c.isFollowing,
      'icon': c.icon,
      'iconBg': c.iconBg,
    }).toList();
  }

  static void _notify() {
    pinsChangeNotifier.value = !pinsChangeNotifier.value;
    ProfileManager.profileUpdateNotifier.value = !ProfileManager.profileUpdateNotifier.value;
  }
}
