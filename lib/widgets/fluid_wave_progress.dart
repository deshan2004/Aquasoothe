import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated Fluid Wave Progress Widget for AquaSoothe
/// Gives an ultra-modern, organic water fill effect for seniors.
class FluidWaveProgress extends StatefulWidget {
  final double percentage; // 0.0 to 1.0
  final double width;
  final double height;
  final bool isGoalMet;

  const FluidWaveProgress({
    super.key,
    required this.percentage,
    this.width = 130,
    this.height = 140,
    this.isGoalMet = false,
  });

  @override
  State<FluidWaveProgress> createState() => _FluidWaveProgressState();
}

class _FluidWaveProgressState extends State<FluidWaveProgress> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final innerW = widget.width - 6.0;
    final innerH = widget.height - 6.0;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glass Container
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: widget.isGoalMet ? const Color(0xFF15803D) : const Color(0xFF006687),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.isGoalMet ? const Color(0xFF15803D) : const Color(0xFF006687))
                      .withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          // Animated Wave Liquid Fill Clip with Explicit Size
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: SizedBox(
              width: innerW,
              height: innerH,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(innerW, innerH),
                    painter: WavePainter(
                      animationValue: _animationController.value,
                      percentage: widget.percentage,
                      isGoalMet: widget.isGoalMet,
                    ),
                  );
                },
              ),
            ),
          ),

          // Overlay Percentage Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isGoalMet ? Icons.verified_rounded : Icons.water_drop_rounded,
                size: 38,
                color: widget.percentage > 0.45 ? Colors.white : const Color(0xFF006687),
              ),
              const SizedBox(height: 4),
              Text(
                '${(widget.percentage * 100).round()}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.percentage > 0.45 ? Colors.white : const Color(0xFF0A2540),
                  shadows: widget.percentage > 0.45
                      ? [
                          const Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ]
                      : [],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double percentage;
  final bool isGoalMet;

  WavePainter({
    required this.animationValue,
    required this.percentage,
    required this.isGoalMet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final clampedPercent = percentage.clamp(0.0, 1.0);
    final fillHeight = size.height * clampedPercent;
    final baseWaterLevel = size.height - fillHeight;

    if (clampedPercent <= 0) return;

    // Paint 1: Back Wave
    final backWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isGoalMet
            ? [const Color(0xFF86EFAC).withValues(alpha: 0.6), const Color(0xFF22C55E).withValues(alpha: 0.6)]
            : [const Color(0xFF7DD3FC).withValues(alpha: 0.6), const Color(0xFF0284C7).withValues(alpha: 0.6)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final backPath = Path();
    backPath.moveTo(0, size.height);
    for (double i = 0.0; i <= size.width; i++) {
      final y = math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi) + math.pi) * 5 + baseWaterLevel;
      backPath.lineTo(i, y);
    }
    backPath.lineTo(size.width, size.height);
    backPath.close();
    canvas.drawPath(backPath, backWavePaint);

    // Paint 2: Front Wave
    final frontWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isGoalMet
            ? [const Color(0xFF22C55E), const Color(0xFF15803D)]
            : [const Color(0xFF0284C7), const Color(0xFF006687)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final frontPath = Path();
    frontPath.moveTo(0, size.height);
    for (double i = 0.0; i <= size.width; i++) {
      final y = math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * 5 + baseWaterLevel;
      frontPath.lineTo(i, y);
    }
    frontPath.lineTo(size.width, size.height);
    frontPath.close();
    canvas.drawPath(frontPath, frontWavePaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.percentage != percentage ||
        oldDelegate.isGoalMet != isGoalMet;
  }
}
