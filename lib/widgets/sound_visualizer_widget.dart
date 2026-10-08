import 'dart:math' as math;
import 'package:flutter/material.dart';

class SoundVisualizerWidget extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double barWidth;
  final double maxHeight;
  final int barCount;

  const SoundVisualizerWidget({
    super.key,
    required this.isPlaying,
    this.color = const Color(0xFF0C4648),
    this.barWidth = 3.5,
    this.maxHeight = 22.0,
    this.barCount = 4,
  });

  @override
  State<SoundVisualizerWidget> createState() => _SoundVisualizerWidgetState();
}

class _SoundVisualizerWidgetState extends State<SoundVisualizerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SoundVisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            double value = 0.3;
            if (widget.isPlaying) {
              final phase = (index * 0.4) + (_controller.value * 2 * math.pi);
              value = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(phase));
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: widget.barWidth,
              height: widget.maxHeight * value,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.barWidth / 2),
              ),
            );
          }),
        );
      },
    );
  }
}
