import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sleep_journal_model.dart';
import '../providers/sleep_journal_provider.dart';
import '../providers/hydration_provider.dart';
import 'glass_card.dart';

class SleepJournalCard extends ConsumerWidget {
  const SleepJournalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepState = ref.watch(sleepJournalProvider);
    final hydrationState = ref.watch(hydrationProvider);
    final todayLog = sleepState.todayLog;

    final yesterdayWater = hydrationState.todayTotalMl;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bedtime_rounded, size: 30, color: Color(0xFF0A2540)),
                  SizedBox(width: 12),
                  Text(
                    'Morning Sleep Rating',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                  ),
                ],
              ),
              if (todayLog != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Logged Today',
                    style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (todayLog == null) ...[
            const Text(
              'How did you sleep last night?',
              style: TextStyle(fontSize: 17, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),

            Row(
              children: SleepRating.values.map((rating) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF006687), width: 1.5),
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                      ),
                      onPressed: () {
                        ref.read(sleepJournalProvider.notifier).logSleep(
                              rating: rating,
                              previousDayWaterMl: yesterdayWater,
                            );
                      },
                      child: Column(
                        children: [
                          Text(rating.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 4),
                          Text(
                            rating.label,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0284C7)),
              ),
              child: Row(
                children: [
                  Text(todayLog.rating.emoji, style: const TextStyle(fontSize: 38)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Slept ${todayLog.rating.label} last night',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayLog.rating.description,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
