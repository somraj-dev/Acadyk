import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double fontSize;
  final double size;

  const LogoWidget({
    super.key,
    this.fontSize = 32.0,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.25),
            image: const DecorationImage(
              image: AssetImage('assets/images/acadyk_logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Text(
          'acadyk',
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
