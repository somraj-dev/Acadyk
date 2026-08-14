import 'package:flutter/material.dart';
import 'dart:math';

class CourseItemModel {
  final String id;
  final String title;
  final String tag;
  final double? progress; // e.g. 0.16 for 16%
  final String avatarType; // 'pink_circle', 'grey_poly', 'blue_poly', 'slate_poly', 'light_grid'

  const CourseItemModel({
    required this.id,
    required this.title,
    required this.tag,
    this.progress,
    required this.avatarType,
  });
}

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final List<CourseItemModel> _courses = const [
    CourseItemModel(
      id: '2',
      title: 'Dr. Abhishek Bhatt',
      tag: 'Centre for Artificial Intelligence',
      progress: null,
      avatarType: 'grey_poly',
    ),
    CourseItemModel(
      id: '3',
      title: 'Dr. Anurag Singh Tomar',
      tag: 'Centre for Artificial Intelligence',
      progress: null,
      avatarType: 'blue_poly',
    ),
    CourseItemModel(
      id: '4',
      title: 'Dr. Hardev Singh Pal',
      tag: 'Centre for Artificial Intelligence',
      progress: null,
      avatarType: 'slate_poly',
    ),
    CourseItemModel(
      id: '5',
      title: 'Dr. Mausam Chouksey',
      tag: 'Centre for Artificial Intelligence',
      progress: null,
      avatarType: 'light_grid',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0D1117) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Courses',
          style: TextStyle(
            color: titleColor,
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final item = _courses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: _buildCourseCard(item, isDark),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(CourseItemModel item, bool isDark) {
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB);
    final titleColor = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1F2937);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with geometric mosaic pattern
              _buildAvatar(item.avatarType),
              const SizedBox(width: 14.0),

              // Title and Tag Pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8D7),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Text(
                        item.tag,
                        style: const TextStyle(
                          color: Color(0xFF9A5B2D),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // More options button
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showOptionsBottomSheet(item),
              ),
            ],
          ),

          // Progress Bar section if present
          if (item.progress != null) ...[
            const SizedBox(height: 14.0),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      backgroundColor: const Color(0xFFFDE8D7),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE67E22)),
                      minHeight: 6.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  '${(item.progress! * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String type) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.0),
      child: SizedBox(
        width: 62,
        height: 62,
        child: CustomPaint(
          painter: _AvatarPatternPainter(type),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(CourseItemModel item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined, color: Color(0xFF0F4C81)),
                  title: const Text('View Syllabus & Modules'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline, color: Color(0xFF0F4C81)),
                  title: const Text('Faculty & Mentor Details'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: Color(0xFF0F4C81)),
                  title: const Text('Share Course Info'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvatarPatternPainter extends CustomPainter {
  final String type;

  _AvatarPatternPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    switch (type) {
      case 'pink_circle':
        _paintPinkRosette(canvas, rect);
        break;
      case 'grey_poly':
        _paintGreyMosaic(canvas, rect);
        break;
      case 'blue_poly':
        _paintBlueMosaic(canvas, rect);
        break;
      case 'slate_poly':
        _paintSlateMosaic(canvas, rect);
        break;
      case 'light_grid':
      default:
        _paintLightGridMosaic(canvas, rect);
        break;
    }
  }

  void _paintPinkRosette(Canvas canvas, Rect rect) {
    final bgPaint = Paint()..color = const Color(0xFFD84A78);
    canvas.drawRect(rect, bgPaint);

    final circlePaint = Paint()
      ..color = const Color(0xFFB82D5C).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final cx = rect.width / 2;
    final cy = rect.height / 2;

    // Concentric overlapping rosette rings
    const int petals = 8;
    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * 3.14159265) / petals;
      final px = cx + 12 * cos(angle);
      final py = cy + 12 * sin(angle);
      canvas.drawCircle(Offset(px, py), 16, circlePaint);
    }

    final detailPaint = Paint()
      ..color = const Color(0xFFE56A95).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(cx, cy), 16, detailPaint);
    canvas.drawCircle(Offset(cx, cy), 8, detailPaint);
  }

  void _paintGreyMosaic(Canvas canvas, Rect rect) {
    final bgPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRect(rect, bgPaint);

    final tilePaint1 = Paint()..color = const Color(0xFFCBD5E1);
    final tilePaint2 = Paint()..color = const Color(0xFF94A3B8);
    final tilePaint3 = Paint()..color = const Color(0xFF64748B);

    final w = rect.width / 4;
    final h = rect.height / 4;

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        final path = Path();
        if ((i + j) % 2 == 0) {
          path.moveTo(i * w, j * h);
          path.lineTo((i + 1) * w, j * h);
          path.lineTo((i + 1) * w, (j + 1) * h);
          path.close();
          canvas.drawPath(path, (i + j) % 3 == 0 ? tilePaint2 : tilePaint1);
        } else {
          path.moveTo(i * w, j * h);
          path.lineTo(i * w, (j + 1) * h);
          path.lineTo((i + 1) * w, (j + 1) * h);
          path.close();
          canvas.drawPath(path, (i * j) % 2 == 0 ? tilePaint3 : tilePaint2);
        }
      }
    }
  }

  void _paintBlueMosaic(Canvas canvas, Rect rect) {
    final bgPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRect(rect, bgPaint);

    final darkBlue = Paint()..color = const Color(0xFF0369A1);
    final brightBlue = Paint()..color = const Color(0xFF38BDF8);
    final midBlue = Paint()..color = const Color(0xFF0EA5E9);

    final w = rect.width / 3;
    final h = rect.height / 3;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final path = Path();
        path.moveTo(i * w + w / 2, j * h);
        path.lineTo((i + 1) * w, j * h + h / 2);
        path.lineTo(i * w + w / 2, (j + 1) * h);
        path.lineTo(i * w, j * h + h / 2);
        path.close();
        canvas.drawPath(path, (i + j) % 2 == 0 ? brightBlue : midBlue);

        final cornerPath = Path();
        cornerPath.moveTo(i * w, j * h);
        cornerPath.lineTo(i * w + w / 2, j * h);
        cornerPath.lineTo(i * w, j * h + h / 2);
        cornerPath.close();
        canvas.drawPath(cornerPath, darkBlue);
      }
    }
  }

  void _paintSlateMosaic(Canvas canvas, Rect rect) {
    final bgPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawRect(rect, bgPaint);

    final tile1 = Paint()..color = const Color(0xFF64748B);
    final tile2 = Paint()..color = const Color(0xFF475569);
    final tile3 = Paint()..color = const Color(0xFFCBD5E1);

    final w = rect.width / 3;
    final h = rect.height / 3;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final path = Path();
        path.moveTo(i * w, j * h);
        path.lineTo((i + 1) * w, j * h);
        path.lineTo(i * w + w / 2, (j + 1) * h);
        path.close();
        canvas.drawPath(path, (i + j) % 2 == 0 ? tile1 : tile2);

        final invPath = Path();
        invPath.moveTo(i * w, (j + 1) * h);
        invPath.lineTo((i + 1) * w, (j + 1) * h);
        invPath.lineTo(i * w + w / 2, j * h);
        invPath.close();
        canvas.drawPath(invPath, (i * j) % 2 == 0 ? tile3 : tile1);
      }
    }
  }

  void _paintLightGridMosaic(Canvas canvas, Rect rect) {
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(rect, bgPaint);

    final subTile1 = Paint()..color = const Color(0xFFE2E8F0);
    final subTile2 = Paint()..color = const Color(0xFFCBD5E1);

    final w = rect.width / 4;
    final h = rect.height / 4;

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if ((i + j) % 2 == 0) {
          final path = Path();
          path.moveTo(i * w, j * h);
          path.lineTo((i + 1) * w, (j + 1) * h);
          path.lineTo(i * w, (j + 1) * h);
          path.close();
          canvas.drawPath(path, subTile1);
        } else if ((i * j) % 3 == 0) {
          canvas.drawCircle(Offset(i * w + w / 2, j * h + h / 2), w / 3, subTile2);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
