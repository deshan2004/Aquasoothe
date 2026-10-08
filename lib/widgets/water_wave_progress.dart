import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaterWaveProgress extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Widget? child;
  final Color baseColor;
  final Color waveColor;

  const WaterWaveProgress({
    super.key,
    required this.progress,
    this.height = 220,
    this.child,
    this.baseColor = const Color(0xFFD5ECE7),
    this.waveColor = const Color(0xFF5F8B88),
  });

  @override
  State<WaterWaveProgress> createState() => _WaterWaveProgressState();
}

class _WaterWaveProgressState extends State<WaterWaveProgress> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.baseColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4648).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Wave animation painter
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(double.infinity, widget.height),
                  painter: _WaterWavePainter(
                    progress: clampedProgress,
                    animationValue: _animController.value,
                    waveColor: widget.waveColor,
                  ),
                );
              },
            ),

            // Foreground child content overlay
            if (widget.child != null) Center(child: widget.child!),
          ],
        ),
      ),
    );
  }
}

class _WaterWavePainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final Color waveColor;

  _WaterWavePainter({
    required this.progress,
    required this.animationValue,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillHeight = size.height * (1.0 - progress);

    // Front Wave
    final Paint frontPaint = Paint()
      ..color = waveColor.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    // Back Wave (Slightly lighter, offset phase)
    final Paint backPaint = Paint()
      ..color = waveColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final Path backPath = Path();
    final Path frontPath = Path();

    final double waveAmplitude = progress == 0 ? 3.0 : (progress >= 1.0 ? 2.0 : 8.0);
    final double waveFrequency = 2 * math.pi / size.width;

    // Build Back Wave Path
    backPath.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 2) {
      final y = fillHeight + math.sin((x * waveFrequency) + (animationValue * 2 * math.pi) + math.pi / 2) * waveAmplitude;
      backPath.lineTo(x, y);
    }
    backPath.lineTo(size.width, size.height);
    backPath.close();

    // Build Front Wave Path
    frontPath.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 2) {
      final y = fillHeight + math.sin((x * waveFrequency) + (animationValue * 2 * math.pi)) * waveAmplitude;
      frontPath.lineTo(x, y);
    }
    frontPath.lineTo(size.width, size.height);
    frontPath.close();

    canvas.drawPath(backPath, backPaint);
    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.progress != progress ||
        oldDelegate.waveColor != waveColor;
  }
}
