import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/sound_model.dart';
import '../providers/hydration_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/sleep_rating_dialog.dart';
import '../widgets/scale_button.dart';
import '../widgets/sound_visualizer_widget.dart';
import '../widgets/water_wave_progress.dart';
import '../widgets/glass_card.dart';
import '../widgets/voice_assistant_sheet.dart';
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

    final isSi = settingsState.isSinhala;
    final isPlaying = audioNotifier.isPlaying && audioNotifier.currentTrack.id == currentSound.id;
    final displayName = user != null && user.name.isNotEmpty ? user.name : (isSi ? 'පරිශීලකයා' : 'Guest User');

    // Calculate dynamic time and greeting
    final now = DateTime.now();
    final hour = now.hour;
    final timeString = DateFormat('h:mm a').format(now);
    final dateString = DateFormat('EEEE, MMM d').format(now);

    String greeting;
    String subtitle;

    if (hour >= 5 && hour < 12) {
      greeting = isSi ? 'සුබ උදෑසනක්' : 'Good morning';
      subtitle = isSi ? 'නැවුම් දවසකට සූදානම් වන්න.' : 'Ready for a refreshing day.';
    } else if (hour >= 12 && hour < 17) {
      greeting = isSi ? 'සුබ දහවලක්' : 'Good afternoon';
      subtitle = isSi ? 'ප්‍රමාණවත් ලෙස ජලය පානය කරන්න.' : 'Stay hydrated and focused.';
    } else {
      greeting = isSi ? 'සුබ සැන්දෑවක්' : 'Good evening';
      subtitle = isSi ? 'විවේකීව සහ සුවබරව සිටින්න.' : 'Time to rest and restore.';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Glassmorphic Background Aura Blobs
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF0C4648) : const Color(0xFFBDE4E1)).withValues(alpha: 0.38),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF163C42) : const Color(0xFFD5ECE7)).withValues(alpha: 0.32),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8AB80).withValues(alpha: isDark ? 0.15 : 0.22),
              ),
            ),
          ),

          SafeArea(
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

                    const SizedBox(height: 24),

                    // Time & Date Frosted Glass Pill
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.12),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded, size: 15, color: subtitleColor),
                              const SizedBox(width: 7),
                              Text(
                                '$timeString  •  $dateString',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: subtitleColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Greeting Section
                    Text(
                      '$greeting, $displayName.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Senior-Friendly Voice Assistant Quick Access Card
                    ScaleButton(
                      onTap: () => showVoiceAssistantModal(context),
                      child: GlassCard(
                        borderRadius: 20,
                        blur: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: EdgeInsets.zero,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFFAE85), Color(0xFFF89966)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(Icons.mic_rounded, size: 20, color: Color(0xFF4D2411)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSi ? 'හඬ සහායක' : 'Voice Assistant',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    isSi
                                        ? 'ටැප් කර කතා කරන්න: "වතුර 250ml බිව්වා" හෝ "වැසි නාදය"'
                                        : 'Tap to speak: "Log 250ml water" or "Play rain"',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subtitleColor),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // LAST PLAYED Card with Animated Equalizer Visualizer & Glass Look
                    GlassCard(
                      borderRadius: 22,
                      blur: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      margin: EdgeInsets.zero,
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
                                      isSi ? 'අවසන් වරට වාදනය වූ' : 'LAST PLAYED',
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
                                          isSi
                                              ? '• ස්වයංක්‍රීයව නතර වේ ${audioNotifier.formattedTimeRemaining}'
                                              : '• Auto-off ${audioNotifier.formattedTimeRemaining}',
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: isPlaying ? 0.6 : 0.25),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  if (isPlaying)
                                    BoxShadow(
                                      color: const Color(0xFFF8AB80).withValues(alpha: 0.45),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
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

                    const SizedBox(height: 14),

                    // Morning Sleep Journal Check-in Glass Banner
                    GlassCard(
                      borderRadius: 20,
                      blur: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      margin: EdgeInsets.zero,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const SleepRatingDialog(),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8AB80).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFF8AB80).withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: const Icon(Icons.star_rounded, color: Color(0xFFF8AB80), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSi ? 'උදෑසන නින්දේ තත්ත්වය' : 'Morning Sleep Rating',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSi ? 'ඊයේ රාත්‍රියේ නින්ද කෙබඳුදැයි සටහන් කරන්න' : 'Log how well you rested last night',
                                  style: TextStyle(fontSize: 13, color: subtitleColor),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: subtitleColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Fluid Wave Hydration Display Inside Glass Card
                    GlassCard(
                      borderRadius: 26,
                      blur: 20,
                      padding: const EdgeInsets.all(16),
                      margin: EdgeInsets.zero,
                      child: Center(
                        child: WaterWaveProgress(
                          progress: progress,
                          height: 190,
                          baseColor: isDark ? const Color(0xFF13272C).withValues(alpha: 0.7) : const Color(0xFFE8F6F4).withValues(alpha: 0.7),
                          waveColor: isDark ? const Color(0xFF22525A).withValues(alpha: 0.85) : const Color(0xFFBDE4E1).withValues(alpha: 0.85),
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
                                isSi ? 'අද බීපු ප්‍රමාණය' : 'logged today',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSi ? 'ඉලක්කය: $displayGoal' : 'Goal: $displayGoal',
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
                    ),

                    const SizedBox(height: 20),

                    // + Log Water Interactive Glass Gradient Button
                    ScaleButton(
                      onTap: () {
                        ref.read(hydrationProvider.notifier).logWater(250);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSi ? 'වතුර 250ml එකතු කළා!' : 'Logged 250ml water!',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color(0xFF0C4648),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFAE85), Color(0xFFF89966)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF8AB80).withValues(alpha: 0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_rounded, size: 24, color: Color(0xFF4D2411)),
                                const SizedBox(width: 8),
                                Text(
                                  isSi ? 'වතුර එකතු කරන්න' : 'Log Water',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4D2411),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Single Clear Entry Point to Sounds (Senior-Friendly)
                    ScaleButton(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen(initialIndex: 1),
                          ),
                        );
                      },
                      child: GlassCard(
                        borderRadius: 20,
                        blur: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        margin: EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.waves_rounded, size: 22, color: textColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                isSi ? 'සියලු ශබ්ද ගවේෂණය' : 'Browse All Soundscapes',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 18, color: subtitleColor),
                          ],
                        ),
                      ),
                    ),

                    // Bottom padding for the floating navigation glass dock
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
