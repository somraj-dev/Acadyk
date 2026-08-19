import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton loader for the Feed Screen mimicking the LinkedIn/Acadyk post card layout.
class FeedSkeleton extends StatelessWidget {
  final int itemCount;

  const FeedSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;

    return AppShimmer(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            color: cardBg,
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Author Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SkeletonCircle(size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonLine(width: 140, height: 14),
                          SizedBox(height: 6),
                          SkeletonLine(width: 200, height: 11),
                        ],
                      ),
                    ),
                    const SkeletonContainer(width: 24, height: 24, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 14),

                // Post Text Lines
                const SkeletonLine(width: double.infinity, height: 13),
                const SizedBox(height: 6),
                const SkeletonLine(width: double.infinity, height: 13),
                const SizedBox(height: 6),
                FractionallySizedBox(
                  widthFactor: 0.65,
                  child: const SkeletonLine(height: 13),
                ),
                const SizedBox(height: 14),

                // Optional Image Placeholder on alternating cards
                if (index % 2 == 1) ...[
                  const SkeletonContainer(
                    width: double.infinity,
                    height: 180,
                    borderRadius: 10,
                  ),
                  const SizedBox(height: 14),
                ],

                // Post Stats Row (likes, comments count)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SkeletonLine(width: 70, height: 10),
                    SkeletonLine(width: 80, height: 10),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: isDark ? const Color(0xFF30363D) : const Color(0xFFF3F4F6),
                ),
                const SizedBox(height: 10),

                // Action Buttons Row (Like, Comment, Repost, Share)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    4,
                    (i) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SkeletonCircle(size: 18),
                        SizedBox(width: 6),
                        SkeletonLine(width: 36, height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
