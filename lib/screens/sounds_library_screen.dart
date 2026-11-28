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
import '../widgets/add_custom_sound_sheet.dart';

class SoundsLibraryScreen extends ConsumerStatefulWidget {
  const SoundsLibraryScreen({super.key});

  @override
  ConsumerState<SoundsLibraryScreen> createState() => _SoundsLibraryScreenState();
}

class _SoundsLibraryScreenState extends ConsumerState<SoundsLibraryScreen> {
  bool _showAllCatalog = false;

  @override
  Widget build(BuildContext context) {
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
    const primaryTeal = Color(0xFF0C4648);

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

    final hasPersonalizedSound = customSounds.isNotEmpty;
    // As requested: Only that relevant sound is shown on their interface!
    final allTracks = (hasPersonalizedSound && !_showAllCatalog)
        ? customSounds
        : [...customSounds, ...defaultTracks];

    final String pageTitle = (hasPersonalizedSound && !_showAllCatalog)
        ? (isSi ? 'ඔබගේ පුද්ගලික ශබ්ද' : 'Your Personal Sounds')
        : (isSi ? 'සුව නින්දේ ශබ්ද' : 'Sleep Soundscapes');

    final String pageSubtitle = (hasPersonalizedSound && !_showAllCatalog)
        ? (isSi ? 'ඔබට නියමිත AI නාද සහ ඔබ එක් කළ සියලුම ශබ්ද.' : 'Your personalized AI therapy and imported soundscapes.')
        : (isSi ? 'සුවබර නින්ද සඳහා සුවිශේෂී ස්වභාවික නාද.' : 'Curated audio for deep restorative rest.');

    final String countBadge = (hasPersonalizedSound && !_showAllCatalog)
        ? (isSi ? '${customSounds.length} ශබ්ද' : '${customSounds.length} Sounds')
        : (isSi ? '${allTracks.length} ශබ්ද' : '${allTracks.length} Sounds');

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

                  // Header title & count badge (Full width so words never break)
                  Text(
                    pageTitle,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    pageSubtitle,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action Buttons Row (Add Sound & Prescribed Badge)
                  Row(
                    children: [
                      ScaleButton(
                        onTap: () => showAddCustomSoundSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0C4648), Color(0xFF165B5F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0C4648).withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_circle_outline_rounded,
                                size: 16,
                                color: Color(0xFF70D6CE),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSi ? 'ශබ්දයක් එක්කරන්න' : 'Add Sound',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0xFF1E3A40) : const Color(0xFFE6F4F2)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF5ED1C7).withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: isDark ? const Color(0xFF70D6CE) : primaryTeal,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              countBadge,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF70D6CE) : primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sleek Frosted Glass Sleep Timer & Active Controls Card
                  GlassCard(
                    borderRadius: 24,
                    blur: 18,
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 18),
                    borderColor: Colors.white.withValues(alpha: isDark ? 0.12 : 0.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  child: Icon(Icons.pause_rounded, color: textColor, size: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.volume_up_rounded, color: textColor, size: 18),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    activeTrackColor: textColor,
                                    inactiveTrackColor: textColor.withValues(alpha: 0.15),
                                    thumbColor: textColor,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
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
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(height: 1, color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1)),
                          const SizedBox(height: 10),
                        ],

                        // Sleep Timer Header & Live Time
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, color: textColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isSi ? 'නින්දේ ටයිමරය' : 'Auto-Off Sleep Timer',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                            ),
                            const Spacer(),
                            if (isPlaying && audioNotifier.secondsRemaining > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648)).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: (isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648)).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.hourglass_bottom_rounded, size: 13, color: textColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Off in ${audioNotifier.formattedTimeRemaining}',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: textColor),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ScaleButton(
                                onTap: () => _showCustomSleepTimerSheet(context, audioNotifier, isSi, isDark),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648)).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: (isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648)).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.tune_rounded, size: 13, color: textColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${audioNotifier.customTimerMinutes}m',
                                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Interactive Live Slider on Card (5 to 180 Minutes)
                        Row(
                          children: [
                            Text(
                              '5m',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 3.5,
                                  activeTrackColor: textColor,
                                  inactiveTrackColor: textColor.withValues(alpha: 0.12),
                                  thumbColor: textColor,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                ),
                                child: Slider(
                                  value: audioNotifier.customTimerMinutes.toDouble().clamp(5.0, 180.0),
                                  min: 5,
                                  max: 180,
                                  divisions: 35,
                                  onChanged: (val) {
                                    audioNotifier.setCustomMinutes(val.round());
                                  },
                                ),
                              ),
                            ),
                            Text(
                              '180m',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Sleep Timer Presets Row (Clean pills)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              ...[
                                SleepTimerPreset.min15,
                                SleepTimerPreset.min30,
                                SleepTimerPreset.min45,
                                SleepTimerPreset.min60,
                                SleepTimerPreset.allNight,
                              ].map((preset) {
                                final isSelected = audioNotifier.selectedPreset == preset;
                                final label = preset == SleepTimerPreset.allNight
                                    ? (isSi ? 'මුළු රාත්‍රියම' : 'All Night')
                                    : (isSi ? '${preset.minutes} මි' : '${preset.minutes}m');

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ScaleButton(
                                    onTap: () {
                                      audioNotifier.setTimerPreset(preset);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? textColor
                                            : (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? textColor
                                              : (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.14),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          color: isSelected
                                              ? (isDark ? const Color(0xFF0B1F23) : Colors.white)
                                              : textColor,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
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
                                        if (track.category == 'User Custom' || track.id.startsWith('user_sound_')) ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.phone_android_rounded,
                                                size: 13,
                                                color: isDark ? const Color(0xFFFFAE85) : const Color(0xFFC2410C),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isSi ? 'දුරකථනයෙන් එක් කළ ශබ්දය' : 'Imported from Phone',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? const Color(0xFFFFAE85) : const Color(0xFFC2410C),
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                        ] else if (track.category == 'AI Personalized' || track.id.startsWith('ai_bespoke_')) ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.auto_awesome_rounded,
                                                size: 13,
                                                color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isSi ? 'ඔබටම වෙන්වූ නාදය' : 'AI Prescribed for You',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B),
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                        ],
                                        Text(
                                          (track.category == 'AI Personalized' || track.id.startsWith('ai_bespoke_'))
                                              ? track.title
                                              : track.title
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
                                          (track.category == 'AI Personalized' || track.id.startsWith('ai_bespoke_'))
                                              ? (track.description.isNotEmpty ? track.description : (isSi ? 'පුද්ගලීකෘත AI නින්දේ නාදය' : 'AI Restorative Harmonic Loop'))
                                              : 'Restorative Ambient Loop',
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
                            if (track.category == 'User Custom' || track.id.startsWith('user_sound_')) ...[
                              ScaleButton(
                                onTap: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: isDark ? const Color(0xFF13272C) : Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Text(
                                        isSi ? 'ශබ්දය ඉවත් කරන්නද?' : 'Delete Sound?',
                                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                                      ),
                                      content: Text(
                                        isSi
                                            ? '"${track.title}" ශබ්දය ඔබගේ Library එකෙන් ඉවත් කිරීමට අවශ්‍යද?'
                                            : 'Are you sure you want to remove "${track.title}" from your library?',
                                        style: TextStyle(color: subtitleColor),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(false),
                                          child: Text(isSi ? 'නැත' : 'Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: Text(
                                            isSi ? 'ඉවත් කරන්න' : 'Delete',
                                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    if (track.id == currentTrack.id && isPlaying) {
                                      await audioNotifier.stop();
                                    }
                                    await ref.read(customSoundProvider.notifier).deleteCustomSound(track.id);
                                  }
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                ),
                              ),
                            ],
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

                  if (hasPersonalizedSound) ...[
                    const SizedBox(height: 14),
                    Center(
                      child: ScaleButton(
                        onTap: () => setState(() => _showAllCatalog = !_showAllCatalog),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showAllCatalog ? Icons.check_circle_outline_rounded : Icons.explore_outlined,
                                size: 15,
                                color: subtitleColor,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                _showAllCatalog
                                    ? (isSi ? 'මගේ නාදය පමණක් පෙන්වන්න' : 'Show Only My Prescribed Sound')
                                    : (isSi ? 'අනෙකුත් සියලුම ශබ්ද බලන්න' : 'Explore All Catalog Sounds'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Space for floating bottom glass dock & mini player
                  const SizedBox(height: 130),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomSleepTimerSheet(
    BuildContext context,
    AudioServiceNotifier audioNotifier,
    bool isSi,
    bool isDark,
  ) {
    int currentMinutes = audioNotifier.customTimerMinutes;
    const primaryTeal = Color(0xFF0C4648);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final now = DateTime.now();
            final endTime = now.add(Duration(minutes: currentMinutes));
            final endHour = endTime.hour > 12 ? endTime.hour - 12 : (endTime.hour == 0 ? 12 : endTime.hour);
            final endMin = endTime.minute.toString().padLeft(2, '0');
            final endPeriod = endTime.hour >= 12 ? 'PM' : 'AM';
            final formattedEndTime = '$endHour:$endMin $endPeriod';

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF13272C) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5ED1C7).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.timer_outlined, color: isDark ? const Color(0xFF5ED1C7) : primaryTeal, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSi ? 'නින්දේ ටයිමරය (කැමති වේලාවක්)' : 'Custom Sleep Timer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : primaryTeal,
                                ),
                              ),
                              Text(
                                isSi ? 'ශබ්දය නැවතීමට කැමති කාලය තෝරන්න' : 'Choose how long audio plays before fading out',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : const Color(0xFF5A7275),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Luminous Minutes Display Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$currentMinutes',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSi ? 'විනාඩි' : 'Minutes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : const Color(0xFF5A7275),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5ED1C7).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isSi ? 'නැවතෙන වේලාව: $formattedEndTime' : 'Audio will stop at: $formattedEndTime',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Slider for minutes
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        activeTrackColor: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                        inactiveTrackColor: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.15),
                        thumbColor: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: Slider(
                        value: currentMinutes.toDouble().clamp(5.0, 180.0),
                        min: 5,
                        max: 180,
                        divisions: 35,
                        onChanged: (val) {
                          setSheetState(() {
                            currentMinutes = val.round();
                          });
                        },
                      ),
                    ),

                    // Quick presets row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [10, 20, 40, 60, 90, 120].map((mins) {
                        final isCurrent = currentMinutes == mins;
                        return ScaleButton(
                          onTap: () {
                            setSheetState(() {
                              currentMinutes = mins;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? (isDark ? const Color(0xFF5ED1C7) : primaryTeal)
                                  : (isDark ? Colors.white.withValues(alpha: 0.08) : primaryTeal.withValues(alpha: 0.06)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isCurrent
                                    ? (isDark ? const Color(0xFF5ED1C7) : primaryTeal)
                                    : (isDark ? Colors.white12 : primaryTeal.withValues(alpha: 0.12)),
                              ),
                            ),
                            child: Text(
                              isSi ? '$mins මි' : '$mins m',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                color: isCurrent
                                    ? (isDark ? const Color(0xFF0C1F23) : Colors.white)
                                    : (isDark ? Colors.white70 : primaryTeal),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Exact Clock Time Picker Button
                    ScaleButton(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: endTime.hour, minute: endTime.minute),
                        );
                        if (picked != null) {
                          final pickedDateTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            picked.hour,
                            picked.minute,
                          );
                          var diff = pickedDateTime.difference(now).inMinutes;
                          if (diff <= 0) {
                            diff += 24 * 60; // Next day
                          }
                          setSheetState(() {
                            currentMinutes = diff.clamp(1, 480);
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time_rounded, size: 16, color: isDark ? const Color(0xFF5ED1C7) : primaryTeal),
                            const SizedBox(width: 8),
                            Text(
                              isSi ? 'නිශ්චිත ඔරලෝසු වේලාවක් තෝරන්න (Time Picker)' : 'Choose exact clock time (Time Picker)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Apply Button
                    ScaleButton(
                      onTap: () {
                        audioNotifier.setCustomMinutes(currentMinutes);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: primaryTeal,
                            content: Text(
                              isSi
                                  ? 'සුව නින්දේ ටයිමරය විනාඩි $currentMinutes කට සකසන ලදී.'
                                  : 'Sleep timer set for $currentMinutes minutes.',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0C4648), Color(0xFF1E676B)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: primaryTeal.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isSi ? 'ටයිමරය සක්‍රිය කරන්න (Set Timer)' : 'Set Sleep Timer',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
