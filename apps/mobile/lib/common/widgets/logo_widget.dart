import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double fontSize;
  final double size;
  final String text;

  const LogoWidget({
    super.key,
    this.fontSize = 32.0,
    this.size = 36.0,
    this.text = 'Acadyk',
  });

  @override
  Widget build(BuildContext context) {
    final safeSize = (size > 0 && !size.isNaN && !size.isInfinite) ? size : 36.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(safeSize * 0.25),
          child: Image.asset(
            'assets/images/acadyk_logo.png',
            width: safeSize,
            height: safeSize,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: safeSize,
              height: safeSize,
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C81),
                borderRadius: BorderRadius.circular(safeSize * 0.25),
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
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF0F4C81),
            fontWeight: FontWeight.w900,
            fontSize: safeSize * 0.75,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}
