import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const LogoWidget({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeSize = (size > 0 && !size.isNaN && !size.isInfinite) ? size : 32.0;

    return Image.asset(
      'assets/images/acadyk_logo.png',
      width: safeSize,
      height: safeSize,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: safeSize,
          height: safeSize,
          decoration: const BoxDecoration(
            color: Color(0xFF0A66C2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            'A',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: safeSize * 0.5,
            ),
          ),
        );
      },
    );
  }
}
