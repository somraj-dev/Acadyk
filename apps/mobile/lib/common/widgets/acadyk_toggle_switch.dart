import 'package:flutter/material.dart';

/// Universal toggle switch for Acadyk matching the Notifications page switch design.
class AcadykToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;

  const AcadykToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF0F4C81),
    this.inactiveColor = const Color(0xFFE2E8F0),
    this.width = 48,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;

    return GestureDetector(
      onTap: isEnabled ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: value ? activeColor : inactiveColor,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: height - 5,
              height: height - 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
