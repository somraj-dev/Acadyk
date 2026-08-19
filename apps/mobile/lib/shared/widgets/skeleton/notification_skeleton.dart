import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton loader for Notification Screen matching the notification item card layout.
class NotificationSkeleton extends StatelessWidget {
  final int itemCount;

  const NotificationSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final hasBodyBlock = index % 2 == 0;

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender Avatar Placeholder
                const SkeletonCircle(size: 40),
                const SizedBox(width: 12),

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Title / Name & Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SkeletonLine(width: 130, height: 13),
                          SkeletonLine(width: 45, height: 11),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Notification Detail Line
                      const SkeletonLine(width: double.infinity, height: 12),
                      const SizedBox(height: 4),
                      FractionallySizedBox(
                        widthFactor: 0.8,
                        child: const SkeletonLine(height: 12),
                      ),

                      // Optional Body Block Box
                      if (hasBodyBlock) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SkeletonLine(width: double.infinity, height: 11),
                              SizedBox(height: 4),
                              FractionallySizedBox(
                                widthFactor: 0.7,
                                child: SkeletonLine(height: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
