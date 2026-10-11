import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_model.dart';
import '../providers/hydration_provider.dart';
import '../providers/medication_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import 'scale_button.dart';

/// Global helper to show the Medication & Hydration Schedule Modal Sheet
void showMedicationScheduleModal(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const MedicationScheduleSheet(),
  );
}

class MedicationScheduleSheet extends ConsumerWidget {
  const MedicationScheduleSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationProvider);
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTeal = const Color(0xFF0C4648);
    final accentTurquoise = const Color(0xFF28A096);
    final coral = const Color(0xFFFFAE85);
    final takenCount = medications.where((m) => m.isTakenToday).length;
    final totalCount = medications.length;

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
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF132A30).withValues(alpha: 0.92),
                          const Color(0xFF0A1B1F).withValues(alpha: 0.96),
                        ]
                      : [
                          const Color(0xFFE8F6F8).withValues(alpha: 0.90),
                          const Color(0xFFD6EEF2).withValues(alpha: 0.94),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.85),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.5 : 0.18),
                    blurRadius: 40,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Drag Handle & Title Header (Fixed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Header Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    coral.withValues(alpha: 0.45),
                                    const Color(0xFFF89966).withValues(alpha: 0.25),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                size: 24,
                                color: Color(0xFFF89966),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSi ? 'බෙහෙත් වේලාවන් සහ ජල සටහන' : 'Medication & Hydration',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : primaryTeal,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSi
                                        ? 'පෙති බී වතුර වීදුරුවක් ලබාගන්න'
                                        : 'Take daily pills with a fresh glass of water',
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
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, thickness: 1, color: Colors.white24),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Notification Status & Test Pill Banner (Liquid Glass)
                          _buildNotificationStatusBanner(context, isSi, isDark, primaryTeal),

                          const SizedBox(height: 14),

                          // 2. Today's Progress Card (Liquid Glass)
                          _buildProgressGlassCard(
                            isSi,
                            isDark,
                            primaryTeal,
                            takenCount,
                            totalCount,
                            accentTurquoise,
                          ),

                          const SizedBox(height: 20),

                          // 3. Medication Cards by Period
                          ...MedicationPeriod.values.map((period) {
                            final periodMeds =
                                medications.where((m) => m.period == period).toList();
                            if (periodMeds.isEmpty) return const SizedBox.shrink();

                            String periodHeader;
                            IconData periodIcon;
                            Color periodColor;

                            switch (period) {
                              case MedicationPeriod.morning:
                                periodHeader = isSi ? 'උදෑසන වේලාව' : 'Morning Routine';
                                periodIcon = Icons.wb_sunny_rounded;
                                periodColor = const Color(0xFFF89966);
                                break;
                              case MedicationPeriod.afternoon:
                                periodHeader = isSi ? 'දහවල් වේලාව' : 'Afternoon Routine';
                                periodIcon = Icons.wb_twilight_rounded;
                                periodColor = const Color(0xFFE5A93B);
                                break;
                              case MedicationPeriod.night:
                                periodHeader = isSi ? 'රාත්‍රී වේලාව' : 'Bedtime Routine';
                                periodIcon = Icons.nightlight_round;
                                periodColor = const Color(0xFF4AC4B8);
                                break;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Capsule Pill Header
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: periodColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: periodColor.withValues(alpha: 0.35),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(periodIcon, size: 14, color: periodColor),
                                        const SizedBox(width: 6),
                                        Text(
                                          periodHeader,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                            color: isDark ? Colors.white : primaryTeal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Period Medication Cards
                                ...periodMeds.map((med) => _buildMedicationGlassCard(
                                      context,
                                      ref,
                                      med,
                                      isSi,
                                      isDark,
                                      primaryTeal,
                                    )),
                              ],
                            );
                          }),

                          const SizedBox(height: 22),

                          // 4. Add Custom Medicine Button (Glass Outline)
                          ScaleButton(
                            onTap: () => _showAddMedicineDialog(context, ref, isSi),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.white.withValues(alpha: 0.08),
                                          Colors.white.withValues(alpha: 0.04),
                                        ]
                                      : [
                                          Colors.white.withValues(alpha: 0.70),
                                          const Color(0xFFE2F4F7).withValues(alpha: 0.50),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.8),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryTeal.withValues(alpha: isDark ? 0.2 : 0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline_rounded,
                                      size: 20, color: isDark ? Colors.white : primaryTeal),
                                  const SizedBox(width: 8),
                                  Text(
                                    isSi ? 'නව බෙහෙත් වේලාවක් එක් කරන්න' : 'Add Medication Schedule',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : primaryTeal,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Notification active status banner with instant test button
  Widget _buildNotificationStatusBanner(
    BuildContext context,
    bool isSi,
    bool isDark,
    Color primaryTeal,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1B4048).withValues(alpha: 0.75),
                  const Color(0xFF10272D).withValues(alpha: 0.65),
                ]
              : [
                  Colors.white.withValues(alpha: 0.85),
                  const Color(0xFFE4F6F8).withValues(alpha: 0.70),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28A096).withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF28A096).withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 18,
              color: Color(0xFF1C7D75),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSi
                      ? 'වේලාවට Notification පැමිණේ'
                      : 'Scheduled Notifications Active',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : primaryTeal,
                  ),
                ),
                Text(
                  isSi
                      ? 'App එක වැසුවද නියමිත වේලාවට එයි'
                      : 'Fires even when app is closed',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : const Color(0xFF5A7275),
                  ),
                ),
              ],
            ),
          ),
          ScaleButton(
            onTap: () async {
              HapticFeedback.lightImpact();
              await NotificationService().sendTestNotification(isSinhala: isSi);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isSi
                          ? '🔔 Notification එක යැව්වා! Phone එකේ උඩ Panel එක බලන්න.'
                          : '🔔 Test notification sent! Check your notification shade.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF0C4648),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF28A096).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF28A096).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send_rounded, size: 12, color: Color(0xFF1C7D75)),
                  const SizedBox(width: 4),
                  Text(
                    isSi ? 'පරීක්ෂා' : 'Test',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C7D75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Today's progress banner in authentic Liquid Glass styling
  Widget _buildProgressGlassCard(
    bool isSi,
    bool isDark,
    Color primaryTeal,
    int takenCount,
    int totalCount,
    Color accentTurquoise,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A3840).withValues(alpha: 0.70),
                  const Color(0xFF0F2429).withValues(alpha: 0.60),
                ]
              : [
                  Colors.white.withValues(alpha: 0.85),
                  const Color(0xFFE4F6F8).withValues(alpha: 0.65),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.90),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: totalCount > 0 ? (takenCount / totalCount).clamp(0.0, 1.0) : 0,
                  strokeWidth: 5,
                  backgroundColor: (isDark ? Colors.white12 : primaryTeal.withValues(alpha: 0.1)),
                  color: accentTurquoise,
                ),
              ),
              Text(
                '$takenCount/$totalCount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSi
                      ? (takenCount == totalCount && totalCount > 0
                          ? 'අද දින සියලු බෙහෙත් සම්පූර්ණයි! 🎉'
                          : 'අද දින: පෙති $takenCount/$totalCount ලබාගෙන ඇත')
                      : (takenCount == totalCount && totalCount > 0
                          ? 'All pills completed for today! 🎉'
                          : 'Today: $takenCount of $totalCount pills taken'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : primaryTeal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isSi
                      ? 'සෑම පෙත්තක් සමගම 250ml වතුර පානය සටහන් වේ'
                      : '250ml of water is logged with every pill',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF5A7275),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Medication Card with Liquid Glass look
  Widget _buildMedicationGlassCard(
    BuildContext context,
    WidgetRef ref,
    MedicationItem med,
    bool isSi,
    bool isDark,
    Color primaryTeal,
  ) {
    final title = isSi ? med.nameSi : med.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1C3A42).withValues(alpha: 0.72),
                  const Color(0xFF10262B).withValues(alpha: 0.55),
                ]
              : [
                  Colors.white.withValues(alpha: 0.88),
                  const Color(0xFFEEF9FA).withValues(alpha: 0.70),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.28 : 0.90),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.5),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon, Name/Time, and Delete Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: med.isTakenToday
                        ? const Color(0xFF28A096).withValues(alpha: 0.2)
                        : (isDark ? Colors.white12 : primaryTeal.withValues(alpha: 0.08)),
                    border: Border.all(
                      color: med.isTakenToday
                          ? const Color(0xFF28A096).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    med.isTakenToday ? Icons.check_circle_rounded : Icons.medication_rounded,
                    size: 22,
                    color: med.isTakenToday
                        ? const Color(0xFF1E706B)
                        : (isDark ? Colors.white70 : primaryTeal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            med.dosage,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white60 : const Color(0xFF5A7275),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white12 : primaryTeal.withValues(alpha: 0.08)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 11,
                                  color: isDark ? Colors.white70 : primaryTeal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  med.time,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  onPressed: () {
                    ref.read(medicationProvider.notifier).deleteMedication(med.id, isSinhala: isSi);
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Bottom Action: Take Pill & Log Water
            if (med.isTakenToday)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF28A096).withValues(alpha: 0.18),
                      const Color(0xFF28A096).withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF28A096).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, color: Color(0xFF0C4648), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      isSi
                          ? 'අද දින සම්පූර්ණයි • 250ml වතුර ලොග් කළා ✓'
                          : 'Pill Taken • 250ml Water Logged ✓',
                      style: const TextStyle(
                        color: Color(0xFF0C4648),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              ScaleButton(
                onTap: () async {
                  final hydrationNotifier = ref.read(hydrationProvider.notifier);
                  final amount = await ref
                      .read(medicationProvider.notifier)
                      .takeMedication(med.id, hydrationNotifier);

                  if (amount != null && context.mounted) {
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isSi
                              ? '💊 $title ලබාගෙන වතුර ${amount}ml එකතු කළා!'
                              : '💊 $title taken & ${amount}ml water logged!',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFF0C4648),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFAE85), Color(0xFFF89966)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF8AB80).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.water_drop_rounded, size: 18, color: Color(0xFF4D2411)),
                      const SizedBox(width: 6),
                      Text(
                        isSi ? 'බී වතුර 250ml සටහන් කරන්න' : 'Take & Log 250ml Water',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4D2411),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context, WidgetRef ref, bool isSi) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController(text: isSi ? 'පෙති 1' : '1 Tablet');
    MedicationPeriod selectedPeriod = MedicationPeriod.morning;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(isSi ? 'නව බෙහෙත් වේලාවක් එක් කරන්න' : 'Add Medication Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: isSi ? 'බෙහෙතේ නම' : 'Medication Name',
                  hintText: isSi ? 'උදා: විටමින් පෙත්ත' : 'e.g. Heart Vitamin',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dosageController,
                decoration: InputDecoration(
                  labelText: isSi ? 'මාත්‍රාව' : 'Dosage',
                  hintText: isSi ? 'පෙති 1' : '1 Tablet',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MedicationPeriod>(
                initialValue: selectedPeriod,
                decoration: InputDecoration(labelText: isSi ? 'වේලාව' : 'Time Period'),
                items: [
                  DropdownMenuItem(
                    value: MedicationPeriod.morning,
                    child: Text(isSi ? 'උදෑසන' : 'Morning'),
                  ),
                  DropdownMenuItem(
                    value: MedicationPeriod.afternoon,
                    child: Text(isSi ? 'දහවල්' : 'Afternoon'),
                  ),
                  DropdownMenuItem(
                    value: MedicationPeriod.night,
                    child: Text(isSi ? 'රාත්‍රී' : 'Night'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedPeriod = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isSi ? 'අවලංගු කරන්න' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C4648),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final newMed = MedicationItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  nameSi: nameController.text.trim(),
                  dosage: dosageController.text.trim(),
                  time: selectedPeriod == MedicationPeriod.morning
                      ? '08:00 AM'
                      : selectedPeriod == MedicationPeriod.afternoon
                          ? '01:00 PM'
                          : '08:30 PM',
                  period: selectedPeriod,
                  waterMl: 250,
                );
                ref.read(medicationProvider.notifier).addMedication(newMed, isSinhala: isSi);
                Navigator.pop(ctx);
              },
              child: Text(isSi ? 'සුරකින්න' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
