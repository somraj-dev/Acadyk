import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:acadyk/features/profile/presentation/services/profile_manager.dart';
import 'package:acadyk/features/notifications/presentation/screens/notification_screen.dart';
import 'package:acadyk/features/feed/presentation/screens/home_feed_screen.dart';

class AcadykTopHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showDropdownArrow;
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onTitleTap;
  final Widget? actionWidget;
  final Widget? trailing;

  const AcadykTopHeaderBar({
    super.key,
    this.title = 'Acadyk',
    this.showDropdownArrow = false,
    this.onOpenDrawer,
    this.onTitleTap,
    this.actionWidget,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final iconColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final searchBgColor = isDark ? const Color(0xFF262626) : const Color(0xFFF2F4F7);

    return Container(
      color: scaffoldBg,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left: User Circular Avatar (Tapping opens Drawer)
          Align(
            alignment: Alignment.centerLeft,
            child: ValueListenableBuilder<bool>(
              valueListenable: ProfileManager.profileUpdateNotifier,
              builder: (context, _, __) {
                final avatarUrl = ProfileManager.avatarUrl.isNotEmpty
                    ? ProfileManager.avatarUrl
                    : 'assets/images/somraj_avatar.jpg';
                final ImageProvider avatarProvider = avatarUrl.startsWith('http')
                    ? NetworkImage(avatarUrl)
                    : AssetImage(avatarUrl) as ImageProvider;

                return GestureDetector(
                  onTap: () {
                    if (onOpenDrawer != null) {
                      onOpenDrawer!();
                    } else {
                      HomeFeedScreen.openMainDrawer();
                      Scaffold.maybeOf(context)?.openDrawer();
                    }
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: avatarProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Center: Dynamic Page Title Text (Clean & Simple)
          GestureDetector(
            onTap: onTitleTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: title == 'Acadyk'
                      ? TextStyle(
                          color: textColor,
                          fontSize: 26,
                          fontFamily: 'Billabong',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        )
                      : TextStyle(
                          color: textColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                ),
                if (showDropdownArrow) ...[
                  const SizedBox(width: 3),
                  Icon(Icons.keyboard_arrow_down_rounded, color: iconColor, size: 20),
                ],
              ],
            ),
          ),

          // Right: Action Widget (Filter/Edit), Search Button & Inbox Tray with Unread Badge
          Align(
            alignment: Alignment.centerRight,
            child: trailing ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Optional screen action (Filter, Edit, etc.)
                    if (actionWidget != null) ...[
                      actionWidget!,
                      const SizedBox(width: 10),
                    ],

                    // Search button
                    GestureDetector(
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: AcadykSearchDelegate(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: searchBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.search, color: iconColor, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Inbox / Notifications Tray
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(CupertinoIcons.tray, color: iconColor, size: 24),
                          Positioned(
                            top: -1,
                            right: -2,
                            child: Container(
                              width: 8.5,
                              height: 8.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3897F0), // Vibrant blue notification indicator
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
