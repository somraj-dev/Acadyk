import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton loader for Direct Message screen with alternating sender & receiver bubbles.
class ChatSkeleton extends StatelessWidget {
  final int itemCount;

  const ChatSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final isMe = index % 2 == 1;
          final double bubbleWidthFactor = (index % 3 == 0)
              ? 0.75
              : (index % 3 == 1)
                  ? 0.55
                  : 0.65;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe) ...[
                  const SkeletonCircle(size: 28),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: FractionallySizedBox(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    widthFactor: bubbleWidthFactor,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          const SkeletonLine(width: double.infinity, height: 12),
                          const SizedBox(height: 6),
                          FractionallySizedBox(
                            widthFactor: 0.7,
                            child: const SkeletonLine(height: 12),
                          ),
                          const SizedBox(height: 6),
                          const SkeletonLine(width: 35, height: 9),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 8),
                  const SkeletonCircle(size: 28),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
