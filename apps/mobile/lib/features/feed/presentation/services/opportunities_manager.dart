import 'package:flutter/material.dart';
import '../../../../common/services/event_service.dart';

class OpportunitiesManager {
  static final ValueNotifier<List<Map<String, dynamic>>> opportunitiesNotifier = ValueNotifier<List<Map<String, dynamic>>>(_defaultOpportunities);

  static final List<Map<String, dynamic>> _defaultOpportunities = [
    {
      'title': 'DevSprint Hackathon',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&auto=format&fit=crop',
      'organizer': 'DevSprint Hackathon Organizers',
      'timeAgo': '2h ago',
      'tagline': 'Join us for DevSprint 2025 – a 36-hour hackathon to build innovative solutions, collaborate, and win prizes worth \$10,000+.',
      'dates': '12-13 July 2025\nSat, 9:00 AM',
      'location': 'Bangalore, India\nIn-person',
      'teamSizeText': '4-6 Members\nTeam Size',
      'tags': ['Hackathon', 'Tech Event', 'Innovation', 'Open to All'],
      'prizePool': '\$10,000+',
      'likes': 342,
      'comments': 28,
      'event': {
        'title': 'DevSprint Hackathon 2025',
        'organizer': 'DevSprint Hackathon Organizers',
        'bannerUrl': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=80&auto=format&fit=crop',
        'teamSize': 'Team (4-6 Members)',
        'registered': 1890,
        'prizes': 'Prize Pool worth \$10,000+',
        'eligibility': 'Open to all students, working professionals, and developers globally.',
        'description': 'DevSprint 2025 is a premium 36-hour hackathon designed to spur creativity, foster team collaborations, and challenge developers to engineer scalable digital solutions. Top ideas will gain VC mentorship and product development grants.',
        'timeline': [
          {
            'day': '12',
            'month': 'JUL',
            'title': 'Hacking Starts',
            'startDate': '12 Jul 25, 09:00 AM IST',
            'endDate': '13 Jul 25, 09:00 PM IST',
            'isLive': true,
            'desc': '36 hours of non-stop coding, build sprints, and project reviews.'
          }
        ]
      }
    },
    {
      'title': 'Google Summer of Code Info Session',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800&auto=format&fit=crop',
      'organizer': 'OpenSource Hub',
      'timeAgo': '1d ago',
      'tagline': 'Get ready to dive into the world of open-source contributions. Learn how to draft a winning proposal from past GSoC mentors and contributors.',
      'dates': '18 July 2025\nFri, 6:00 PM',
      'location': 'Online\nZoom Webinar',
      'teamSizeText': 'Individual\nParticipation',
      'tags': ['Webinar', 'Open Source', 'Mentorship', 'Free'],
      'prizePool': 'Certificates & Perks',
      'likes': 812,
      'comments': 64,
      'event': {
        'title': 'Google Summer of Code Info Session 2025',
        'organizer': 'OpenSource Hub',
        'bannerUrl': 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=80&auto=format&fit=crop',
        'teamSize': 'Individual Participation',
        'registered': 3420,
        'prizes': 'Certificates & Open Source Perks',
        'eligibility': 'Open to all aspiring open source contributors and students.',
        'description': 'Master the proposal creation process, interact with veteran GSoC developers, and discover the best practices for contributing to organizations.',
        'timeline': [
          {
            'day': '18',
            'month': 'JUL',
            'title': 'Live Webinar',
            'startDate': '18 Jul 25, 06:00 PM IST',
            'endDate': '18 Jul 25, 08:30 PM IST',
            'isLive': true,
            'desc': 'Interactive session with Q&A round led by open source maintainers.'
          }
        ]
      }
    }
  ];

  static final Set<String> _hiddenOpportunityTitles = {};
  static final Set<String> _hiddenOrganizers = {};

  static void addOpportunity(Map<String, dynamic> op) {
    final list = List<Map<String, dynamic>>.from(opportunitiesNotifier.value);
    list.insert(0, op);
    opportunitiesNotifier.value = list;
  }

  static void hideOpportunity(String title) {
    _hiddenOpportunityTitles.add(title.toLowerCase().trim());
    _filterOutHidden();
  }

  static void unhideOpportunity(String title) {
    _hiddenOpportunityTitles.remove(title.toLowerCase().trim());
    loadFromBackend();
  }

  static void hideOrganizer(String organizer) {
    _hiddenOrganizers.add(organizer.toLowerCase().trim());
    _filterOutHidden();
  }

  static void unhideOrganizer(String organizer) {
    _hiddenOrganizers.remove(organizer.toLowerCase().trim());
    loadFromBackend();
  }

  static void _filterOutHidden() {
    final list = opportunitiesNotifier.value.where((op) {
      final t = (op['title'] ?? '').toString().toLowerCase().trim();
      final o = (op['organizer'] ?? '').toString().toLowerCase().trim();
      return !_hiddenOpportunityTitles.contains(t) && !_hiddenOrganizers.contains(o);
    }).toList();
    opportunitiesNotifier.value = list;
  }

  static void loadFromBackend() async {
    try {
      final events = await EventService.getEvents();
      if (events.isNotEmpty) {
        opportunitiesNotifier.value = events.where((op) {
          final t = (op['title'] ?? '').toString().toLowerCase().trim();
          final o = (op['organizer'] ?? '').toString().toLowerCase().trim();
          return !_hiddenOpportunityTitles.contains(t) && !_hiddenOrganizers.contains(o);
        }).toList();
      } else {
        _filterOutHidden();
      }
    } catch (e) {
      debugPrint('[OpportunitiesManager] Backend load note: $e');
    }
  }
}
