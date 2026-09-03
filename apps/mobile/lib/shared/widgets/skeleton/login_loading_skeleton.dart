import 'package:flutter/material.dart';
import 'feed_skeleton.dart';
import 'skeleton_base.dart';

/// Full-page skeleton screen displayed immediately upon selecting email or tapping login.
/// Eliminates perceived login wait times by instantly transitioning the user into an
/// animated, high-fidelity shimmer representation of the Acadyk feed while credentials verify.
class LoginLoadingSkeleton extends StatelessWidget {
  final String statusText;

  const LoginLoadingSkeleton({
    super.key,
    this.statusText = 'Verifying campus credentials...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F2EF);
    final appBarBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Skeleton (matches AcadykTopHeaderBar)
            Container(
              color: appBarBg,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  const SkeletonCircle(size: 36),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: SkeletonContainer(
                      height: 36,
                      borderRadius: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SkeletonContainer(width: 24, height: 24, borderRadius: 6),
                  const SizedBox(width: 12),
                  const SkeletonContainer(width: 24, height: 24, borderRadius: 6),
                ],
              ),
            ),

            // Live Verification Banner with Progress Indicator
            Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C81)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F4C81).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Acadyk',
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F4C81),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      minHeight: 2.5,
                      backgroundColor: Color(0x1A0F4C81),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C81)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Feed Shimmer Cards
            const Expanded(
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: FeedSkeleton(itemCount: 4),
              ),
            ),

            // Bottom Nav Bar Skeleton
            Container(
              color: appBarBg,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SkeletonContainer(width: 22, height: 22, borderRadius: 6),
                      SizedBox(height: 4),
                      SkeletonLine(width: 28, height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
