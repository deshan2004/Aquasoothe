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
import '../widgets/soundscape_mixer_dialog.dart';
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

    final Map<String, CardStyle> cardStyles = {
      'waterfall': const CardStyle(
        bg: Color(0xFFD5ECE7),
        text: Color(0xFF0C4648),
        btnBg: Color(0xFF0C4648),
        iconColor: Colors.white,
      ),
      'ocean': const CardStyle(
        bg: Color(0xFFB9E3DE),
        text: Color(0xFF0C4648),
        btnBg: Color(0xFF0C4648),
        iconColor: Colors.white,
      ),
      'rainfall': const CardStyle(
        bg: Color(0xFFC7DEDB),
        text: Color(0xFF0C4648),
        btnBg: Color(0xFF0C4648),
        iconColor: Colors.white,
      ),
      'pink_noise': const CardStyle(
        bg: Color(0xFFF7BD9E),
        text: Color(0xFF4D2411),
        btnBg: Color(0xFF5C2B14),
        iconColor: Colors.white,
      ),
      'brown_noise': const CardStyle(
        bg: Color(0xFFCFC5B7),
        text: Color(0xFF4D2411),
        btnBg: Color(0xFF4D2411),
        iconColor: Colors.white,
      ),
      'forest': const CardStyle(
        bg: Color(0xFFD2EAE4),
        text: Color(0xFF0C4648),
        btnBg: Color(0xFF0C4648),
        iconColor: Colors.white,
      ),
      'crickets': const CardStyle(
        bg: Color(0xFFC4E4E0),
        text: Color(0xFF0C4648),
        btnBg: Color(0xFF0C4648),
        iconColor: Colors.white,
      ),
    };

    final allTracks = [...defaultTracks, ...customSounds];

    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F6),
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
              const Text(
                'Sleep Soundscapes',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C4648),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Curated audio for deep restorative rest.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5B787A),
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 28),

              // Active Sound Controls Banner if playing
              // Active Sound & Auto-off Sleep Timer Controls Banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF0C4648).withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0C4648).withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (isPlaying) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SoundVisualizerWidget(
                                  isPlaying: true,
                                  color: const Color(0xFF0C4648),
                                  barWidth: 3.5,
                                  maxHeight: 18,
                                  barCount: 4,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    'Playing: ${currentTrack.title}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0C4648),
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFF0C4648), size: 30),
                            onPressed: () => audioNotifier.pause(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.volume_up_rounded, color: Color(0xFF0C4648), size: 20),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                activeTrackColor: const Color(0xFF0C4648),
                                inactiveTrackColor: const Color(0xFF0C4648).withValues(alpha: 0.15),
                                thumbColor: const Color(0xFF0C4648),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0C4648), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                    ],
                    // Sleep Timer Header
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Color(0xFF0C4648), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Auto-Off Sleep Timer',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0C4648)),
                        ),
                        const Spacer(),
                        if (isPlaying && audioNotifier.secondsRemaining > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C4648).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_bottom_rounded, size: 14, color: Color(0xFF0C4648)),
                                const SizedBox(width: 4),
                                Text(
                                  'Off in ${audioNotifier.formattedTimeRemaining}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0C4648)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Sleep Timer Presets
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: SleepTimerPreset.values.map((preset) {
                          final isSelected = audioNotifier.selectedPreset == preset;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(preset.label),
                              selected: isSelected,
                              selectedColor: const Color(0xFF0C4648),
                              backgroundColor: const Color(0xFFEFF8F6),
                              showCheckmark: false,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF0C4648),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) {
                                audioNotifier.setTimerPreset(preset);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // List of Sound Cards
              Column(
                children: allTracks.map((track) {
                  final isSelected = track.id == currentTrack.id;
                  final isTrackPlaying = isSelected && isPlaying;
                  final style = cardStyles[track.id] ??
                      const CardStyle(
                        bg: Color(0xFFD5ECE7),
                        text: Color(0xFF0C4648),
                        btnBg: Color(0xFF0C4648),
                        iconColor: Colors.white,
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

              // Soundscape Studio Dual Layer Mixer Launcher Button
              ScaleButton(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    builder: (_) => const SoundscapeMixerDialog(),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C4648),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C4648).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tune_rounded, size: 22, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        audioNotifier.isMixerEnabled ? 'Soundscape Studio (Active Mix)' : 'Custom Soundscape Mixer',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0C4648), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 22, color: Color(0xFF0C4648)),
                      SizedBox(width: 10),
                      Text(
                        'Generative AI Sound Studio',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0C4648)),
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
