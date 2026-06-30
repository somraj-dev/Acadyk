import 'package:flutter/material.dart';

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
    },
    {
      'title': 'InnovateX Design Challenge',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=800&auto=format&fit=crop',
      'organizer': 'Design Syndicate',
      'timeAgo': '3d ago',
      'tagline': 'Showcase your UI/UX and product design skills in our annual 48-hour sprint. Solve real-world user design problems and win exclusive tech setups.',
      'dates': '25-27 July 2025\nFri, 5:00 PM',
      'location': 'Mumbai, India\nHybrid',
      'teamSizeText': '1-3 Members\nTeam Size',
      'tags': ['UI/UX Design', 'Hackathon', 'Product Sprint', 'Global'],
      'prizePool': '₹ 5,00,000',
      'likes': 429,
      'comments': 39,
      'event': {
        'title': 'InnovateX Design Challenge 2025',
        'organizer': 'Design Syndicate',
        'bannerUrl': 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=80&auto=format&fit=crop',
        'teamSize': 'Individual or Team (1-3 members)',
        'registered': 1120,
        'prizes': 'Cash Prizes worth ₹ 5,00,000',
        'eligibility': 'Open to all digital product design enthusiasts, students, and professionals.',
        'description': 'InnovateX challenges design thinkers to build empathetic, scalable layouts for social impact apps. Showcase your Figma layouts and design systems.',
        'timeline': [
          {
            'day': '25',
            'month': 'JUL',
            'title': 'Design Sprint Kickoff',
            'startDate': '25 Jul 25, 05:00 PM IST',
            'endDate': '27 Jul 25, 05:00 PM IST',
            'isLive': true,
            'desc': '48-hour design challenge submission phase.'
          }
        ]
      }
    },
    {
      'title': 'Coca-Cola Mantra Challenge',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&auto=format&fit=crop',
      'organizer': 'Coca-Cola India',
      'timeAgo': '4d ago',
      'tagline': 'Step into a high-energy arena where ideas thrive, innovation is celebrated, and entrepreneurial thinking leads the way. Solve global cases.',
      'dates': '05-15 August 2025\nMon, 10:00 AM',
      'location': 'Delhi, India\nIn-person',
      'teamSizeText': '2-3 Members\nTeam Size',
      'tags': ['Business Case', 'Marketing', 'Corporate', 'MBA Students'],
      'prizePool': '₹ 3,25,000',
      'likes': 654,
      'comments': 51,
      'event': {
        'title': 'Coca-Cola Mantra Challenge 2025',
        'organizer': 'Coca-Cola India',
        'bannerUrl': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=80&auto=format&fit=crop',
        'teamSize': 'Team (2-3 Members)',
        'registered': 2450,
        'prizes': 'Prizes worth ₹ 3,25,000',
        'eligibility': 'First-year MBA/PGDM students pursuing full-time programs.',
        'description': 'Mantra Challenge is a business challenge designed to solve critical distribution, supply chain, and marketing problems with real data matrices.',
        'timeline': [
          {
            'day': '05',
            'month': 'AUG',
            'title': 'Case Submission',
            'startDate': '05 Aug 25, 10:00 AM IST',
            'endDate': '15 Aug 25, 11:59 PM IST',
            'isLive': true,
            'desc': 'Review target business metrics and formulate distribution frameworks.'
          }
        ]
      }
    },
    {
      'title': 'AI Innovation Summit 2025',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop',
      'organizer': 'AI Frontier',
      'timeAgo': '1w ago',
      'tagline': 'Join lead AI researchers and developers from top tech companies to discuss the future of generative models, LLM agents, and cognitive architectures.',
      'dates': '20 August 2025\nWed, 9:00 AM',
      'location': 'Online\nYouTube Live',
      'teamSizeText': 'Unlimited\nAttendees',
      'tags': ['Conference', 'Artificial Intel', 'Future Tech', 'Free'],
      'prizePool': 'Networking & Jobs',
      'likes': 1040,
      'comments': 89,
      'event': {
        'title': 'AI Innovation Summit 2025',
        'organizer': 'AI Frontier',
        'bannerUrl': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=80&auto=format&fit=crop',
        'teamSize': 'Individual Access',
        'registered': 8920,
        'prizes': 'Certificates, Mentorship & Job referrals',
        'eligibility': 'Open to all engineers, researchers, and AI builders globally.',
        'description': 'A one-day summit focused on neural architecture optimizations, prompt design systems, and scaling multi-agent production frameworks.',
        'timeline': [
          {
            'day': '20',
            'month': 'AUG',
            'title': 'Summit Opening Keynote',
            'startDate': '20 Aug 25, 09:00 AM IST',
            'endDate': '20 Aug 25, 06:00 PM IST',
            'isLive': true,
            'desc': 'Fireside discussions, live building events, and tech panels.'
          }
        ]
      }
    },
    {
      'title': 'Web3 Hack & Build',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=800&auto=format&fit=crop',
      'organizer': 'Ethereum India',
      'timeAgo': '1w ago',
      'tagline': 'Build decentralized applications, smart contracts, or protocols on top-tier layer-2 blockchains. Mentorship provided by top global Web3 devs.',
      'dates': '01-07 Sept 2025\nMon, 12:00 PM',
      'location': 'Goa, India\nIn-person',
      'teamSizeText': '1-4 Members\nTeam Size',
      'tags': ['Web3', 'Blockchain', 'DApp Sprint', 'Travel Stipends'],
      'prizePool': '\$25,000',
      'likes': 310,
      'comments': 18,
      'event': {
        'title': 'Web3 Hack & Build 2025',
        'organizer': 'Ethereum India',
        'bannerUrl': 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=80&auto=format&fit=crop',
        'teamSize': 'Individual or Team (Up to 4 members)',
        'registered': 1410,
        'prizes': 'Grants and bounties worth \$25,000',
        'eligibility': 'Open to blockchain builders, smart contract writers, and protocols designers.',
        'description': 'Web3 Hack & Build gathers the brightest minds to architect the scaling layer of Ethereum. Build protocols that solve liquidity bottlenecks.',
        'timeline': [
          {
            'day': '01',
            'month': 'SEP',
            'title': 'Hackathon Launch',
            'startDate': '01 Sep 25, 12:00 PM IST',
            'endDate': '07 Sep 25, 05:00 PM IST',
            'isLive': true,
            'desc': 'Build, draft smart contracts, review with audit mentors.'
          }
        ]
      }
    },
    {
      'title': 'Data Science Bootcamp: Zero to Hero',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&auto=format&fit=crop',
      'organizer': 'Analytics Labs',
      'timeAgo': '2w ago',
      'tagline': 'A fast-paced, hands-on workshop covering data analysis, feature engineering, and deploying machine learning models into production environments.',
      'dates': '15 Sept 2025\nMon, 4:00 PM',
      'location': 'Online\nMS Teams',
      'teamSizeText': 'Individual\nParticipation',
      'tags': ['Workshop', 'Data Science', 'Machine Learning', 'Certificates'],
      'prizePool': 'Free Premium Sub',
      'likes': 520,
      'comments': 43,
      'event': {
        'title': 'Data Science Bootcamp 2025',
        'organizer': 'Analytics Labs',
        'bannerUrl': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=80&auto=format&fit=crop',
        'teamSize': 'Individual Seat',
        'registered': 4120,
        'prizes': '1-year Premium Platform Subscriptions',
        'eligibility': 'Open to anyone starting in analytics or wanting to improve predictive model scaling.',
        'description': 'Cover Pandas, scikit-learn, hyperparameter tuning, and containerizing ML model APIs with FastAPI and Docker.',
        'timeline': [
          {
            'day': '15',
            'month': 'SEP',
            'title': 'Bootcamp Opening Session',
            'startDate': '15 Sep 25, 04:00 PM IST',
            'endDate': '15 Sep 25, 08:00 PM IST',
            'isLive': true,
            'desc': 'Interactive live coding, jupyter lab setups, and deployment sprint.'
          }
        ]
      }
    },
    {
      'title': 'GreenTech Pitch Competition',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&auto=format&fit=crop',
      'organizer': 'EcoStart Alliance',
      'timeAgo': '2w ago',
      'tagline': 'Pitch your sustainable startup idea to top impact venture capitalists. Win initial seed funding and direct mentorship from industry leaders.',
      'dates': '22 Sept 2025\nTue, 2:00 PM',
      'location': 'Bangalore, India\nHybrid',
      'teamSizeText': '1-5 Members\nPitch Team',
      'tags': ['Pitch Competition', 'Sustainability', 'Funding', 'Mentors'],
      'prizePool': '\$50,000 Seed',
      'likes': 290,
      'comments': 12,
      'event': {
        'title': 'EcoStart GreenTech Challenge 2025',
        'organizer': 'EcoStart Alliance',
        'bannerUrl': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=80&auto=format&fit=crop',
        'teamSize': 'Team (1-5 Members)',
        'registered': 640,
        'prizes': 'Seed grant worth \$50,000 + VC matches',
        'eligibility': 'Early-stage climate-tech and environment-oriented startups.',
        'description': 'Pitch your waste management, carbon capture, or green hydrogen tech layouts. Review panel includes top sustainability VCs.',
        'timeline': [
          {
            'day': '22',
            'month': 'SEP',
            'title': 'Final Pitch Round',
            'startDate': '22 Sep 25, 02:00 PM IST',
            'endDate': '22 Sep 25, 06:00 PM IST',
            'isLive': true,
            'desc': 'Live pitch deck presentation followed by Q&A with VC judges.'
          }
        ]
      }
    },
    {
      'title': 'Cloud Practitioner Webinar',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop',
      'organizer': 'Cloud Architects',
      'timeAgo': '3w ago',
      'tagline': 'Learn foundational concepts of cloud computing, security, database migrations, and serverless computing. Get prepped for AWS/Azure tests.',
      'dates': '28 Sept 2025\nSun, 11:00 AM',
      'location': 'Online\nZoom Webinar',
      'teamSizeText': 'Individual\nWebinar',
      'tags': ['Cloud Computing', 'AWS/Azure', 'Certification', 'Webinar'],
      'prizePool': 'Free Exam Vouchers',
      'likes': 476,
      'comments': 26,
      'event': {
        'title': 'Cloud Practitioner Workshop 2025',
        'organizer': 'Cloud Architects',
        'bannerUrl': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=80&auto=format&fit=crop',
        'teamSize': 'Individual Attendee',
        'registered': 5800,
        'prizes': '100 Free Certification Vouchers',
        'eligibility': 'Open to anyone seeking to build, migrate, and secure cloud apps.',
        'description': 'Master database replication, virtual networks, and elastic architectures. Includes practice exam walkthroughs.',
        'timeline': [
          {
            'day': '28',
            'month': 'SEP',
            'title': 'Live Masterclass',
            'startDate': '28 Sep 25, 11:00 AM IST',
            'endDate': '28 Sep 25, 03:00 PM IST',
            'isLive': true,
            'desc': 'Core cloud structures, exam format reviews, and practice questions.'
          }
        ]
      }
    },
    {
      'title': 'Global Finance & Trade Quiz',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/180px-Python-logo-notext.svg.png',
      'bannerUrl': 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=800&auto=format&fit=crop',
      'organizer': 'Finance Forum',
      'timeAgo': '1m ago',
      'tagline': 'Test your knowledge on macroeconomic policies, global finance trends, corporate trading, and stock market fundamentals in this fast-paced online quiz.',
      'dates': '05 Oct 2025\nSun, 8:00 PM',
      'location': 'Online\nAcadyk Platform',
      'teamSizeText': 'Individual\nQuiz',
      'tags': ['Finance Quiz', 'Trading', 'Economics', 'Online'],
      'prizePool': '₹ 50,000',
      'likes': 338,
      'comments': 21,
      'event': {
        'title': 'Global Finance & Trade Quiz 2025',
        'organizer': 'Finance Forum',
        'bannerUrl': 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=800&auto=format&fit=crop',
        'logoUrl': 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=80&auto=format&fit=crop',
        'teamSize': 'Individual Play',
        'registered': 3120,
        'prizes': 'Cash Prizes worth ₹ 50,000',
        'eligibility': 'Open to all corporate, stock, and business quiz enthusiasts.',
        'description': 'A competitive finance quiz testing global stock charts, currency rates, case studies, and corporate trade routes.',
        'timeline': [
          {
            'day': '05',
            'month': 'OCT',
            'title': 'Quiz Round 1',
            'startDate': '05 Oct 25, 08:00 PM IST',
            'endDate': '05 Oct 25, 08:30 PM IST',
            'isLive': true,
            'desc': '30 multiple choice questions in 20 minutes on trade logistics.'
          }
        ]
      }
    }
  ];

  static void addOpportunity(Map<String, dynamic> op) {
    final list = List<Map<String, dynamic>>.from(opportunitiesNotifier.value);
    list.insert(0, op);
    opportunitiesNotifier.value = list;
  }
}
