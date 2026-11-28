import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hydration_provider.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';

void showBedtimeReminderSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const BedtimeReminderSheet(),
  );
}

class BedtimeReminderSheet extends ConsumerStatefulWidget {
  const BedtimeReminderSheet({super.key});

  @override
  ConsumerState<BedtimeReminderSheet> createState() => _BedtimeReminderSheetState();
}

class _BedtimeReminderSheetState extends ConsumerState<BedtimeReminderSheet> {
  late bool _isEnabled;
  late int _sleepHour;
  late int _sleepMinute;
  late int _advanceMins;

  @override
  void initState() {
    super.initState();
    final goal = ref.read(hydrationProvider).goal;
    _isEnabled = goal.isBedtimeReminderEnabled;
    _sleepHour = goal.sleepHour;
    _sleepMinute = goal.sleepMinute;
    _advanceMins = goal.windDownAdvanceMinutes;
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isSi = settings.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTeal = const Color(0xFF0C4648);
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
                // Top drag handle
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

                // Header
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
                            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.nightlight_round, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSi ? 'සුව නින්දේ මතක් කිරීම්' : 'Bedtime Sleep Reminder',
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
                                ? 'නින්දට පෙර සන්සුන් වීමට වේලාව සකසන්න'
                                : 'Customize your sleep schedule & wind-down prompts',
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

                // Master Toggle Glass Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (_isEnabled ? const Color(0xFF0284C7).withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05))
                        : (_isEnabled ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isEnabled ? const Color(0xFF0284C7).withValues(alpha: 0.6) : (isDark ? Colors.white12 : Colors.black12),
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
                              color: _isEnabled ? const Color(0xFF0284C7).withValues(alpha: 0.2) : (isDark ? Colors.white10 : Colors.black12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.bedtime_rounded,
                              color: _isEnabled ? const Color(0xFF0284C7) : subtitleColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSi ? 'නින්දට පෙර මතක් කිරීම්' : 'Wind-Down Reminder',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isEnabled
                                    ? (isSi ? 'මතක් කිරීම සක්‍රියයි' : 'Bedtime reminder active')
                                    : (isSi ? 'මතක් කිරීම අක්‍රියයි' : 'Turn on to receive reminder'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isEnabled ? const Color(0xFF0284C7) : subtitleColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isEnabled,
                        activeTrackColor: const Color(0xFF0284C7),
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _isEnabled = val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Bedtime Hour Picker Card
                Text(
                  isSi ? 'ඔබ සාමාන්‍යයෙන් නිදාගන්නා වේලාව' : 'TARGET BEDTIME',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 10),

                ScaleButton(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: _sleepHour, minute: _sleepMinute),
                    );
                    if (picked != null) {
                      setState(() {
                        _sleepHour = picked.hour;
                        _sleepMinute = picked.minute;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                        width: 1.2,
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
                                color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.nightlight_round, color: Color(0xFF0284C7), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSi ? 'නිදාගන්නා ඉලක්ක වේලාව' : 'Bedtime Target',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: subtitleColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTime(_sleepHour, _sleepMinute),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit_calendar_rounded, size: 16, color: Color(0xFF0284C7)),
                              const SizedBox(width: 4),
                              Text(
                                isSi ? 'වෙනස් කරන්න' : 'Change',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Advance Alert options
                Text(
                  isSi ? 'නින්දට පෙර මතක් කළ යුතු කාලය' : 'WIND-DOWN ALERT IN ADVANCE',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [15, 30, 45, 60].map((mins) {
                    final isSel = _advanceMins == mins;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ScaleButton(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _advanceMins = mins);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFF0284C7)
                                  : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel ? const Color(0xFF0284C7) : (isDark ? Colors.white12 : Colors.black12),
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$mins m',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                    color: isSel ? Colors.white : textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSi ? 'පෙර' : 'before',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSel ? Colors.white70 : Colors.grey,
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

                const SizedBox(height: 18),

                // Informational Notice Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.12 : 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isSi
                              ? 'මතක් කිරීම ලද පසු tap කිරීමෙන් කෙලින්ම සුව නින්දේ ස්වභාවික නාද සහ ශ්වසන අභ්‍යාසය ආරම්භ වේ.'
                              : 'Tapping the notification directly starts your soothing sleep sound and 4-7-8 breathing ritual.',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // UNIFIED SIGNATURE GLASS BUTTON (Save)
                ScaleButton(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final currentGoal = ref.read(hydrationProvider).goal;
                    final newGoal = currentGoal.copyWith(
                      isBedtimeReminderEnabled: _isEnabled,
                      sleepHour: _sleepHour,
                      sleepMinute: _sleepMinute,
                      windDownAdvanceMinutes: _advanceMins,
                    );

                    await ref.read(hydrationProvider.notifier).updateGoal(newGoal, isSinhala: isSi);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF70D6CE)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isSi
                                      ? '🌙 සුව නින්දේ මතක් කිරීම් සැකසුම සුරැකිණි!'
                                      : '🌙 Bedtime reminder settings saved successfully!',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: primaryTeal,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C4648), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF70D6CE).withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4648).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isSi ? 'සැකසුම් සුරකින්න (Save)' : 'Save Bedtime Reminder',
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
