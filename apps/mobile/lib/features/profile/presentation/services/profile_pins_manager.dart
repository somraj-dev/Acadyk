import 'package:flutter/material.dart';
import 'profile_manager.dart';

enum PinCategory {
  project,
  experience,
  education,
  club,
  skill,
  responsibility,
  certificate,
  achievement,
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
  final String? highlight;
  bool isPinned;
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
    this.highlight,
    this.isPinned = true,
    this.rawData = const {},
  });

  ProfilePinItem copyWith({
    bool? isPinned,
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
      highlight: highlight,
      isPinned: isPinned ?? this.isPinned,
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
      id: 'club_1',
      category: PinCategory.club,
      title: 'MITS Coding & Open Source Club',
      subtitle: 'President & Founding Core Member',
      organization: 'MITS Campus',
      duration: 'Joined Aug 2023 • Active',
      location: 'College Campus',
      description: 'Official student chapter fostering competitive programming, open source contributions, and internal college hackathons.',
      tags: ['Competitive Programming', 'Git', 'Hackathons'],
      originStatus: PinOriginStatus.joined,
      statusLabel: 'Joined (Active)',
      icon: Icons.terminal_rounded,
      iconBg: const Color(0xFF0F4C81),
      isPinned: true,
      rawData: {
        'name': 'MITS Coding & Open Source Club',
        'role': 'President & Founding Core Member',
        'membersCount': 340,
        'icon': Icons.terminal_rounded,
        'iconBg': const Color(0xFF0F4C81),
      },
    ),
    ProfilePinItem(
      id: 'club_2',
      category: PinCategory.club,
      title: 'Robotics and Innovation Society',
      subtitle: 'Autonomous Systems Hardware Contributor',
      organization: 'Tech Club',
      duration: 'Joined Oct 2023 • Active',
      location: 'Robotics Center',
      description: 'Student engineering society working on competitive robotics, quadcopters, and IoT automation projects.',
      tags: ['Robotics', 'Hardware', 'Sensors'],
      originStatus: PinOriginStatus.joined,
      statusLabel: 'Joined (Active)',
      icon: Icons.smart_toy_outlined,
      iconBg: const Color(0xFF059669),
      isPinned: true,
      rawData: {
        'name': 'Robotics and Innovation Society',
        'role': 'Autonomous Systems Hardware Contributor',
        'membersCount': 185,
        'icon': Icons.smart_toy_outlined,
        'iconBg': const Color(0xFF059669),
      },
    ),
    ProfilePinItem(
      id: 'club_3',
      category: PinCategory.club,
      title: 'IEEE Student Chapter MITS',
      subtitle: 'Event Coordinator & Organizing Committee',
      organization: 'IEEE Global',
      duration: 'Completed Term (2023 - 2024)',
      location: 'MITS Gwalior',
      description: 'Organized national student paper presentations, guest seminars by tech industry leaders, and technical symposia.',
      tags: ['Conferences', 'Seminars', 'IEEE'],
      originStatus: PinOriginStatus.completed,
      statusLabel: 'Completed Term',
      icon: Icons.electric_bolt_rounded,
      iconBg: const Color(0xFFD97706),
      isPinned: false,
      rawData: {
        'name': 'IEEE Student Chapter MITS',
        'role': 'Event Coordinator & Organizing Committee',
        'membersCount': 220,
        'icon': Icons.electric_bolt_rounded,
        'iconBg': const Color(0xFFD97706),
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
    _items.removeWhere((i) => i.id == item.id);
    _items.insert(0, item);
    _notify();
  }

  static void addProjectPin({
    required String title,
    required String subtitle,
    String? organization,
    String? duration,
    String? location,
    String? description,
    List<String> tags = const [],
    PinOriginStatus originStatus = PinOriginStatus.posted,
    String statusLabel = 'Created & Posted',
    bool isPinned = true,
    Map<String, dynamic> rawData = const {},
  }) {
    final id = 'proj_${DateTime.now().millisecondsSinceEpoch}';
    final item = ProfilePinItem(
      id: id,
      category: PinCategory.project,
      title: title,
      subtitle: subtitle.isNotEmpty ? subtitle : (organization ?? 'Project'),
      organization: organization,
      duration: duration,
      location: location,
      description: description,
      tags: tags,
      originStatus: originStatus,
      statusLabel: statusLabel,
      icon: Icons.code_rounded,
      iconBg: const Color(0xFF0284C7),
      isPinned: isPinned,
      rawData: {
        'title': title,
        'time': duration ?? '',
        'duration': duration ?? '',
        'association': organization ?? subtitle,
        'organization': organization ?? '',
        'description': description ?? '',
        'skills': tags.join(', '),
        ...rawData,
      },
    );
    addCustomItem(item);
  }

  static void addExperiencePin({
    required String title,
    required String subtitle,
    String? organization,
    String? duration,
    String? location,
    String? description,
    List<String> tags = const [],
    PinOriginStatus originStatus = PinOriginStatus.active,
    String statusLabel = 'Active Work',
    bool isPinned = true,
    Map<String, dynamic> rawData = const {},
  }) {
    final id = 'exp_${DateTime.now().millisecondsSinceEpoch}';
    final item = ProfilePinItem(
      id: id,
      category: PinCategory.experience,
      title: title,
      subtitle: subtitle.isNotEmpty ? subtitle : (organization ?? 'Company'),
      organization: organization ?? subtitle,
      duration: duration,
      location: location,
      description: description,
      tags: tags,
      originStatus: originStatus,
      statusLabel: statusLabel,
      icon: Icons.business_center_rounded,
      iconBg: const Color(0xFF0F172A),
      isPinned: isPinned,
      rawData: {
        'title': title,
        'company': organization ?? subtitle,
        'organization': organization ?? subtitle,
        'duration': duration ?? '',
        'location': location ?? '',
        'description': description ?? '',
        'skills': tags.join(', '),
        ...rawData,
      },
    );
    addCustomItem(item);
  }

  static void addEducationPin({
    required String school,
    required String degree,
    String? duration,
    String? location,
    String? description,
    List<String> tags = const [],
    PinOriginStatus originStatus = PinOriginStatus.active,
    String statusLabel = 'Enrolled & In Progress',
    bool isPinned = true,
    Map<String, dynamic> rawData = const {},
  }) {
    final id = 'edu_${DateTime.now().millisecondsSinceEpoch}';
    final item = ProfilePinItem(
      id: id,
      category: PinCategory.education,
      title: school,
      subtitle: degree,
      organization: school,
      duration: duration,
      location: location,
      description: description,
      tags: tags,
      originStatus: originStatus,
      statusLabel: statusLabel,
      icon: Icons.school_rounded,
      iconBg: const Color(0xFF0F4C81),
      isPinned: isPinned,
      rawData: {
        'school': school,
        'degree': degree,
        'duration': duration ?? '',
        'location': location ?? '',
        'description': description ?? '',
        ...rawData,
      },
    );
    addCustomItem(item);
  }

  static void addSkillPin({
    required String skillName,
    String? association,
    String? proficiency,
    bool isPinned = true,
  }) {
    final id = 'skill_${DateTime.now().millisecondsSinceEpoch}';
    final item = ProfilePinItem(
      id: id,
      category: PinCategory.skill,
      title: skillName,
      subtitle: association?.isNotEmpty == true ? association! : (proficiency ?? 'Verified Skill'),
      organization: association,
      duration: proficiency,
      description: 'Demonstrated skill on profile',
      tags: [skillName],
      originStatus: PinOriginStatus.active,
      statusLabel: proficiency ?? 'Active Skill',
      icon: Icons.auto_awesome_rounded,
      iconBg: const Color(0xFF10B981),
      isPinned: isPinned,
      rawData: {
        'name': skillName,
        'association': association ?? '',
        'proficiency': proficiency ?? '',
      },
    );
    addCustomItem(item);
  }

  static void addResponsibilityPin({
    required String title,
    required String organization,
    String? duration,
    String? location,
    String? description,
    List<String> tags = const [],
    bool isPinned = true,
  }) {
    final id = 'resp_${DateTime.now().millisecondsSinceEpoch}';
    final item = ProfilePinItem(
      id: id,
      category: PinCategory.responsibility,
      title: title,
      subtitle: organization,
      organization: organization,
      duration: duration,
      location: location,
      description: description,
      tags: tags,
      originStatus: PinOriginStatus.active,
      statusLabel: 'Position of Responsibility',
      icon: Icons.groups_2_rounded,
      iconBg: const Color(0xFF8B5CF6),
      isPinned: isPinned,
      rawData: {
        'title': title,
        'organization': organization,
        'duration': duration ?? '',
        'location': location ?? '',
        'description': description ?? '',
        'skills': tags.join(', '),
      },
    );
    addCustomItem(item);
  }

  static void addCertificatePin({
    required String title,
    required String issuingOrg,
    String? issueDate,
    String? credentialUrl,
    String? description,
    List<String> tags = const [],
    bool isPinned = true,
  }) {
    final id = 'cert_${DateTime.now().millisecondsSinceEpoch}';
    final item = ProfilePinItem(
      id: id,
      category: PinCategory.certificate,
      title: title,
      subtitle: issuingOrg,
      organization: issuingOrg,
      duration: issueDate,
      location: credentialUrl,
      description: description,
      tags: tags,
      originStatus: PinOriginStatus.completed,
      statusLabel: 'Certified',
      icon: Icons.workspace_premium_rounded,
      iconBg: const Color(0xFFEA580C),
      isPinned: isPinned,
      rawData: {
        'title': title,
        'issuingOrg': issuingOrg,
        'issueDate': issueDate ?? '',
        'credentialUrl': credentialUrl ?? '',
        'description': description ?? '',
        'skills': tags.join(', '),
      },
    );
    addCustomItem(item);
  }

  static void addAchievementPin({
    required String title,
    required String issuingOrg,
    String? date,
    String? description,
    List<String> tags = const [],
    bool isPinned = true,
  }) {
    final id = 'achv_${DateTime.now().millisecondsSinceEpoch}';
    final item = ProfilePinItem(
      id: id,
      category: PinCategory.achievement,
      title: title,
      subtitle: issuingOrg,
      organization: issuingOrg,
      duration: date,
      description: description,
      tags: tags,
      originStatus: PinOriginStatus.completed,
      statusLabel: 'Award & Recognition',
      icon: Icons.emoji_events_rounded,
      iconBg: const Color(0xFFF59E0B),
      isPinned: isPinned,
      rawData: {
        'title': title,
        'issuingOrg': issuingOrg,
        'date': date ?? '',
        'description': description ?? '',
        'skills': tags.join(', '),
      },
    );
    addCustomItem(item);
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
      'organization': c.organization ?? '',
      'duration': c.duration ?? '',
      'description': c.description ?? '',
      'membersCount': 100,
      'icon': c.icon,
      'iconBg': c.iconBg,
    }).toList();
  }

  static List<Map<String, String>> getPinnedSkills() {
    final pinned = getPinnedItems(PinCategory.skill);
    return pinned.map((s) => {
      'name': s.title,
      'association': s.subtitle != 'Verified Skill' ? s.subtitle : (s.organization ?? ''),
    }).toList();
  }

  static List<Map<String, dynamic>> getPinnedResponsibilities() {
    final pinned = getPinnedItems(PinCategory.responsibility);
    return pinned.map((r) => {
      'title': r.title,
      'organization': r.organization ?? r.subtitle,
      'duration': r.duration ?? '',
      'location': r.location ?? '',
      'description': r.description ?? '',
      'skills': r.tags.join(', '),
    }).toList();
  }

  static List<Map<String, dynamic>> getPinnedCertificates() {
    final pinned = getPinnedItems(PinCategory.certificate);
    return pinned.map((c) => {
      'title': c.title,
      'issuingOrg': c.organization ?? c.subtitle,
      'issueDate': c.duration ?? '',
      'credentialUrl': c.location ?? '',
      'description': c.description ?? '',
      'skills': c.tags.join(', '),
    }).toList();
  }

  static List<Map<String, dynamic>> getPinnedAchievements() {
    final pinned = getPinnedItems(PinCategory.achievement);
    return pinned.map((a) => {
      'title': a.title,
      'issuingOrg': a.organization ?? a.subtitle,
      'date': a.duration ?? '',
      'description': a.description ?? '',
      'skills': a.tags.join(', '),
    }).toList();
  }

  static void _notify() {
    pinsChangeNotifier.value = !pinsChangeNotifier.value;
    ProfileManager.profileUpdateNotifier.value = !ProfileManager.profileUpdateNotifier.value;
  }
}

