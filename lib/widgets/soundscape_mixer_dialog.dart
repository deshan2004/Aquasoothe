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

class _SoundMeta {
  final String emoji;
  final IconData icon;
  final Color themeColor;
  final Color bgColor;
  final String titleEn;
  final String titleSi;
  final String descEn;
  final String descSi;

  const _SoundMeta({
    required this.emoji,
    required this.icon,
    required this.themeColor,
    required this.bgColor,
    required this.titleEn,
    required this.titleSi,
    required this.descEn,
    required this.descSi,
  });
}

class SoundscapeMixerDialog extends ConsumerWidget {
  const SoundscapeMixerDialog({super.key});

  static const Map<String, _SoundMeta> _meta = {
    'waterfall': _SoundMeta(
      emoji: '🏞️',
      icon: Icons.water_rounded,
      themeColor: Color(0xFF06B6D4),
      bgColor: Color(0xFFE0F7FA),
      titleEn: 'Waterfall',
      titleSi: 'දිය ඇල්ල',
      descEn: 'Fresh flowing cascade',
      descSi: 'නැවුම් දිය පහර',
    ),
    'ocean': _SoundMeta(
      emoji: '🌊',
      icon: Icons.waves_rounded,
      themeColor: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
      titleEn: 'Ocean Waves',
      titleSi: 'සාගර රළ',
      descEn: 'Gentle rhythmic tides',
      descSi: 'සන්සුන් මුහුදු රළ',
    ),
    'rainfall': _SoundMeta(
      emoji: '🌧️',
      icon: Icons.water_drop_rounded,
      themeColor: Color(0xFF0EA5E9),
      bgColor: Color(0xFFE0F2FE),
      titleEn: 'Gentle Rain',
      titleSi: 'සුවදායී වැස්ස',
      descEn: 'Soft rain on leaves',
      descSi: 'මනස නිවන වැස්ස',
    ),
    'forest': _SoundMeta(
      emoji: '🌲',
      icon: Icons.park_rounded,
      themeColor: Color(0xFF10B981),
      bgColor: Color(0xFFD1FAE5),
      titleEn: 'Forest Wind',
      titleSi: 'වනාන්තරය',
      descEn: 'Whispering pine trees',
      descSi: 'ගස් අතරින් සුළඟ',
    ),
    'crickets': _SoundMeta(
      emoji: '🦗',
      icon: Icons.nightlight_round,
      themeColor: Color(0xFF8B5CF6),
      bgColor: Color(0xFFEDE9FE),
      titleEn: 'Night Crickets',
      titleSi: 'රැහැයියන්',
      descEn: 'Peaceful starry night',
      descSi: 'සන්සුන් රාත්‍රිය',
    ),
    'brown_noise': _SoundMeta(
      emoji: '📻',
      icon: Icons.blur_linear_rounded,
      themeColor: Color(0xFFB45309),
      bgColor: Color(0xFFFEF3C7),
      titleEn: 'Deep Sleep Wave',
      titleSi: 'සුව නින්දේ තරංග',
      descEn: 'Calms racing thoughts',
      descSi: 'නින්ද නොයාමට',
    ),
    'pink_noise': _SoundMeta(
      emoji: '🌸',
      icon: Icons.graphic_eq_rounded,
      themeColor: Color(0xFFEC4899),
      bgColor: Color(0xFFFCE7F3),
      titleEn: 'Noise Blocker',
      titleSi: 'බාහිර ශබ්ද ආවරණය',
      descEn: 'Masks room sounds',
      descSi: 'බාධා වළකයි',
    ),
  };

  _SoundMeta _getMeta(String id, String fallbackTitle) {
    return _meta[id] ??
        _SoundMeta(
          emoji: '🎵',
          icon: Icons.music_note_rounded,
          themeColor: const Color(0xFF0284C7),
          bgColor: const Color(0xFFE0F2FE),
          titleEn: fallbackTitle.replaceAll(RegExp(r'^(Cascading|Soothing|Deep|Gentle)\s+'), ''),
          titleSi: 'ස්වභාවික නාදය',
          descEn: 'Custom soothing sound',
          descSi: 'සුවදායී නාදය',
        );
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

    final primaryMeta = _getMeta(primaryTrack.id, primaryTrack.title);
    final secondaryMeta = secondaryTrack != null ? _getMeta(secondaryTrack.id, secondaryTrack.title) : null;

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
                : Colors.white.withValues(alpha: 0.95),
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

                // 1. PRIMARY SOUND SECTION (OVERFLOW FIXED with Expanded)
                Row(
                  children: [
                    Text(
                      isSi ? '1. ප්‍රධාන ස්වභාවික නාදය' : '1. PRIMARY NATURE SOUND',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${primaryMeta.emoji} ${isSi ? primaryMeta.titleSi : primaryMeta.titleEn}',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Modern 2-Column Senior-Friendly Sound Grid for Primary Layer
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: defaultTracks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.3,
                  ),
                  itemBuilder: (context, index) {
                    final track = defaultTracks[index];
                    final meta = _getMeta(track.id, track.title);
                    final isSelected = track.id == primaryTrack.id;

                    return ScaleButton(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        audioNotifier.selectTrack(track);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? meta.themeColor.withValues(alpha: 0.3) : meta.bgColor)
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? meta.themeColor
                                : (isDark ? Colors.white12 : Colors.black12),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: meta.themeColor.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? meta.themeColor
                                    : (isDark ? Colors.white12 : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: meta.themeColor.withValues(alpha: isSelected ? 0.8 : 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  meta.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSi ? meta.titleSi : meta.titleEn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? (isDark ? Colors.white : meta.themeColor) : textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    isSi ? meta.descSi : meta.descEn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: subtitleColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: meta.themeColor, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // Primary Volume Slider with Glass Frame
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isDark ? Colors.white12 : const Color(0xFF0C4648).withValues(alpha: 0.1)),
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

                // 2. SECONDARY SOUND SECTION (When Enabled - OVERFLOW FIXED with Expanded)
                if (isMixerEnabled) ...[
                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  Row(
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
                      const SizedBox(width: 8),
                      if (secondaryMeta != null)
                        Expanded(
                          child: Text(
                            '${secondaryMeta.emoji} ${isSi ? secondaryMeta.titleSi : secondaryMeta.titleEn}',
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Modern 2-Column Grid for Secondary Track Selection
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: defaultTracks.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.3,
                    ),
                    itemBuilder: (context, index) {
                      final track = defaultTracks[index];
                      final meta = _getMeta(track.id, track.title);
                      final isSelected = secondaryTrack != null && track.id == secondaryTrack.id;

                      return ScaleButton(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          audioNotifier.selectSecondaryTrack(track);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFFD97706).withValues(alpha: 0.3) : const Color(0xFFFEF3C7))
                                : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD97706)
                                  : (isDark ? Colors.white12 : Colors.black12),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFD97706).withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFD97706)
                                      : (isDark ? Colors.white12 : Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFD97706).withValues(alpha: isSelected ? 0.8 : 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    meta.emoji,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSi ? meta.titleSi : meta.titleEn,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? const Color(0xFFB45309) : textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      isSi ? meta.descSi : meta.descEn,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: subtitleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: Color(0xFFD97706), size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Secondary Volume Slider
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : const Color(0xFFD97706)).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark ? Colors.white12 : const Color(0xFFD97706).withValues(alpha: 0.2)),
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
