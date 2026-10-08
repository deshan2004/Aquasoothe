import 'package:flutter/material.dart';

/// Reusable AquaSoothe logo and brand title widget.
class AquaSootheHeader extends StatelessWidget {
  final bool isCentered;
  final double iconSize;
  final double fontSize;
  final bool showImageLogo;

  const AquaSootheHeader({
    super.key,
    this.isCentered = false,
    this.iconSize = 34,
    this.fontSize = 26,
    this.showImageLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showImageLogo)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C4648).withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                width: iconSize,
                height: iconSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.waves_rounded,
                  size: iconSize,
                  color: const Color(0xFF0C4648),
                ),
              ),
            ),
          )
        else
          Icon(
            Icons.waves_rounded,
            size: iconSize,
            color: const Color(0xFF0C4648),
          ),
        const SizedBox(width: 10),
        Text(
          'AquaSoothe',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0C4648),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );

    if (isCentered) {
      return Center(child: logoWidget);
    }
    return logoWidget;
  }
}

