import 'dart:ui';
import 'package:flutter/material.dart';
import 'scale_button.dart';

/// Frosted Glass Modal Dialog for morning sleep quality check-in & rating.
class SleepRatingDialog extends StatefulWidget {
  const SleepRatingDialog({super.key});

  @override
  State<SleepRatingDialog> createState() => _SleepRatingDialogState();
}

class _SleepRatingDialogState extends State<SleepRatingDialog> {
  int _selectedRating = 4;
  final Set<String> _selectedTags = {'Restful', 'Fresh Morning'};

  final List<String> _availableTags = [
    'Restful',
    'Deep Sleep',
    'Interrupted',
    'Fresh Morning',
    'Calm Mind',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF13272C).withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 28,
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
                  'Morning Sleep Journal',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'How restful was your sleep last night?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: subtitleColor),
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
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return ScaleButton(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTags.remove(tag);
                          } else {
                            _selectedTags.add(tag);
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
                          tag,
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
                        content: Text('Logged $_selectedRating-Star Sleep Rating!', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        backgroundColor: const Color(0xFF0C4648),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
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
                    child: const Center(
                      child: Text(
                        'Save Journal Entry',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
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
