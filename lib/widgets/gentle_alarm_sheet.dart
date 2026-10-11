import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alarm_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';
import 'sleep_rating_dialog.dart';
import 'sound_visualizer_widget.dart';

/// Global helper to show the Gentle Nature Wake-Up Alarm Modal Sheet
void showGentleAlarmModal(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => const GentleAlarmSheet(),
  );
}

class GentleAlarmSheet extends ConsumerWidget {
  const GentleAlarmSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarm = ref.watch(alarmProvider);
    final alarmNotifier = ref.read(alarmProvider.notifier);
    final audioNotifier = ref.read(audioServiceProvider);

    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTeal = const Color(0xFF0C4648);
    final goldAmber = const Color(0xFFFFAE85);
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.88,
        ),
        margin: const EdgeInsets.only(top: 12),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF13272C).withValues(alpha: 0.90),
                      const Color(0xFF0C1F23).withValues(alpha: 0.94),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.88),
                      const Color(0xFFE8F6F4).withValues(alpha: 0.90),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.75),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.4 : 0.16),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: goldAmber.withValues(alpha: 0.2),
                        border: Border.all(
                          color: goldAmber.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.wb_sunny_rounded, size: 24, color: Color(0xFFF89966)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSi ? 'මෘදු ස්වභාවික නාද ඇලාම්' : 'Gentle Nature Alarm',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isSi
                                ? 'තිගැස්සීමකින් තොරව ක්‍රමයෙන් අවදි කරන සුවදායී ඇලාමය'
                                : 'Gradually fades in soft nature sounds without startling you',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : const Color(0xFF5A7275),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
                      onPressed: () {
                        alarmNotifier.stopPreview(audioNotifier);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Luminous Glass Digital Clock Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.14),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSi ? 'ඇලාම් වේලාව' : 'Wake-up Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: isDark ? Colors.white60 : const Color(0xFF5A7275),
                                ),
                              ),
                              const SizedBox(height: 4),
                              ScaleButton(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(hour: alarm.hour, minute: alarm.minute),
                                  );
                                  if (picked != null) {
                                    alarmNotifier.setTime(picked);
                                  }
                                },
                                child: Text(
                                  alarm.formattedTime,
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : primaryTeal,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: alarm.isEnabled,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF5ED1C7),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFF32545A),
                            onChanged: (val) {
                              alarmNotifier.toggleEnabled(val);
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.touch_app_rounded, size: 14, color: isDark ? Colors.white54 : const Color(0xFF5A7275)),
                          const SizedBox(width: 4),
                          Text(
                            isSi ? 'වේලාව මත ටැප් කර වෙනස් කරන්න' : 'Tap time to adjust hours & minutes',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : const Color(0xFF5A7275),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Nature Sound Selector
                Text(
                  isSi ? 'ස්වභාවික ඇලාම් නාදය තෝරන්න' : 'NATURE WAKE-UP SOUND',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white60 : const Color(0xFF5A7275),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _buildSoundOption(
                      title: isSi ? '🌧️ වැසි නාදය' : '🌧️ Rainfall',
                      soundId: 'rainfall',
                      isSelected: alarm.soundId == 'rainfall',
                      onTap: () => alarmNotifier.setSound('rainfall'),
                      isDark: isDark,
                      primaryTeal: primaryTeal,
                    ),
                    const SizedBox(width: 8),
                    _buildSoundOption(
                      title: isSi ? '🌊 මුහුදු රළ' : '🌊 Ocean Tide',
                      soundId: 'ocean',
                      isSelected: alarm.soundId == 'ocean',
                      onTap: () => alarmNotifier.setSound('ocean'),
                      isDark: isDark,
                      primaryTeal: primaryTeal,
                    ),
                    const SizedBox(width: 8),
                    _buildSoundOption(
                      title: isSi ? '🏞️ දිය ඇල්ල' : '🏞️ Waterfall',
                      soundId: 'waterfall',
                      isSelected: alarm.soundId == 'waterfall',
                      onTap: () => alarmNotifier.setSound('waterfall'),
                      isDark: isDark,
                      primaryTeal: primaryTeal,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Gradual Fade-in Duration Selector
                Text(
                  isSi ? 'ශබ්දය සෙමෙන් වැඩිවන කාලය (FADE-IN)' : 'GENTLE FADE-IN DURATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white60 : const Color(0xFF5A7275),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [3, 5, 10].map((mins) {
                    final isSelected = alarm.fadeInMinutes == mins;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ScaleButton(
                          onTap: () => alarmNotifier.setFadeInMinutes(mins),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF1E676B) : primaryTeal)
                                  : (isDark ? Colors.white.withValues(alpha: 0.06) : primaryTeal.withValues(alpha: 0.05)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF5ED1C7)
                                    : (isDark ? Colors.white12 : primaryTeal.withValues(alpha: 0.12)),
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isSi ? 'විනාඩි $mins' : '$mins Mins',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : primaryTeal),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Preview Progressive Fade-in Button
                ScaleButton(
                  onTap: () {
                    if (alarmNotifier.isPreviewing) {
                      alarmNotifier.stopPreview(audioNotifier);
                    } else {
                      alarmNotifier.startPreview(audioNotifier);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: alarmNotifier.isPreviewing
                            ? [const Color(0xFFFFAE85), const Color(0xFFF89966)]
                            : [
                                const Color(0xFF0C4648).withValues(alpha: 0.92),
                                const Color(0xFF1E676B).withValues(alpha: 0.92),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (alarmNotifier.isPreviewing ? const Color(0xFFF8AB80) : primaryTeal).withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (alarmNotifier.isPreviewing) ...[
                          SoundVisualizerWidget(
                            isPlaying: true,
                            color: const Color(0xFF4D2411),
                            barWidth: 3,
                            maxHeight: 14,
                            barCount: 3,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSi ? 'නැවත්වීම' : 'Stop Preview',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4D2411),
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isSi ? 'ශබ්දය සෙමෙන් වැඩිවීම අත්හදා බලන්න' : 'Preview Gentle Fade-in',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Morning Sleep Quality Rating Button (Wake-up Check-in)
                ScaleButton(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const SleepRatingDialog(),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark ? Colors.white12 : primaryTeal).withValues(alpha: 0.14),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF8AB80), size: 19),
                        const SizedBox(width: 8),
                        Text(
                          isSi
                              ? 'අවදි වූ පසු නින්දේ සුවතාවය සටහන් කරන්න'
                              : 'Rate Morning Sleep Quality',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : primaryTeal,
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
    ),
  ),
);
}

  Widget _buildSoundOption({
    required String title,
    required String soundId,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryTeal,
  }) {
    return Expanded(
      child: ScaleButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1E676B) : primaryTeal)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : primaryTeal.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF5ED1C7)
                  : (isDark ? Colors.white12 : primaryTeal.withValues(alpha: 0.12)),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : primaryTeal),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
