/// Mock feed data for Acadyk home feed
/// Contains posts from MITS Gwalior college including regular posts,
/// collaboration posts, event notifications, and announcements.

class MockFeedData {
  static final List<Map<String, dynamic>> mockPosts = [
    // 1. MITS Gwalior Official — Placement Announcement
    {
      'id': 'mits_placement_01',
      'type': 'announcement',
      'authorName': 'MITS Gwalior',
      'authorSubtitle': 'Official College Page',
      'authorInitials': 'M',
      'authorBgColor': 0xFF1565C0,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': '2h',
      'content':
          '🎉 Proud to announce! 45+ students from MITS Gwalior have been placed at top MNCs including TCS, Infosys, Wipro & Cognizant in the 2026 placement drive. Our highest package this year: ₹18.5 LPA!\n\nCongratulations to all the achievers! 🏆\n\n#MITSGwalior #Placements2026 #ProudMoment',
      'hasImage': false,
      'likes': 342,
      'comments': 89,
      'isCollab': false,
    },

    // 2. Collab Post — MITS x Google Developer Group
    {
      'id': 'mits_collab_gdg',
      'type': 'collab',
      'authorName': 'MITS Gwalior',
      'authorSubtitle': 'Official College Page',
      'authorInitials': 'M',
      'authorBgColor': 0xFF1565C0,
      'collabAuthorName': 'GDG Gwalior',
      'collabAuthorInitials': 'G',
      'collabAuthorBgColor': 0xFF4285F4,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': '5h',
      'content':
          '🤝 Collaboration Alert!\n\nMITS Gwalior × GDG Gwalior present "DevFest 2026" — A 2-day mega tech event featuring workshops on Flutter, Firebase, Google Cloud & AI/ML.\n\n📅 September 15-16, 2026\n📍 MITS Auditorium, Gwalior\n\nRegistrations open now! Limited seats available.\n\n#DevFest2026 #GDGGwalior #MITSGwalior',
      'hasImage': false,
      'likes': 567,
      'comments': 134,
      'isCollab': true,
    },

    // 3. Student Post — Hackathon Win
    {
      'id': 'mits_student_hackathon',
      'type': 'student',
      'authorName': 'Arjun Patel',
      'authorSubtitle': 'CSE \'27 @ MITS Gwalior | Full Stack Dev',
      'authorInitials': 'AP',
      'authorBgColor': 0xFF7C4DFF,
      'isVerified': false,
      'badgeType': 'bronze',
      'timeAgo': '8h',
      'content':
          '🏆 Our team from MITS Gwalior just won 1st place at Smart India Hackathon 2026! We built an AI-powered crop disease detection system that analyzes leaf images with 97% accuracy.\n\nHuge shoutout to our mentor Prof. R.K. Sharma and teammates Sneha, Vikram & Priya!\n\n#SIH2026 #MITSGwalior #HackathonWinners #AIForGood',
      'hasImage': false,
      'likes': 892,
      'comments': 203,
      'isCollab': false,
    },

    // 4. MITS Official — Notification: Exam Schedule
    {
      'id': 'mits_exam_notif',
      'type': 'notification',
      'authorName': 'MITS Gwalior — Examinations',
      'authorSubtitle': 'Official Notification',
      'authorInitials': 'M',
      'authorBgColor': 0xFFD32F2F,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': '12h',
      'content':
          '📢 IMPORTANT NOTIFICATION\n\nEnd Semester Examination Schedule (Odd Sem 2026-27) has been released. Exams commence from October 5, 2026.\n\n📋 Admit cards available on the student portal from September 20.\n📌 Students with pending fees must clear dues before September 15.\n\nDownload the complete schedule from the MITS portal.\n\n— Controller of Examinations, MITS Gwalior',
      'hasImage': false,
      'likes': 156,
      'comments': 78,
      'isCollab': false,
    },

    // 5. Collab Post — MITS x IEEE
    {
      'id': 'mits_collab_ieee',
      'type': 'collab',
      'authorName': 'MITS Gwalior',
      'authorSubtitle': 'Official College Page',
      'authorInitials': 'M',
      'authorBgColor': 0xFF1565C0,
      'collabAuthorName': 'IEEE MITS SB',
      'collabAuthorInitials': 'IEEE',
      'collabAuthorBgColor': 0xFF00629B,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': '1d',
      'content':
          '🌐 MITS Gwalior × IEEE Student Branch present\n\n"TechNova 2026" — International Conference on Emerging Technologies\n\nTopics: Quantum Computing, Edge AI, Blockchain, 6G Networks\n\n🎤 Keynote Speaker: Dr. Priya Mehta (Google Research)\n📅 October 20-21, 2026\n\nPaper submissions open until September 30.\n\n#TechNova2026 #IEEE #MITSGwalior #Research',
      'hasImage': false,
      'likes': 423,
      'comments': 67,
      'isCollab': true,
    },

    // 6. Faculty Post — Research Published
    {
      'id': 'mits_faculty_research',
      'type': 'faculty',
      'authorName': 'Dr. Neha Gupta',
      'authorSubtitle': 'Assoc. Prof., CSE @ MITS Gwalior | AI Researcher',
      'authorInitials': 'NG',
      'authorBgColor': 0xFF00897B,
      'isVerified': true,
      'badgeType': 'silver',
      'timeAgo': '1d',
      'content':
          '📄 Excited to share that our research paper "Federated Learning for Privacy-Preserving Healthcare Data Analysis" has been accepted at IEEE ICML 2026!\n\nThis work was done in collaboration with my brilliant students at MITS Gwalior\'s AI Lab. Special thanks to Rahul & Meera for their tireless efforts.\n\nProud of Team MITS! 🎓\n\n#Research #AI #FederatedLearning #MITSGwalior',
      'hasImage': false,
      'likes': 278,
      'comments': 45,
      'isCollab': false,
    },

    // 7. Student Club — Coding Contest
    {
      'id': 'mits_coding_club',
      'type': 'club',
      'authorName': 'CodeCraft MITS',
      'authorSubtitle': 'Official Coding Club @ MITS Gwalior',
      'authorInitials': 'CC',
      'authorBgColor': 0xFFFF6F00,
      'isVerified': false,
      'badgeType': 'bronze',
      'timeAgo': '1d',
      'content':
          '💻 Weekly Coding Challenge #42\n\nThis week\'s problem: "Optimal Path in Dynamic Grid"\nDifficulty: 🟡 Medium-Hard\n\nPrizes:\n🥇 ₹500 Amazon voucher\n🥈 ₹300 Amazon voucher\n🥉 ₹200 Amazon voucher\n\nSubmission deadline: Friday, 11:59 PM\nLink in bio 👆\n\n#CodeCraftMITS #CodingChallenge #CompetitiveProgramming',
      'hasImage': false,
      'likes': 189,
      'comments': 56,
      'isCollab': false,
    },

    // 8. MITS Official — Cultural Fest
    {
      'id': 'mits_fest_announce',
      'type': 'announcement',
      'authorName': 'MITS Gwalior',
      'authorSubtitle': 'Official College Page',
      'authorInitials': 'M',
      'authorBgColor': 0xFF1565C0,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': '2d',
      'content':
          '🎭 Save the Date!\n\n"UDAAN 2026" — MITS Gwalior\'s Annual Cultural & Technical Festival is here!\n\n🎶 Star Night | 🎨 Art Exhibition | 🤖 Robotics Arena | 🎮 Gaming Zone | 💃 Dance Battle\n\n📅 November 8-10, 2026\n💰 Prize Pool: ₹5,00,000+\n\nRegistrations open for all colleges across India! 🇮🇳\n\n#UDAAN2026 #MITSGwalior #CollegeFest',
      'hasImage': false,
      'likes': 1245,
      'comments': 312,
      'isCollab': false,
    },

    // 9. Student Post — Internship Experience
    {
      'id': 'mits_student_intern',
      'type': 'student',
      'authorName': 'Sneha Verma',
      'authorSubtitle': 'IT \'26 @ MITS Gwalior | SDE Intern @ Microsoft',
      'authorInitials': 'SV',
      'authorBgColor': 0xFFE91E63,
      'isVerified': false,
      'badgeType': 'bronze',
      'timeAgo': '2d',
      'content':
          'Just completed my 6-month internship at Microsoft! 🎉\n\nFrom debugging production code to shipping features used by millions — what an incredible journey. Grateful to MITS Gwalior\'s placement cell and Prof. Anil Kumar for the guidance.\n\nKey learnings:\n→ System design at scale\n→ Code review culture\n→ Cross-team collaboration\n→ Growth mindset > Fixed mindset\n\nExcited to share: I\'ve received a PPO! 🚀\n\n#Microsoft #Internship #MITSGwalior #PPO',
      'hasImage': false,
      'likes': 1567,
      'comments': 234,
      'isCollab': false,
    },

    // 10. Notification — Fee Deadline
    {
      'id': 'mits_fee_notif',
      'type': 'notification',
      'authorName': 'MITS Gwalior — Accounts',
      'authorSubtitle': 'Official Notification',
      'authorInitials': 'M',
      'authorBgColor': 0xFFD32F2F,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': '2d',
      'content':
          '⚠️ FEE PAYMENT REMINDER\n\nLast date for payment of Odd Semester 2026-27 fees: September 15, 2026\n\nLate fee of ₹100/day will be applicable after the deadline.\n\nPayment modes: Online (student portal) | DD | NEFT\n\nFor queries, contact the Accounts Office (Block A, Ground Floor)\n\n— Accounts Department, MITS Gwalior',
      'hasImage': false,
      'likes': 89,
      'comments': 156,
      'isCollab': false,
    },

    // 11. Collab — MITS x Startup Incubator
    {
      'id': 'mits_collab_startup',
      'type': 'collab',
      'authorName': 'MITS Gwalior',
      'authorSubtitle': 'Official College Page',
      'authorInitials': 'M',
      'authorBgColor': 0xFF1565C0,
      'collabAuthorName': 'AIC-MITS Incubator',
      'collabAuthorInitials': 'AIC',
      'collabAuthorBgColor': 0xFF2E7D32,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': '3d',
      'content':
          '🚀 Startup Spotlight!\n\nMITS Gwalior × AIC-MITS Incubation Center proudly present the 3rd cohort of student startups:\n\n1. AgriSense — AI-powered farming solutions\n2. EduBridge — Connecting rural students with mentors\n3. MedTrack — Digital health records platform\n4. GreenGrid — Smart energy management\n\nThese startups have collectively raised ₹1.2 Cr in seed funding! 💰\n\nApply for Cohort 4 now!\n\n#StartupMITS #Innovation #Entrepreneurship',
      'hasImage': false,
      'likes': 678,
      'comments': 89,
      'isCollab': true,
    },

    // 12. Alumni Post
    {
      'id': 'mits_alumni_01',
      'type': 'alumni',
      'authorName': 'Rohit Sharma',
      'authorSubtitle': 'MITS \'22 Alumnus | SDE-2 @ Amazon | Ex-Google',
      'authorInitials': 'RS',
      'authorBgColor': 0xFF3949AB,
      'isVerified': false,
      'badgeType': 'silver',
      'timeAgo': '3d',
      'content':
          'Throwback to my MITS days! 4 years that changed my life. From late-night coding sessions in the hostel to cracking Google\'s interview — MITS gave me the foundation.\n\nAdvice to current MITSians:\n• Start competitive programming early\n• Build real projects, not just assignments\n• Network with alumni\n• Don\'t skip the fundamentals\n\nForever grateful to this institution. 🙏\n\n#MITSAlumni #NeverStopLearning #Gwalior',
      'hasImage': false,
      'likes': 934,
      'comments': 167,
      'isCollab': false,
    },

    // 13. Department Post — Workshop
    {
      'id': 'mits_cse_workshop',
      'type': 'department',
      'authorName': 'CSE Department, MITS',
      'authorSubtitle': 'Computer Science & Engineering',
      'authorInitials': 'CSE',
      'authorBgColor': 0xFF5C6BC0,
      'isVerified': true,
      'badgeType': 'silver',
      'timeAgo': '3d',
      'content':
          '🖥️ 5-Day Workshop on "Cloud Computing with AWS"\n\nOrganized by CSE Department, MITS Gwalior\nResource Person: Mr. Kunal Shah (AWS Solutions Architect)\n\n📅 September 22-26, 2026\n⏰ 10:00 AM - 4:00 PM\n📍 Computer Lab 3, Block B\n\nOpen to all CSE & IT students.\nRegistration fee: ₹200 (includes certification)\n\nRegister at the department office by September 18.\n\n#AWS #CloudComputing #MITSGwalior #Workshop',
      'hasImage': false,
      'likes': 234,
      'comments': 78,
      'isCollab': false,
    },

    // 14. Student — Project Showcase
    {
      'id': 'mits_student_project',
      'type': 'student',
      'authorName': 'Priya Tiwari',
      'authorSubtitle': 'CSE \'26 @ MITS Gwalior | Flutter & AI Enthusiast',
      'authorInitials': 'PT',
      'authorBgColor': 0xFFAD1457,
      'isVerified': false,
      'badgeType': 'bronze',
      'timeAgo': '4d',
      'content':
          '🚀 Just launched my final year project — "CampusConnect"!\n\nA Flutter app that helps MITS students with:\n✅ Real-time class schedules\n✅ Assignment tracking & reminders\n✅ Campus navigation with AR\n✅ Peer study group matching\n\nBuilt with Flutter + Firebase + TensorFlow Lite\n\nWould love feedback from fellow MITSians! DM me for the APK. 📱\n\n#FlutterDev #FinalYearProject #MITSGwalior #CampusConnect',
      'hasImage': false,
      'likes': 456,
      'comments': 123,
      'isCollab': false,
    },

    // 15. Notification — Library Notice
    {
      'id': 'mits_library_notif',
      'type': 'notification',
      'authorName': 'MITS Gwalior — Library',
      'authorSubtitle': 'Official Notification',
      'authorInitials': 'M',
      'authorBgColor': 0xFF6A1B9A,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': '4d',
      'content':
          '📚 LIBRARY NOTICE\n\nNew digital resources added to MITS Library:\n\n• IEEE Xplore — Full access to 5M+ documents\n• Springer Nature — 3000+ journals\n• Coursera Campus — Free courses for all students\n• NPTEL Local Chapter — Video lectures\n\nAccess credentials available at the library desk.\nWorking hours: 8 AM - 10 PM (Mon-Sat)\n\n— Central Library, MITS Gwalior',
      'hasImage': false,
      'likes': 178,
      'comments': 34,
      'isCollab': false,
    },

    // 16. Collab — MITS x Industry Partner
    {
      'id': 'mits_collab_tcs',
      'type': 'collab',
      'authorName': 'MITS Gwalior',
      'authorSubtitle': 'Official College Page',
      'authorInitials': 'M',
      'authorBgColor': 0xFF1565C0,
      'collabAuthorName': 'TCS iON',
      'collabAuthorInitials': 'TCS',
      'collabAuthorBgColor': 0xFF1A237E,
      'isVerified': true,
      'badgeType': 'gold',
      'timeAgo': '5d',
      'content':
          '🤝 Industry-Academia Partnership!\n\nMITS Gwalior × TCS iON have signed an MoU for:\n\n📌 TCS iON Digital Learning Hub access for all students\n📌 Industry-readiness certification programs\n📌 Guest lectures by TCS tech leads\n📌 Internship pipeline for top performers\n\nThis partnership will benefit 3000+ students at MITS!\n\n#MITSGwalior #TCS #IndustryConnect #SkillDevelopment',
      'hasImage': false,
      'likes': 789,
      'comments': 145,
      'isCollab': true,
    },

    // 17. Sports Achievement
    {
      'id': 'mits_sports_01',
      'type': 'sports',
      'authorName': 'MITS Sports Club',
      'authorSubtitle': 'Sports & Athletics @ MITS Gwalior',
      'authorInitials': 'SC',
      'authorBgColor': 0xFFEF6C00,
      'isVerified': false,
      'badgeType': 'bronze',
      'timeAgo': '5d',
      'content':
          '🏏 MITS Cricket Team wins the Inter-College Championship!\n\nFinal Score: MITS 187/4 vs GGITS 156/10\nPlayer of the Match: Aditya Rajput (78 runs, 3 wickets)\n\nOur team remained unbeaten throughout the tournament! 🏆\n\nNext up: RGPV State Level Tournament in October.\n\nLet\'s cheer for Team MITS! 💪\n\n#MITSCricket #Champions #CollegeSports #Gwalior',
      'hasImage': false,
      'likes': 567,
      'comments': 89,
      'isCollab': false,
    },

    // 18. Student — Motivational/Achievement
    {
      'id': 'mits_student_achieve',
      'type': 'student',
      'authorName': 'Vikram Singh Tomar',
      'authorSubtitle': 'ECE \'27 @ MITS Gwalior | GATE AIR 342',
      'authorInitials': 'VT',
      'authorBgColor': 0xFF1B5E20,
      'isVerified': false,
      'badgeType': 'bronze',
      'timeAgo': '6d',
      'content':
          'From scoring 45% in my 1st semester to cracking GATE with AIR 342 — here\'s my journey.\n\nI failed 3 subjects in first year. Everyone said engineering wasn\'t for me. But MITS gave me a second chance.\n\nWhat changed:\n→ Joined the library gang (shoutout to Central Library!)\n→ Prof. Sharma\'s problem-solving sessions\n→ Consistency over motivation\n→ 200 days of daily practice\n\nIf I can do it, you can too. Never give up, MITSians! 🔥\n\n#GATE2026 #MITSGwalior #NeverGiveUp #Motivation',
      'hasImage': false,
      'likes': 2134,
      'comments': 456,
      'isCollab': false,
    },
  ];
}
