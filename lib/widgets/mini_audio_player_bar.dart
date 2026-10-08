import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../providers/navigation_provider.dart';
import 'sound_visualizer_widget.dart';


/// Floating mini player bar displayed above the bottom navigation bar when audio is active.
class MiniAudioPlayerBar extends ConsumerWidget {
  const MiniAudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.watch(audioServiceProvider);
    final currentTrack = audioNotifier.currentTrack;
    final isPlaying = audioNotifier.isPlaying;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C4648),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4648).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sound Icon or SoundVisualizer
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: isPlaying
                ? SoundVisualizerWidget(
                    isPlaying: true,
                    color: Colors.white,
                    barWidth: 3,
                    maxHeight: 16,
                    barCount: 3,
                  )
                : Icon(currentTrack.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // Sound Title & State
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(navigationTabProvider.notifier).state = 1;
              },

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentTrack.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isPlaying ? 'Playing Ambient Audio' : 'Paused',
                    style: const TextStyle(
                      color: Color(0xFFE2F3F0),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Play / Pause Action Button
          IconButton(
            onPressed: () async {
              if (isPlaying) {
                await audioNotifier.pause();
              } else {
                await audioNotifier.play();
              }
            },
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: const Color(0xFFF8AB80),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}
