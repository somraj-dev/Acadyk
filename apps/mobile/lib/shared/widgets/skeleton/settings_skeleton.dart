import 'package:flutter/material.dart';
import 'skeleton_base.dart';

/// Skeleton loader for Settings / Permissions list pages with section headers and switch rows.
class SettingsListSkeleton extends StatelessWidget {
  final int sectionCount;

  const SettingsListSkeleton({
    super.key,
    this.sectionCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(sectionCount, (sIndex) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const SkeletonLine(width: 120, height: 16),
                  const SizedBox(height: 16),
                  ...List.generate(3, (tIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          const SkeletonCircle(size: 36),
                          const SizedBox(width: 14),
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
                          const SkeletonContainer(width: 44, height: 24, borderRadius: 12),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
