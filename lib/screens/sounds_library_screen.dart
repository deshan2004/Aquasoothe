import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_model.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/custom_sound_provider.dart';
import '../services/audio_service.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/scale_button.dart';
import '../widgets/sound_visualizer_widget.dart';
import 'ai_sound_generator_screen.dart';

class SoundsLibraryScreen extends ConsumerWidget {
  const SoundsLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.watch(audioServiceProvider);
    final customSounds = ref.watch(customSoundProvider);
    final defaultTracks = SoundTrack.defaultTracks;

    final currentTrack = audioNotifier.currentTrack;
    final isPlaying = audioNotifier.isPlaying;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    final Map<String, CardStyle> cardStyles = isDark
        ? {
            'waterfall': const CardStyle(bg: Color(0xFF13272C), text: Color(0xFFE3F5F3), btnBg: Color(0xFF70D6CE), iconColor: Color(0xFF0B191C)),
            'ocean': const CardStyle(bg: Color(0xFF162E34), text: Color(0xFFE3F5F3), btnBg: Color(0xFF70D6CE), iconColor: Color(0xFF0B191C)),
            'rainfall': const CardStyle(bg: Color(0xFF18333A), text: Color(0xFFE3F5F3), btnBg: Color(0xFF70D6CE), iconColor: Color(0xFF0B191C)),
            'pink_noise': const CardStyle(bg: Color(0xFF2C2220), text: Color(0xFFFFD5C0), btnBg: Color(0xFFF8AB80), iconColor: Color(0xFF4D2411)),
            'brown_noise': const CardStyle(bg: Color(0xFF282522), text: Color(0xFFEFE6D8), btnBg: Color(0xFFCFC5B7), iconColor: Color(0xFF4D2411)),
            'forest': const CardStyle(bg: Color(0xFF142B2F), text: Color(0xFFE3F5F3), btnBg: Color(0xFF70D6CE), iconColor: Color(0xFF0B191C)),
            'crickets': const CardStyle(bg: Color(0xFF173136), text: Color(0xFFE3F5F3), btnBg: Color(0xFF70D6CE), iconColor: Color(0xFF0B191C)),
          }
        : {
            'waterfall': const CardStyle(bg: Color(0xFFD5ECE7), text: Color(0xFF0C4648), btnBg: Color(0xFF0C4648), iconColor: Colors.white),
            'ocean': const CardStyle(bg: Color(0xFFB9E3DE), text: Color(0xFF0C4648), btnBg: Color(0xFF0C4648), iconColor: Colors.white),
            'rainfall': const CardStyle(bg: Color(0xFFC7DEDB), text: Color(0xFF0C4648), btnBg: Color(0xFF0C4648), iconColor: Colors.white),
            'pink_noise': const CardStyle(bg: Color(0xFFF7BD9E), text: Color(0xFF4D2411), btnBg: Color(0xFF5C2B14), iconColor: Colors.white),
            'brown_noise': const CardStyle(bg: Color(0xFFCFC5B7), text: Color(0xFF4D2411), btnBg: Color(0xFF4D2411), iconColor: Colors.white),
            'forest': const CardStyle(bg: Color(0xFFD2EAE4), text: Color(0xFF0C4648), btnBg: Color(0xFF0C4648), iconColor: Colors.white),
            'crickets': const CardStyle(bg: Color(0xFFC4E4E0), text: Color(0xFF0C4648), btnBg: Color(0xFF0C4648), iconColor: Colors.white),
          };

    final allTracks = [...defaultTracks, ...customSounds];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              const AquaSootheHeader(isCentered: false),

              const SizedBox(height: 24),

              // Sleep Soundscapes Heading & Subtitle
              Text(
                'Sleep Soundscapes',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Curated audio for deep restorative rest.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  color: subtitleColor,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 28),

              // Active Sound Controls Banner if playing
              if (isPlaying) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF13272C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF1E3A40) : const Color(0xFF0C4648).withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.2 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SoundVisualizerWidget(
                                isPlaying: true,
                                color: textColor,
                                barWidth: 3.5,
                                maxHeight: 18,
                                barCount: 4,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Playing: ${currentTrack.title}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.pause_circle_filled_rounded, color: textColor, size: 30),
                            onPressed: () => audioNotifier.pause(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.volume_up_rounded, color: textColor, size: 20),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                activeTrackColor: textColor,
                                inactiveTrackColor: textColor.withValues(alpha: 0.2),
                                thumbColor: textColor,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                              ),
                              child: Slider(
                                value: audioNotifier.volume,
                                min: 0.0,
                                max: AudioServiceNotifier.maxSafeVolume,
                                onChanged: (val) => audioNotifier.setVolume(val),
                              ),
                            ),
                          ),
                          Text(
                            '${(audioNotifier.volume * 100).round()}%',
                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // List of Sound Cards
              Column(
                children: allTracks.map((track) {
                  final isSelected = track.id == currentTrack.id;
                  final isTrackPlaying = isSelected && isPlaying;
                  final style = cardStyles[track.id] ??
                      CardStyle(
                        bg: isDark ? const Color(0xFF13272C) : const Color(0xFFD5ECE7),
                        text: textColor,
                        btnBg: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648),
                        iconColor: isDark ? const Color(0xFF0B191C) : Colors.white,
                      );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: ScaleButton(
                      onTap: () async {
                        if (isTrackPlaying) {
                          await audioNotifier.pause();
                        } else {
                          await audioNotifier.selectTrack(track);
                          await audioNotifier.play();
                          ref.read(settingsProvider.notifier).setLastUsedSoundId(track.id);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 68,
                        decoration: BoxDecoration(
                          color: style.bg,
                          borderRadius: BorderRadius.circular(18),
                          border: isTrackPlaying ? Border.all(color: style.btnBg, width: 2) : null,
                          boxShadow: [
                            if (isTrackPlaying)
                              BoxShadow(
                                color: style.btnBg.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (isTrackPlaying) ...[
                                    SoundVisualizerWidget(
                                      isPlaying: true,
                                      color: style.text,
                                      barWidth: 3,
                                      maxHeight: 16,
                                      barCount: 3,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Text(
                                    track.title
                                        .replaceAll('Cascading ', '')
                                        .replaceAll('Soothing ', '')
                                        .replaceAll('Deep ', ''),
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: style.text,
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: style.btnBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isTrackPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: style.iconColor,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // AI Sound Studio launcher button
              ScaleButton(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AISoundGeneratorScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF13272C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 22, color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648)),
                      const SizedBox(width: 10),
                      Text(
                        'Generative AI Sound Studio',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CardStyle {
  final Color bg;
  final Color text;
  final Color btnBg;
  final Color iconColor;

  const CardStyle({
    required this.bg,
    required this.text,
    required this.btnBg,
    required this.iconColor,
  });
}
