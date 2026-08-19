import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton loader for Profile Screen matching cover, avatar, details, and section cards.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Photo + Overlapping Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Banner
                const SkeletonContainer(
                  width: double.infinity,
                  height: 140,
                  borderRadius: 0,
                ),

                // Avatar
                Positioned(
                  left: 20,
                  bottom: -40,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: const SkeletonCircle(size: 80),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Profile Info Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(width: 180, height: 20, borderRadius: 6),
                  const SizedBox(height: 8),
                  const SkeletonLine(width: 240, height: 13),
                  const SizedBox(height: 6),
                  const SkeletonLine(width: 140, height: 12),
                  const SizedBox(height: 14),

                  // Connection stats pills
                  Row(
                    children: const [
                      SkeletonContainer(width: 90, height: 26, borderRadius: 13),
                      SizedBox(width: 8),
                      SkeletonContainer(width: 100, height: 26, borderRadius: 13),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: const [
                      Expanded(
                        child: SkeletonContainer(height: 38, borderRadius: 20),
                      ),
                      SizedBox(width: 10),
                      SkeletonContainer(width: 38, height: 38, borderRadius: 19),
                      SizedBox(width: 10),
                      SkeletonContainer(width: 38, height: 38, borderRadius: 19),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Section 1 (Experience / Pinned)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonLine(width: 120, height: 16),
                      SkeletonCircle(size: 24),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonContainer(width: 44, height: 44, borderRadius: 8),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonLine(width: 160, height: 14),
                            SizedBox(height: 6),
                            SkeletonLine(width: 120, height: 12),
                            SizedBox(height: 6),
                            SkeletonLine(width: 90, height: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Profile Section 2 (Education)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonLine(width: 100, height: 16),
                      SkeletonCircle(size: 24),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonContainer(width: 44, height: 44, borderRadius: 8),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonLine(width: 180, height: 14),
                            SizedBox(height: 6),
                            SkeletonLine(width: 130, height: 12),
                            SizedBox(height: 6),
                            SkeletonLine(width: 80, height: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
