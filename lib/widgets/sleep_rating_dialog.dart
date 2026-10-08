import 'package:flutter/material.dart';

/// Modal dialog for morning sleep quality check-in & rating.
class SleepRatingDialog extends StatefulWidget {
  const SleepRatingDialog({super.key});

  @override
  State<SleepRatingDialog> createState() => _SleepRatingDialogState();
}

class _SleepRatingDialogState extends State<SleepRatingDialog> {
  int _selectedRating = 4;
  final Set<String> _selectedTags = {'Restful', 'Fresh Morning'};
  final TextEditingController _noteController = TextEditingController();

  final List<String> _availableTags = [
    'Restful',
    'Deep Sleep',
    'Interrupted',
    'Fresh Morning',
    'Calm Mind',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFEFF8F6),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFE1F2F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bedtime_rounded, color: Color(0xFF0C4648), size: 32),
            ),

            const SizedBox(height: 16),

            const Text(
              'Morning Sleep Journal',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C4648),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'How restful was your sleep last night?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFF5B787A)),
            ),

            const SizedBox(height: 20),

            // 1-5 Star Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  onPressed: () {
                    setState(() => _selectedRating = starValue);
                  },
                  icon: Icon(
                    starValue <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFF8AB80),
                    size: 38,
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Tags Wrap Selection
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return ChoiceChip(
                  label: Text(tag, style: const TextStyle(fontSize: 13)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0C4648),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF0C4648),
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Action Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C4648),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(_selectedRating);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logged $_selectedRating-Star Sleep Rating!', style: const TextStyle(fontSize: 16)),
                      backgroundColor: const Color(0xFF0C4648),
                    ),
                  );
                },
                child: const Text(
                  'Save Journal Entry',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
