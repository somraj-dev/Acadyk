import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton loader for Message Center screen mimicking conversation list rows.
class MessageSkeleton extends StatelessWidget {
  final int itemCount;

  const MessageSkeleton({
    super.key,
    this.itemCount = 7,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const Divider(
          height: 16,
          thickness: 0.5,
          indent: 64,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User / Group Avatar
                const SkeletonCircle(size: 48),
                const SizedBox(width: 14),

                // Conversation Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SkeletonLine(width: 140, height: 14),
                          SkeletonLine(width: 40, height: 11),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Last Message Preview
                      FractionallySizedBox(
                        widthFactor: index % 3 == 0 ? 0.9 : 0.65,
                        child: const SkeletonLine(height: 12),
                      ),
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
