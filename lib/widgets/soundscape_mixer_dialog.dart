import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_model.dart';
import '../providers/audio_provider.dart';
import '../services/audio_service.dart';
import 'scale_button.dart';
import 'sound_visualizer_widget.dart';

class SoundscapeMixerDialog extends ConsumerWidget {
  const SoundscapeMixerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.watch(audioServiceProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTrack = audioNotifier.currentTrack;
    final secondaryTrack = audioNotifier.secondaryTrack;
    final isMixerEnabled = audioNotifier.isMixerEnabled;
    final isPlaying = audioNotifier.isPlaying;

    final defaultTracks = SoundTrack.defaultTracks;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13272C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C4648).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Color(0xFF0C4648), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soundscape Studio',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Blend multiple nature sounds & white noise',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Master Layer Mixer Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A40) : const Color(0xFFE8F6F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0C4648).withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.layers_rounded,
                        color: isMixerEnabled ? const Color(0xFF0C4648) : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dual-Layer Sound Mixing',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648),
                            ),
                          ),
                          Text(
                            isMixerEnabled ? 'Layer 2 is active' : 'Turn on to blend a 2nd sound',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: isMixerEnabled,
                    activeTrackColor: const Color(0xFF0C4648),
                    onChanged: (val) {
                      audioNotifier.toggleMixer(val);
                      if (val && secondaryTrack == null) {
                        // Pick a default complementary secondary track
                        final defaultSecondary = defaultTracks.firstWhere(
                          (t) => t.id != primaryTrack.id,
                          orElse: () => defaultTracks.last,
                        );
                        audioNotifier.selectSecondaryTrack(defaultSecondary);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Primary Sound Section
            Text(
              'PRIMARY SOUND',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
              ),
            ),
            const SizedBox(height: 8),

            // Track Selector Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: defaultTracks.length,
                itemBuilder: (context, index) {
                  final track = defaultTracks[index];
                  final isSelected = track.id == primaryTrack.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(
                        track.icon,
                        size: 16,
                        color: isSelected ? Colors.white : const Color(0xFF0C4648),
                      ),
                      label: Text(track.title.replaceAll('Cascading ', '').replaceAll('Soothing ', '').replaceAll('Deep ', '')),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0C4648),
                      backgroundColor: isDark ? const Color(0xFF1E3A40) : const Color(0xFFE8F6F4),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0C4648)),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      onSelected: (_) {
                        audioNotifier.selectTrack(track);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Primary Volume Slider
            Row(
              children: [
                const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF0C4648)),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      activeTrackColor: const Color(0xFF0C4648),
                      inactiveTrackColor: const Color(0xFF0C4648).withValues(alpha: 0.15),
                      thumbColor: const Color(0xFF0C4648),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0C4648)),
                ),
              ],
            ),

            if (isMixerEnabled) ...[
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),

              // Secondary Background Layer Section
              Text(
                'SECONDARY BACKGROUND LAYER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
                ),
              ),
              const SizedBox(height: 8),

              // Secondary Track Chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: defaultTracks.length,
                  itemBuilder: (context, index) {
                    final track = defaultTracks[index];
                    final isSelected = secondaryTrack != null && track.id == secondaryTrack.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(
                          track.icon,
                          size: 16,
                          color: isSelected ? Colors.white : const Color(0xFFF8AB80),
                        ),
                        label: Text(track.title.replaceAll('Cascading ', '').replaceAll('Soothing ', '').replaceAll('Deep ', '')),
                        selected: isSelected,
                        selectedColor: const Color(0xFFF8AB80),
                        backgroundColor: isDark ? const Color(0xFF1E3A40) : const Color(0xFFFFF4EE),
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF4D2411) : (isDark ? Colors.white : const Color(0xFF4D2411)),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        onSelected: (_) {
                          audioNotifier.selectSecondaryTrack(track);
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Secondary Volume Slider
              Row(
                children: [
                  const Icon(Icons.graphic_eq_rounded, size: 18, color: Color(0xFFF8AB80)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        activeTrackColor: const Color(0xFFF8AB80),
                        inactiveTrackColor: const Color(0xFFF8AB80).withValues(alpha: 0.2),
                        thumbColor: const Color(0xFFF8AB80),
                      ),
                      child: Slider(
                        value: audioNotifier.secondaryVolume,
                        min: 0.0,
                        max: AudioServiceNotifier.maxSafeVolume,
                        onChanged: (val) => audioNotifier.setSecondaryVolume(val),
                      ),
                    ),
                  ),
                  Text(
                    '${(audioNotifier.secondaryVolume * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4D2411)),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Quick Preset Soundscapes
            Text(
              'QUICK SOUNDSCAPE PRESETS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _PresetTile(
                    title: '🌧️ Cozy Rain',
                    subtitle: 'Rain + Crickets',
                    onTap: () {
                      final p = defaultTracks.firstWhere((t) => t.id == 'rainfall');
                      final s = defaultTracks.firstWhere((t) => t.id == 'crickets');
                      audioNotifier.selectTrack(p);
                      audioNotifier.selectSecondaryTrack(s);
                      audioNotifier.toggleMixer(true);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PresetTile(
                    title: '🌊 Ocean Breeze',
                    subtitle: 'Ocean + Pink Noise',
                    onTap: () {
                      final p = defaultTracks.firstWhere((t) => t.id == 'ocean');
                      final s = defaultTracks.firstWhere((t) => t.id == 'pink_noise');
                      audioNotifier.selectTrack(p);
                      audioNotifier.selectSecondaryTrack(s);
                      audioNotifier.toggleMixer(true);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PresetTile(
                    title: '🌲 Deep Forest',
                    subtitle: 'Forest + Brown Noise',
                    onTap: () {
                      final p = defaultTracks.firstWhere((t) => t.id == 'forest');
                      final s = defaultTracks.firstWhere((t) => t.id == 'brown_noise');
                      audioNotifier.selectTrack(p);
                      audioNotifier.selectSecondaryTrack(s);
                      audioNotifier.toggleMixer(true);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PresetTile(
                    title: '💦 Waterfall Chill',
                    subtitle: 'Waterfall + Forest',
                    onTap: () {
                      final p = defaultTracks.firstWhere((t) => t.id == 'waterfall');
                      final s = defaultTracks.firstWhere((t) => t.id == 'forest');
                      audioNotifier.selectTrack(p);
                      audioNotifier.selectSecondaryTrack(s);
                      audioNotifier.toggleMixer(true);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Play / Control Button
            ScaleButton(
              onTap: () async {
                if (isPlaying) {
                  await audioNotifier.pause();
                } else {
                  await audioNotifier.play();
                }
              },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: isPlaying ? const Color(0xFFF8AB80) : const Color(0xFF0C4648),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isPlaying ? const Color(0xFFF8AB80) : const Color(0xFF0C4648)).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isPlaying) ...[
                      SoundVisualizerWidget(
                        isPlaying: true,
                        color: const Color(0xFF4D2411),
                        barWidth: 3,
                        maxHeight: 16,
                        barCount: 3,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: isPlaying ? const Color(0xFF4D2411) : Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPlaying ? 'Pause Soundscape' : 'Play Blended Soundscape',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPlaying ? const Color(0xFF4D2411) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PresetTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E3A40) : const Color(0xFFE8F6F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0C4648).withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
