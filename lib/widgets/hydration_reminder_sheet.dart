import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hydration_provider.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';

void showHydrationReminderSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const HydrationReminderSheet(),
  );
}

class HydrationReminderSheet extends ConsumerStatefulWidget {
  const HydrationReminderSheet({super.key});

  @override
  ConsumerState<HydrationReminderSheet> createState() => _HydrationReminderSheetState();
}

class _HydrationReminderSheetState extends ConsumerState<HydrationReminderSheet> {
  late bool _isEnabled;
  late double _intervalHours;
  late int _wakeHour;
  late int _wakeMinute;
  late int _sleepHour;
  late int _sleepMinute;
  late int _targetMl;

  @override
  void initState() {
    super.initState();
    final goal = ref.read(hydrationProvider).goal;
    _isEnabled = goal.isReminderEnabled;
    _intervalHours = goal.intervalHours;
    _wakeHour = goal.wakeHour;
    _wakeMinute = goal.wakeMinute;
    _sleepHour = goal.sleepHour;
    _sleepMinute = goal.sleepMinute;
    _targetMl = goal.dailyTargetMl;
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
                      child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSi ? 'ජල මතක් කිරීම් සැකසුම' : 'Water Reminder Settings',
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
                                ? 'ඔබට පහසු පරිදි වතුර බීමට මතක් කිරීම් සකසන්න'
                                : 'Customize intervals and active hours for alerts',
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

                // Main Toggle Glass Card
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
                              Icons.notifications_active_rounded,
                              color: _isEnabled ? const Color(0xFF0284C7) : subtitleColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSi ? 'ජල මතක් කිරීම් (Reminders)' : 'Hydration Alerts',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isEnabled
                                    ? (isSi ? 'මතක් කිරීම් සක්‍රියයි' : 'Reminders active')
                                    : (isSi ? 'මතක් කිරීම් අක්‍රියයි' : 'Turn on to receive reminders'),
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

                // Reminder Frequency Chips
                Text(
                  isSi ? 'මතක් කිරීම් වාර ගණන (FREQUENCY)' : 'REMINDER FREQUENCY',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _buildIntervalChip(
                      value: 1.0,
                      label: isSi ? 'පැය 1' : 'Every 1h',
                      subtitle: isSi ? 'ඉක්මන්' : 'Quick',
                    ),
                    const SizedBox(width: 8),
                    _buildIntervalChip(
                      value: 1.5,
                      label: isSi ? 'පැය 1.5' : 'Every 1.5h',
                      subtitle: isSi ? 'මධ්‍යස්ථ' : 'Moderate',
                    ),
                    const SizedBox(width: 8),
                    _buildIntervalChip(
                      value: 2.0,
                      label: isSi ? 'පැය 2' : 'Every 2h',
                      subtitle: isSi ? 'නිර්දේශිත' : 'Best',
                    ),
                    const SizedBox(width: 8),
                    _buildIntervalChip(
                      value: 3.0,
                      label: isSi ? 'පැය 3' : 'Every 3h',
                      subtitle: isSi ? 'සෙමෙන්' : 'Relaxed',
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Active Hours Window (Wake / Sleep)
                Text(
                  isSi ? 'මතක් කිරීම් ක්‍රියාත්මක කාල පරාසය' : 'ACTIVE WAKING HOURS',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // Start Time (Wake)
                    Expanded(
                      child: ScaleButton(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: _wakeHour, minute: _wakeMinute),
                          );
                          if (picked != null) {
                            setState(() {
                              _wakeHour = picked.hour;
                              _wakeMinute = picked.minute;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (isDark ? Colors.white12 : primaryTeal.withValues(alpha: 0.15)),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.wb_sunny_rounded, color: Color(0xFFF59E0B), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    isSi ? 'ආරම්භක වේලාව' : 'Wake-Up Time',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtitleColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(_wakeHour, _wakeMinute),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // End Time (Sleep)
                    Expanded(
                      child: ScaleButton(
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (isDark ? Colors.white12 : primaryTeal.withValues(alpha: 0.15)),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.nightlight_round, color: Color(0xFF0284C7), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    isSi ? 'නින්දට යන වේලාව' : 'Bedtime',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtitleColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(_sleepHour, _sleepMinute),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Daily Goal Target
                Text(
                  isSi ? 'දෛනික ජල ඉලක්කය (DAILY TARGET)' : 'DAILY HYDRATION GOAL',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [1500, 2000, 2500, 3000].map((ml) {
                    final isSel = _targetMl == ml;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ScaleButton(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _targetMl = ml);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
                            child: Center(
                              child: Text(
                                '$ml ml',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                  color: isSel ? Colors.white : textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 26),

                // UNIFIED SIGNATURE GLASS BUTTON (Save Settings)
                ScaleButton(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final currentGoal = ref.read(hydrationProvider).goal;
                    final newGoal = currentGoal.copyWith(
                      isReminderEnabled: _isEnabled,
                      intervalHours: _intervalHours,
                      wakeHour: _wakeHour,
                      wakeMinute: _wakeMinute,
                      sleepHour: _sleepHour,
                      sleepMinute: _sleepMinute,
                      dailyTargetMl: _targetMl,
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
                                      ? '💧 ජල මතක් කිරීම් සැකසුම සුරැකිණි!'
                                      : '💧 Hydration reminder settings saved successfully!',
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
                          isSi ? 'සැකසුම් සුරකින්න (Save)' : 'Save Reminder Settings',
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

  Widget _buildIntervalChip({
    required double value,
    required String label,
    required String subtitle,
  }) {
    final isSel = (_intervalHours - value).abs() < 0.1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8F6F4) : const Color(0xFF0C4648);

    return Expanded(
      child: ScaleButton(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _intervalHours = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSel
                ? const Color(0xFF0284C7)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC)),
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
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                  color: isSel ? Colors.white : textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSel ? Colors.white70 : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
