import 'package:flutter/material.dart';

class WeeklyHydrationChart extends StatelessWidget {
  final double todayProgress; // 0.0 to 1.0

  const WeeklyHydrationChart({
    super.key,
    required this.todayProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF13272C) : Colors.white;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);
    final emptyBarColor = isDark ? const Color(0xFF1E3A40) : const Color(0xFFE1F2F0);
    final activeBarColor = isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648);

    // Mock weekly historical completion rates (e.g. 85%, 100%, 75%, 90%, today)
    final days = [
      {'day': 'Mon', 'progress': 0.85, 'isToday': false},
      {'day': 'Tue', 'progress': 1.00, 'isToday': false},
      {'day': 'Wed', 'progress': 0.70, 'isToday': false},
      {'day': 'Thu', 'progress': 0.95, 'isToday': false},
      {'day': 'Fri', 'progress': 0.80, 'isToday': false},
      {'day': 'Sat', 'progress': 0.90, 'isToday': false},
      {'day': 'Sun', 'progress': todayProgress.clamp(0.05, 1.0), 'isToday': true},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBg,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-DAY HYDRATION HISTORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: subtitleColor,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.stars_rounded, size: 16, color: const Color(0xFFF8AB80)),
                  const SizedBox(width: 4),
                  Text(
                    '6 Days Goal Met',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bar Chart Row
          SizedBox(
            height: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final dayLabel = d['day'] as String;
                final prog = d['progress'] as double;
                final isToday = d['isToday'] as bool;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Percentage tooltip
                    Text(
                      '${(prog * 100).round()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isToday ? const Color(0xFFF8AB80) : subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Vertical Bar Container
                    Container(
                      width: 18,
                      height: 64,
                      decoration: BoxDecoration(
                        color: emptyBarColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          FractionallySizedBox(
                            widthFactor: 1.0,
                            heightFactor: prog,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday ? const Color(0xFFF8AB80) : activeBarColor,
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Day label
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? textColor : subtitleColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
