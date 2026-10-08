import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hydration_model.dart';
import '../providers/hydration_provider.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/scale_button.dart';
import '../widgets/water_wave_progress.dart';
import '../widgets/weekly_hydration_chart.dart';

class HydrationScreen extends ConsumerWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydrationState = ref.watch(hydrationProvider);
    final goal = hydrationState.goal;
    final todayTotalMl = hydrationState.todayTotalMl;
    final progress = hydrationState.todayProgress.clamp(0.0, 1.0);
    final unit = goal.preferredUnit;

    final displayTotal = unit == 'ml'
        ? '${todayTotalMl.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ml'
        : '${(todayTotalMl / 250).toStringAsFixed(1)} cups';
    final displayGoal = unit == 'ml'
        ? '${goal.dailyTargetMl.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ml goal'
        : '${goal.dailyTargetCups} cups goal';

    final logs = hydrationState.todayLogs;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
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
                  'Daily Hydration',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stay mindful. Replenish your body.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    color: subtitleColor,
                  ),
                ),

                const SizedBox(height: 28),

                // Animated Fluid Wave Progress Card
                WaterWaveProgress(
                  progress: progress,
                  height: 230,
                  baseColor: isDark ? const Color(0xFF13272C) : const Color(0xFFD5ECE7),
                  waveColor: isDark ? const Color(0xFF22525A) : const Color(0xFF5F8B88),
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
                        'of $displayGoal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: progress > 0.55 ? const Color(0xFFE2F3F0) : subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Preset Quick Log Chips (150ml, 250ml, 500ml)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [150, 250, 500].map((amount) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ScaleButton(
                          onTap: () {
                            ref.read(hydrationProvider.notifier).logWater(amount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logged ${amount}ml of water!', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                backgroundColor: const Color(0xFF0C4648),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF13272C) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? const Color(0xFF1E3A40) : const Color(0xFFD6EBE8)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.2 : 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.local_drink_rounded, color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648), size: 20),
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
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // + Log Water Primary Action Button
                ScaleButton(
                  onTap: () {
                    ref.read(hydrationProvider.notifier).logWater(250);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged 250ml of water!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          'Log Standard Cup (250ml)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4D2411),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Weekly Hydration Bar Chart Visualization
                WeeklyHydrationChart(todayProgress: progress),

                const SizedBox(height: 28),

                // RECENT LOGS Card Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF13272C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECENT LOGS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (logs.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              'No logs recorded yet today.',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                            ),
                          ),
                        ),
                      ] else ...[
                        Column(
                          children: logs.reversed.take(5).map((log) {
                            final timeStr = _formatLogTime(log.timestamp);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF0B191C) : const Color(0xFFEFF8F6),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.water_drop_rounded, size: 18, color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648)),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 16,
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
                                      fontSize: 20,
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

                const SizedBox(height: 24),

                // Goal Setting & Custom Amount Options Accordion/Button
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _showGoalSettingsDialog(context, ref, goal);
                    },
                    icon: Icon(Icons.settings_outlined, size: 18, color: textColor),
                    label: Text(
                      'Adjust Daily Goal & Preferences',
                      style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLogTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _showGoalSettingsDialog(BuildContext context, WidgetRef ref, HydrationGoal initialGoal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, refWatch, child) {
            final currentGoal = refWatch.watch(hydrationProvider).goal;
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
            final iconColor = isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648);
            final bg = isDark ? const Color(0xFF13272C) : Colors.white;

            return Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hydration Goal Settings',
                    style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily Goal (ml):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: iconColor),
                            onPressed: () {
                              final newMl = (currentGoal.dailyTargetMl - 250).clamp(1000, 4000);
                              ref.read(hydrationProvider.notifier).updateGoal(currentGoal.copyWith(dailyTargetMl: newMl));
                            },
                          ),
                          Text('${currentGoal.dailyTargetMl} ml', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, color: iconColor),
                            onPressed: () {
                              final newMl = (currentGoal.dailyTargetMl + 250).clamp(1000, 4000);
                              ref.read(hydrationProvider.notifier).updateGoal(currentGoal.copyWith(dailyTargetMl: newMl));
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
            );
          },
        );
      },
    );
  }
}
