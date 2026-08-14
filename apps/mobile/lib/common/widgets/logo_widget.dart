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
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.25),
          child: Image.asset(
            'assets/images/acadyk_logo.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C81),
                borderRadius: BorderRadius.circular(size * 0.25),
              ),
              alignment: Alignment.center,
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.5,
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
            fontSize: size * 0.75,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}
