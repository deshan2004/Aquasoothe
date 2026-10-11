import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hydration_model.dart';
import '../providers/hydration_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/scale_button.dart';
import '../widgets/water_wave_progress.dart';
import '../widgets/weekly_hydration_chart.dart';
import '../widgets/glass_card.dart';

class HydrationScreen extends ConsumerWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final hydrationState = ref.watch(hydrationProvider);
    final goal = hydrationState.goal;
    final todayTotalMl = hydrationState.todayTotalMl;
    final progress = hydrationState.todayProgress.clamp(0.0, 1.0);
    final unit = goal.preferredUnit;

    final displayTotal = unit == 'ml'
        ? '${todayTotalMl.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ml'
        : (isSi ? '${(todayTotalMl / 250).toStringAsFixed(1)} කෝප්ප' : '${(todayTotalMl / 250).toStringAsFixed(1)} cups');
    final displayGoal = unit == 'ml'
        ? (isSi
            ? '${goal.dailyTargetMl.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ml ඉලක්කය'
            : '${goal.dailyTargetMl.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ml goal')
        : (isSi ? '${goal.dailyTargetCups} කෝප්ප ඉලක්කය' : '${goal.dailyTargetCups} cups goal');

    final logs = hydrationState.todayLogs;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Aura Blobs
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF0C4648) : const Color(0xFFBDE4E1)).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            top: 260,
            left: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF163C42) : const Color(0xFFD5ECE7)).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8AB80).withValues(alpha: isDark ? 0.12 : 0.18),
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
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header
                    const AquaSootheHeader(isCentered: false),

                    const SizedBox(height: 24),

                    // Title & Subtitle
                    Text(
                      isSi ? 'දෛනික ජල පරිභෝජනය' : 'Daily Hydration',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSi ? 'සුවතාවය සඳහා ප්‍රමාණවත් ලෙස ජලය පානය කරන්න.' : 'Stay mindful. Replenish your body.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animated Fluid Wave Progress Inside Glass Card
                    GlassCard(
                      borderRadius: 26,
                      blur: 20,
                      padding: const EdgeInsets.all(18),
                      margin: EdgeInsets.zero,
                      child: WaterWaveProgress(
                        progress: progress,
                        height: 220,
                        baseColor: isDark ? const Color(0xFF13272C).withValues(alpha: 0.7) : const Color(0xFFD5ECE7).withValues(alpha: 0.7),
                        waveColor: isDark ? const Color(0xFF22525A).withValues(alpha: 0.85) : const Color(0xFF5F8B88).withValues(alpha: 0.85),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayTotal,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: progress > 0.55 ? Colors.white : textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isSi ? '$displayGoal න්' : 'of $displayGoal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: progress > 0.55 ? const Color(0xFFE2F3F0) : subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Preset Quick Log Glass Pills (150ml, 250ml, 500ml)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [150, 250, 500].map((amount) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GlassCard(
                              borderRadius: 18,
                              blur: 14,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              margin: EdgeInsets.zero,
                              onTap: () {
                                ref.read(hydrationProvider.notifier).logWater(amount);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSi ? 'වතුර ${amount}ml එකතු කළා!' : 'Logged ${amount}ml of water!',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: const Color(0xFF0C4648),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.local_drink_rounded, color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648), size: 22),
                                  const SizedBox(height: 4),
                                  Text(
                                    '+$amount ml',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // + Log Water Primary Action Button
                    ScaleButton(
                      onTap: () {
                        ref.read(hydrationProvider.notifier).logWater(250);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSi ? 'වතුර 250ml එකතු කළා!' : 'Logged 250ml of water!',
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
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_rounded, size: 24, color: Color(0xFF4D2411)),
                                const SizedBox(width: 8),
                                Text(
                                  isSi ? 'වතුර වීදුරුවක් (250ml)' : 'Log Standard Cup (250ml)',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4D2411),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Weekly Hydration Bar Chart in Glass Container
                    GlassCard(
                      borderRadius: 24,
                      blur: 18,
                      padding: const EdgeInsets.all(18),
                      margin: EdgeInsets.zero,
                      child: WeeklyHydrationChart(todayProgress: progress),
                    ),

                    const SizedBox(height: 20),

                    // RECENT LOGS Glass Card
                    GlassCard(
                      borderRadius: 24,
                      blur: 18,
                      padding: const EdgeInsets.all(20.0),
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSi ? 'මෑත සටහන්' : 'RECENT LOGS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (logs.isEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Text(
                                  isSi ? 'අද දින සටහන් කිසිවක් නැත.' : 'No logs recorded yet today.',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                                ),
                              ),
                            ),
                          ] else ...[
                            Column(
                              children: logs.reversed.take(5).map((log) {
                                final timeStr = _formatLogTime(log.timestamp);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(Icons.water_drop_rounded, size: 18, color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648)),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            timeStr,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: subtitleColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${log.amountMl} ml',
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Goal Setting Preferences Glass Button
                    Center(
                      child: GlassCard(
                        borderRadius: 16,
                        blur: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        margin: EdgeInsets.zero,
                        onTap: () {
                          _showGoalSettingsDialog(context, ref, goal);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_rounded, size: 18, color: textColor),
                            const SizedBox(width: 8),
                            Text(
                              'Adjust Daily Goal & Preferences',
                              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Spacing for floating navigation glass dock
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLogTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _showGoalSettingsDialog(BuildContext context, WidgetRef ref, HydrationGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hydration Goal Settings',
              style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0C4648)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Goal (ml):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF0C4648)),
                      onPressed: () {
                        final newMl = (goal.dailyTargetMl - 250).clamp(1000, 4000);
                        ref.read(hydrationProvider.notifier).updateGoal(goal.copyWith(dailyTargetMl: newMl));
                      },
                    ),
                    Text('${goal.dailyTargetMl} ml', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0C4648)),
                      onPressed: () {
                        final newMl = (goal.dailyTargetMl + 250).clamp(1000, 4000);
                        ref.read(hydrationProvider.notifier).updateGoal(goal.copyWith(dailyTargetMl: newMl));
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Save Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
