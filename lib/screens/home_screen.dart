import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/sound_model.dart';
import '../providers/hydration_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/ai_sound_matcher_dialog.dart';
import '../widgets/soundscape_mixer_dialog.dart';
import '../widgets/sleep_rating_dialog.dart';
import '../widgets/scale_button.dart';
import '../widgets/sound_visualizer_widget.dart';
import '../widgets/water_wave_progress.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final hydrationState = ref.watch(hydrationProvider);
    final audioNotifier = ref.watch(audioServiceProvider);
    final settingsState = ref.watch(settingsProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);
    final cardBg = isDark ? const Color(0xFF13272C) : const Color(0xFFE8F6F4);

    final goal = hydrationState.goal;
    final todayTotalMl = hydrationState.todayTotalMl;
    final progress = hydrationState.todayProgress;
    final unit = goal.preferredUnit;
    final displayIntake = unit == 'ml'
        ? '${todayTotalMl.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ml'
        : '${(todayTotalMl / 250).toStringAsFixed(1)} cups';
    final displayGoal = unit == 'ml'
        ? '${goal.dailyTargetMl.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ml'
        : '${goal.dailyTargetCups} cups';

    final lastSoundId = settingsState.lastUsedSoundId;
    final currentSound = SoundTrack.defaultTracks.firstWhere(
      (t) => t.id == lastSoundId,
      orElse: () => SoundTrack.defaultTracks[1], // Default Ocean/Deep Ocean
    );

    final isPlaying = audioNotifier.isPlaying && audioNotifier.currentTrack.id == currentSound.id;
    final displayName = user != null && user.name.isNotEmpty ? user.name : 'Guest User';

    // Calculate dynamic time and greeting
    final now = DateTime.now();
    final hour = now.hour;
    final timeString = DateFormat('h:mm a').format(now);
    final dateString = DateFormat('EEEE, MMM d').format(now);

    String greeting;
    String subtitle;

    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning';
      subtitle = 'Ready for a refreshing day.';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
      subtitle = 'Stay hydrated and focused.';
    } else {
      greeting = 'Good evening';
      subtitle = 'Time to rest and restore.';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0C4648),
          backgroundColor: Colors.white,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
            ref.invalidate(hydrationProvider);
            ref.invalidate(settingsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logo
                const AquaSootheHeader(isCentered: false),

                const SizedBox(height: 28),

                // Time & Date Chip/Row
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: subtitleColor),
                    const SizedBox(width: 6),
                    Text(
                      '$timeString  •  $dateString',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Greeting Section (Dynamic Morning / Afternoon / Evening)
                Text(
                  '$greeting, $displayName.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 18,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 28),

                // LAST PLAYED Card with Animated Equalizer Visualizer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF1E3A40) : const Color(0xFFD6EBE8), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'LAST PLAYED',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: subtitleColor,
                                  ),
                                ),
                                if (isPlaying) ...[
                                  const SizedBox(width: 8),
                                  SoundVisualizerWidget(
                                    isPlaying: true,
                                    color: textColor,
                                    barWidth: 3,
                                    maxHeight: 14,
                                    barCount: 3,
                                  ),
                                  if (audioNotifier.secondsRemaining > 0) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '• Auto-off ${audioNotifier.formattedTimeRemaining}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentSound.id == 'ocean' ? 'Deep Ocean' : currentSound.title,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ScaleButton(
                        onTap: () async {
                          if (isPlaying) {
                            await audioNotifier.pause();
                          } else {
                            await audioNotifier.selectTrack(currentSound);
                            await audioNotifier.play();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isPlaying ? const Color(0xFFF8AB80) : (isDark ? const Color(0xFF1E3A40) : const Color(0xFFEFE6D8)),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (isPlaying)
                                BoxShadow(
                                  color: const Color(0xFFF8AB80).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: isPlaying ? const Color(0xFF4D2411) : (isDark ? Colors.white : const Color(0xFF3D2E1E)),
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Morning Sleep Journal Check-in Banner
                ScaleButton(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const SleepRatingDialog(),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF13272C) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isDark ? const Color(0xFF1E3A40) : const Color(0xFFD6EBE8)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A40) : const Color(0xFFE1F2F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.star_rounded, color: Color(0xFFF8AB80), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Morning Sleep Rating',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Log how well you rested last night',
                                style: TextStyle(fontSize: 13, color: subtitleColor),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: subtitleColor),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Fluid Wave Hydration Display Card
                Center(
                  child: WaterWaveProgress(
                    progress: progress,
                    height: 180,
                    baseColor: isDark ? const Color(0xFF13272C) : const Color(0xFFE8F6F4),
                    waveColor: isDark ? const Color(0xFF22525A) : const Color(0xFFBDE4E1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayIntake,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'logged today',
                          style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Goal: $displayGoal',
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // + Log Water Button
                ScaleButton(
                  onTap: () {
                    ref.read(hydrationProvider.notifier).logWater(250);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged 250ml water!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        backgroundColor: Color(0xFF0C4648),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8AB80),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF8AB80).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, size: 24, color: Color(0xFF4D2411)),
                        SizedBox(width: 8),
                        Text(
                          'Log Water',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4D2411),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Launcher for Sound Studio, AI Matcher & Sound Library
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          builder: (_) => const SoundscapeMixerDialog(),
                        );
                      },
                      icon: Icon(Icons.layers_rounded, size: 18, color: textColor),
                      label: Text(
                        'Sound Studio',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          builder: (_) => const AISoundMatcherDialog(),
                        );
                      },
                      icon: Icon(Icons.auto_awesome_rounded, size: 18, color: textColor),
                      label: Text(
                        'AI Matcher',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen(initialIndex: 1),
                          ),
                        );
                      },
                      icon: Icon(Icons.tune_rounded, size: 18, color: textColor),
                      label: Text(
                        'All Sounds',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
