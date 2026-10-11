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
import '../widgets/glass_card.dart';
import '../widgets/unified_sound_studio_sheet.dart';

class SoundsLibraryScreen extends ConsumerWidget {
  const SoundsLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.watch(audioServiceProvider);
    final customSounds = ref.watch(customSoundProvider);
    final defaultTracks = SoundTrack.defaultTracks;
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;

    final currentTrack = audioNotifier.currentTrack;
    final isPlaying = audioNotifier.isPlaying;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Background Aura Blobs
          Positioned(
            top: -30,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF0C4648) : const Color(0xFFBDE4E1)).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            top: 340,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF163C42) : const Color(0xFFD5ECE7)).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8AB80).withValues(alpha: isDark ? 0.15 : 0.2),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header
                  const AquaSootheHeader(isCentered: false),

                  const SizedBox(height: 24),

                  // Header title & count badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSi ? 'සුව නින්දේ ශබ්ද' : 'Sleep Soundscapes',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSi ? 'සුවබර නින්ද සඳහා සුවිශේෂී ස්වභාවික නාද.' : 'Curated audio for deep restorative rest.',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          isSi ? '${allTracks.length} ශබ්ද' : '${allTracks.length} Sounds',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: subtitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Active Sound & Auto-off Sleep Timer Glass Card
                  GlassCard(
                    borderRadius: 24,
                    blur: 18,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
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
                                      color: textColor,
                                      barWidth: 3.5,
                                      maxHeight: 18,
                                      barCount: 4,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        isSi ? 'වාදනය වේ: ${currentTrack.title}' : 'Playing: ${currentTrack.title}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ScaleButton(
                                onTap: () => audioNotifier.pause(),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.pause_rounded, color: textColor, size: 24),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.volume_up_rounded, color: textColor, size: 20),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    activeTrackColor: textColor,
                                    inactiveTrackColor: textColor.withValues(alpha: 0.15),
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
                          const SizedBox(height: 12),
                          Divider(height: 1, color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1)),
                          const SizedBox(height: 12),
                        ],
                        // Sleep Timer Header
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, color: textColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Auto-Off Sleep Timer',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                            ),
                            const Spacer(),
                            if (isPlaying && audioNotifier.secondsRemaining > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.hourglass_bottom_rounded, size: 14, color: textColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Off in ${audioNotifier.formattedTimeRemaining}',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Sleep Timer Presets
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: SleepTimerPreset.values.map((preset) {
                              final isSelected = audioNotifier.selectedPreset == preset;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ScaleButton(
                                  onTap: () {
                                    audioNotifier.setTimerPreset(preset);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? textColor
                                          : (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? textColor
                                            : (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      preset.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? (isDark ? const Color(0xFF0B1F23) : Colors.white)
                                            : textColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List of Glassmorphic Sound Cards
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

                      return GlassCard(
                        borderRadius: 20,
                        blur: 16,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        backgroundColor: isTrackPlaying
                            ? (isDark
                                ? const Color(0xFF163C42).withValues(alpha: 0.75)
                                : style.bg.withValues(alpha: 0.75))
                            : (isDark
                                ? const Color(0xFF13272C).withValues(alpha: 0.55)
                                : style.bg.withValues(alpha: 0.35)),
                        borderColor: isTrackPlaying
                            ? const Color(0xFFF8AB80)
                            : null,
                        onTap: () async {
                          if (isTrackPlaying) {
                            await audioNotifier.pause();
                          } else {
                            await audioNotifier.selectTrack(track);
                            await audioNotifier.play();
                            ref.read(settingsProvider.notifier).setLastUsedSoundId(track.id);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (isTrackPlaying) ...[
                                    SoundVisualizerWidget(
                                      isPlaying: true,
                                      color: textColor,
                                      barWidth: 3,
                                      maxHeight: 18,
                                      barCount: 3,
                                    ),
                                    const SizedBox(width: 12),
                                  ] else ...[
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.07),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.graphic_eq_rounded,
                                        size: 18,
                                        color: subtitleColor,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          track.title
                                              .replaceAll('Cascading ', '')
                                              .replaceAll('Soothing ', '')
                                              .replaceAll('Deep ', ''),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Restorative Ambient Loop',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: subtitleColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isTrackPlaying
                                    ? const Color(0xFFF8AB80)
                                    : (isDark ? const Color(0xFF1E3A40) : const Color(0xFFE5F1EE)),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: isTrackPlaying ? 0.6 : 0.3),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  if (isTrackPlaying)
                                    BoxShadow(
                                      color: const Color(0xFFF8AB80).withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                ],
                              ),
                              child: Icon(
                                isTrackPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: isTrackPlaying
                                    ? const Color(0xFF4D2411)
                                    : (isDark ? Colors.white : const Color(0xFF0C4648)),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Unified Sound Studio Hub (AI Generator, Mixer & Mood Matcher in ONE place)
                  GlassCard(
                    borderRadius: 22,
                    blur: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    margin: EdgeInsets.zero,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0C4648).withValues(alpha: 0.92),
                        const Color(0xFF1E676B).withValues(alpha: 0.92),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                        ),
                        builder: (_) => const UnifiedSoundStudioSheet(),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.white),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isSi
                                ? (audioNotifier.isMixerEnabled
                                    ? 'ශබ්ද මැදිරිය (සක්‍රියයි)'
                                    : 'ශබ්ද මැදිරිය (AI & Mixer)')
                                : (audioNotifier.isMixerEnabled
                                    ? 'Sound Studio (Active Mix)'
                                    : 'Sound Studio (AI & Mixer)'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded, size: 22, color: Colors.white70),
                      ],
                    ),
                  ),

                  // Space for floating bottom glass dock
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
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
