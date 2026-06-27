import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double fontSize;

  const LogoWidget({
    super.key,
    this.fontSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Acad',
          style: TextStyle(
            color: const Color(0xFF0A66C2), // LinkedIn Blue
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            letterSpacing: -1.0, // Tighter tracking as in original logo
          ),
        ),
        const SizedBox(width: 2.0), // Tiny margin to keep box adjacent
        Container(
          width: fontSize * 1.0,
          height: fontSize * 1.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF0A66C2),
            borderRadius: BorderRadius.circular(3.0), // Small rounded corners matching "in" box
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2.0), // Aligns uppercase text vertically
            child: Text(
              'YK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize * 0.78,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
