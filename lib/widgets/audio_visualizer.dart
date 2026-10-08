import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Modern Animated Sound Wave Visualizer for sleep audio tracks
class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double height;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.color = const Color(0xFF38BDF8),
    this.height = 32,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: 45,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (index) {
              final val = widget.isPlaying
                  ? (math.sin((_controller.value * 2 * math.pi) + (index * 0.8)) + 1) / 2
                  : 0.25;
              final barHeight = (val * (widget.height - 6)).clamp(4.0, widget.height);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                width: 4,
                height: barHeight,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
