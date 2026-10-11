import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';

/// Frosted Glass Modal Dialog for morning sleep quality check-in & rating.
class SleepRatingDialog extends ConsumerStatefulWidget {
  const SleepRatingDialog({super.key});

  @override
  ConsumerState<SleepRatingDialog> createState() => _SleepRatingDialogState();
}

class _SleepRatingDialogState extends ConsumerState<SleepRatingDialog> {
  int _selectedRating = 4;
  final Set<String> _selectedTags = {'Restful', 'Fresh Morning'};

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    final tags = [
      {'en': 'Restful', 'si': 'සුවබරයි'},
      {'en': 'Deep Sleep', 'si': 'ගැඹුරු නින්දක්'},
      {'en': 'Interrupted', 'si': 'කඩින් කඩ අවදිවීම්'},
      {'en': 'Fresh Morning', 'si': 'නැවුම් උදෑසනක්'},
      {'en': 'Calm Mind', 'si': 'සන්සුන් මනසක්'},
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF13272C).withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.4 : 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8AB80).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF8AB80).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(Icons.bedtime_rounded, color: Color(0xFFF8AB80), size: 32),
                ),

                const SizedBox(height: 16),

                Text(
                  isSi ? 'උදෑසන නින්දේ සුවතාවය' : 'Morning Sleep Journal',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isSi
                      ? 'ඊයේ රාත්‍රියේ නින්ද කෙතරම් සුවදායක වීද?'
                      : 'How restful was your sleep last night?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),

                const SizedBox(height: 18),

                // 1-5 Star Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return ScaleButton(
                      onTap: () {
                        setState(() => _selectedRating = starValue);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          starValue <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFF8AB80),
                          size: 38,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 18),

                // Tags Wrap Selection with frosted styling
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: tags.map((t) {
                    final enKey = t['en']!;
                    final label = isSi ? t['si']! : enKey;
                    final isSelected = _selectedTags.contains(enKey);

                    return ScaleButton(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTags.remove(enKey);
                          } else {
                            _selectedTags.add(enKey);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0C4648)
                              : (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0C4648)
                                : (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // Action Save Button
                ScaleButton(
                  onTap: () {
                    Navigator.of(context).pop(_selectedRating);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isSi
                              ? 'තරු $_selectedRating ක නින්දේ සුවතාවය සටහන් කළා!'
                              : 'Logged $_selectedRating-Star Sleep Rating!',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFF0C4648),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C4648), Color(0xFF165C5F)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4648).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isSi ? 'සටහන් කර සුරකින්න' : 'Save Journal Entry',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
}
