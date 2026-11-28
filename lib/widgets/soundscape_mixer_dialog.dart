import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_model.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import '../services/audio_service.dart';
import 'scale_button.dart';
import 'sound_visualizer_widget.dart';

class SoundscapeMixerDialog extends ConsumerWidget {
  const SoundscapeMixerDialog({super.key});

  String _getTrackTitleSi(String id) {
    switch (id) {
      case 'waterfall':
        return 'දිය ඇල්ල';
      case 'ocean':
        return 'සාගර රළ';
      case 'rainfall':
        return 'වැස්ස';
      case 'pink_noise':
        return 'Pink Noise';
      case 'brown_noise':
        return 'Brown Noise';
      case 'forest':
        return 'වනාන්තරය';
      case 'crickets':
        return 'රැහැයියන්';
      default:
        return 'ස්වභාවික නාදය';
    }
  }

  String _cleanTrackTitle(String title) {
    return title
        .replaceAll('Cascading ', '')
        .replaceAll('Soothing ', '')
        .replaceAll('Deep ', '')
        .replaceAll('Gentle ', '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.watch(audioServiceProvider);
    final settings = ref.watch(settingsProvider);
    final isSi = settings.isSinhala;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTrack = audioNotifier.currentTrack;
    final secondaryTrack = audioNotifier.secondaryTrack;
    final isMixerEnabled = audioNotifier.isMixerEnabled;
    final isPlaying = audioNotifier.isPlaying;

    final defaultTracks = SoundTrack.defaultTracks;

    final primaryTeal = const Color(0xFF0C4648);
    final goldAmber = const Color(0xFFD97706);
    final textColor = isDark ? const Color(0xFFE8F6F4) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF506E70);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F2027).withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Handle Bar
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Senior-Friendly Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0C4648), Color(0xFF0284C7)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C4648).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSi ? 'ද්විත්ව ස්වභාවික නාද මැදිරිය' : 'Soundscape Studio',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isSi
                                ? 'ස්වභාවික නාද 2ක් එකවර මිශ්‍ර කර ශබ්දය පාලනය කරන්න'
                                : 'Blend multiple nature sounds & white noise',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: subtitleColor, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Master Layer Mixer Switch Glass Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isMixerEnabled
                            ? const Color(0xFF0284C7).withValues(alpha: 0.22)
                            : Colors.white.withValues(alpha: 0.05))
                        : (isMixerEnabled
                            ? const Color(0xFFE0F2FE)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMixerEnabled
                          ? const Color(0xFF0284C7).withValues(alpha: 0.6)
                          : (isDark ? Colors.white12 : Colors.black12),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMixerEnabled
                                  ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                                  : (isDark ? Colors.white10 : Colors.black12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.layers_rounded,
                              color: isMixerEnabled ? const Color(0xFF0284C7) : subtitleColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSi ? 'ද්විත්ව නාද මිශ්‍ර කිරීම' : 'Dual-Layer Sound Mixing',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isMixerEnabled
                                    ? (isSi ? 'දෙවන නාදය සක්‍රියව ක්‍රියාත්මකයි' : 'Layer 2 is active')
                                    : (isSi ? 'තවත් නාදයක් මිශ්‍ර කිරීමට switch එක On කරන්න' : 'Turn on to blend a 2nd sound'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isMixerEnabled ? const Color(0xFF0284C7) : subtitleColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: isMixerEnabled,
                        activeTrackColor: const Color(0xFF0284C7),
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          audioNotifier.toggleMixer(val);
                          if (val && secondaryTrack == null) {
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

                const SizedBox(height: 22),

                // 1. PRIMARY SOUND SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSi ? '1. ප්‍රධාන ස්වභාවික නාදය' : '1. PRIMARY NATURE SOUND',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    Text(
                      isSi ? _getTrackTitleSi(primaryTrack.id) : _cleanTrackTitle(primaryTrack.title),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Senior-Friendly Primary Track Grid Wrap (Easy to see and tap!)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: defaultTracks.map((track) {
                    final isSelected = track.id == primaryTrack.id;
                    return ScaleButton(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        audioNotifier.selectTrack(track);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0284C7)
                              : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F9FF)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0284C7)
                                : (isDark ? Colors.white12 : const Color(0xFF0284C7).withValues(alpha: 0.2)),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              track.icon,
                              size: 17,
                              color: isSelected ? Colors.white : const Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isSi ? _getTrackTitleSi(track.id) : _cleanTrackTitle(track.title),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Primary Volume Slider with Glass Frame
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isDark ? Colors.white12 : primaryTeal.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up_rounded, size: 20, color: Color(0xFF0284C7)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 5,
                            activeTrackColor: const Color(0xFF0284C7),
                            inactiveTrackColor: const Color(0xFF0284C7).withValues(alpha: 0.18),
                            thumbColor: const Color(0xFF0284C7),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          ),
                          child: Slider(
                            value: audioNotifier.volume,
                            min: 0.0,
                            max: AudioServiceNotifier.maxSafeVolume,
                            onChanged: (val) => audioNotifier.setVolume(val),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(audioNotifier.volume * 100).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0284C7)),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. SECONDARY SOUND SECTION (When Enabled)
                if (isMixerEnabled) ...[
                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSi ? '2. පසුබිමින් මිශ්‍ර වන දෙවන නාදය' : '2. SECONDARY BACKGROUND LAYER',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      if (secondaryTrack != null)
                        Text(
                          isSi ? _getTrackTitleSi(secondaryTrack.id) : _cleanTrackTitle(secondaryTrack.title),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFB45309),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Secondary Track Grid Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: defaultTracks.map((track) {
                      final isSelected = secondaryTrack != null && track.id == secondaryTrack.id;
                      return ScaleButton(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          audioNotifier.selectSecondaryTrack(track);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFD97706)
                                : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFFFBEB)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD97706)
                                  : (isDark ? Colors.white12 : const Color(0xFFD97706).withValues(alpha: 0.25)),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFD97706).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                track.icon,
                                size: 17,
                                color: isSelected ? Colors.white : const Color(0xFFD97706),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSi ? _getTrackTitleSi(track.id) : _cleanTrackTitle(track.title),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Secondary Volume Slider
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : goldAmber).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark ? Colors.white12 : goldAmber.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.graphic_eq_rounded, size: 20, color: Color(0xFFD97706)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 5,
                              activeTrackColor: const Color(0xFFD97706),
                              inactiveTrackColor: const Color(0xFFD97706).withValues(alpha: 0.2),
                              thumbColor: const Color(0xFFD97706),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                            ),
                            child: Slider(
                              value: audioNotifier.secondaryVolume,
                              min: 0.0,
                              max: AudioServiceNotifier.maxSafeVolume,
                              onChanged: (val) => audioNotifier.setSecondaryVolume(val),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(audioNotifier.secondaryVolume * 100).round()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFD97706)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // QUICK SOUNDSCAPE PRESETS
                Text(
                  isSi ? 'ක්ෂණිකව සකස් කළ සුවදායී නාද සංකලන' : 'QUICK SOUNDSCAPE PRESETS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _PresetTile(
                        title: '🌧️ Cozy Rain',
                        subtitle: isSi ? 'වැස්ස + රැහැයියන්' : 'Rain + Crickets',
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
                        subtitle: isSi ? 'සාගරය + Pink Noise' : 'Ocean + Pink Noise',
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PresetTile(
                        title: '🌲 Deep Forest',
                        subtitle: isSi ? 'වනාන්තරය + Brown Noise' : 'Forest + Brown Noise',
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
                        subtitle: isSi ? 'දිය ඇල්ල + වනාන්තරය' : 'Waterfall + Forest',
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

                const SizedBox(height: 26),

                // Big Senior-Friendly Play / Control Button
                ScaleButton(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    if (isPlaying) {
                      await audioNotifier.pause();
                    } else {
                      await audioNotifier.play();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: isPlaying
                          ? const LinearGradient(
                              colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF0C4648), Color(0xFF0284C7)],
                            ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: (isPlaying ? const Color(0xFFEA580C) : const Color(0xFF0284C7)).withValues(alpha: 0.35),
                          blurRadius: 12,
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
                            color: Colors.white,
                            barWidth: 3,
                            maxHeight: 16,
                            barCount: 3,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isPlaying
                              ? (isSi ? 'නාදය නවත්වන්න (Pause)' : 'Pause Soundscape')
                              : (isSi ? 'නාදය අසන්න (Play Blended Sound)' : 'Play Blended Soundscape'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    final textColor = isDark ? const Color(0xFFE8F6F4) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF506E70);

    return ScaleButton(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0FDF4)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                color: subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
