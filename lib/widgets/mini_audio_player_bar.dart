import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alarm_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/main_navigation_screen.dart';
import 'gentle_alarm_sheet.dart';
import 'scale_button.dart';
import 'sound_visualizer_widget.dart';

/// Floating frosted glass mini player bar displayed above the bottom navigation bar.
/// Displays ambient audio playback, as well as background alarm status & active ringing controls.
class MiniAudioPlayerBar extends ConsumerWidget {
  const MiniAudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.watch(audioServiceProvider);
    final alarm = ref.watch(alarmProvider);
    final alarmNotifier = ref.read(alarmProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final isSi = settings.isSinhala;

    final currentTrack = audioNotifier.currentTrack;
    final isPlaying = audioNotifier.isPlaying;

    // 1. If Alarm is ringing: show full-prominence Ringing / Wake-Up Banner with Turn Off controls
    if (alarm.isRinging) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE25C38),
                    Color(0xFFC0392B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC0392B).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: SoundVisualizerWidget(
                      isPlaying: true,
                      color: Colors.white,
                      barWidth: 3.2,
                      maxHeight: 18,
                      barCount: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSi ? '🌅 ඇලාමය වාදනය වේ!' : '🌅 Alarm Ringing!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSi ? 'නාදය: ${alarm.soundTitleSi}' : 'Sound: ${alarm.soundTitleEn}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Snooze 5m
                  ScaleButton(
                    onTap: () => alarmNotifier.snoozeAlarm(minutes: 5, isSinhala: isSi, overrideNotifier: audioNotifier),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white38),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.snooze_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            isSi ? '5මි' : '5m',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Turn Off Alarm Button
                  ScaleButton(
                    onTap: () => alarmNotifier.turnOffAlarm(audioNotifier),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        isSi ? 'Off කරන්න' : 'Turn Off',
                        style: const TextStyle(
                          color: Color(0xFFC0392B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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

    // 2. Normal Mini Player with integrated active background alarm banner if enabled
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0C4648).withValues(alpha: 0.88),
                  const Color(0xFF006687).withValues(alpha: 0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C4648).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.15),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Background Alarm Status Pill (if alarm is active)
                if (alarm.isEnabled) ...[
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => showGentleAlarmModal(context),
                          child: Row(
                            children: [
                              const Icon(Icons.alarm_on_rounded, color: Color(0xFFFFAE85), size: 14),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  isSi
                                      ? 'ඇලාමය: ${alarm.formattedTime} • ${alarm.soundTitleSi}'
                                      : 'Alarm: ${alarm.formattedTime} • ${alarm.soundTitleEn}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Quick Turn-Off Chip
                      ScaleButton(
                        onTap: () => alarmNotifier.toggleEnabled(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            isSi ? 'Off කරන්න' : 'Turn Off',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFAE85),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 6),
                ],

                // Audio Playback Row
                Row(
                  children: [
                    // Sound Icon or SoundVisualizer in frosted pill
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: isPlaying
                          ? SoundVisualizerWidget(
                              isPlaying: true,
                              color: const Color(0xFFE0F2FE),
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MainNavigationScreen(initialIndex: 1),
                            ),
                          );
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
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPlaying
                                  ? (audioNotifier.secondsRemaining > 0
                                      ? 'Playing • Timer: ${audioNotifier.formattedTimeRemaining}'
                                      : 'Playing Ambient Audio')
                                  : 'Paused',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Play / Pause Action Button
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
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
                          size: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
