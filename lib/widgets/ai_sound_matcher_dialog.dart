import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_sound_recommender.dart';
import '../providers/audio_provider.dart';

class AISoundMatcherDialog extends ConsumerStatefulWidget {
  const AISoundMatcherDialog({super.key});

  @override
  ConsumerState<AISoundMatcherDialog> createState() => _AISoundMatcherDialogState();
}

class _AISoundMatcherDialogState extends ConsumerState<AISoundMatcherDialog> {
  UserMoodState _selectedMood = UserMoodState.stressed;
  AISoundRecommendation? _recommendation;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _analyzeAndRecommend();
  }

  void _analyzeAndRecommend() {
    setState(() => _isAnalyzing = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _recommendation = AISoundRecommender.recommendSound(mood: _selectedMood);
          _isAnalyzing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioNotifier = ref.read(audioServiceProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006687),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Soundscape Matcher',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                      ),
                      Text(
                        'Personalized sleep sound matching engine',
                        style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'How are you feeling right now?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
            ),
            const SizedBox(height: 12),

            // Mood Selector Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UserMoodState.values.map((mood) {
                final isSelected = _selectedMood == mood;
                return ChoiceChip(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  label: Text('${mood.emoji} ${mood.label}', style: const TextStyle(fontSize: 16)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF006687),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedMood = mood);
                      _analyzeAndRecommend();
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // AI Recommendation Output Card
            if (_isAnalyzing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: Color(0xFF006687)),
                ),
              )
            else if (_recommendation != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF0284C7), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology_rounded, color: Color(0xFF006687), size: 28),
                            SizedBox(width: 8),
                            Text(
                              'AI Match Result',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006687)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_recommendation!.matchPercentage}% Match',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Primary: ${_recommendation!.primaryTrack.title}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                    ),

                    if (_recommendation!.secondaryTrack != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Layered Secondary: ${_recommendation!.secondaryTrack!.title}',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
                      ),
                    ],

                    const SizedBox(height: 8),

                    Text(
                      'Timer Recommendation: ${_recommendation!.recommendedTimer.label}',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF475569)),
                    ),

                    const Divider(height: 20),

                    Text(
                      _recommendation!.aiReasoning,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF334155), height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Play Recommendation Button
              ElevatedButton.icon(
                onPressed: () async {
                  final rec = _recommendation!;
                  await audioNotifier.selectTrack(rec.primaryTrack);
                  if (rec.secondaryTrack != null) {
                    audioNotifier.toggleMixer(true);
                    await audioNotifier.selectSecondaryTrack(rec.secondaryTrack);
                  } else {
                    audioNotifier.toggleMixer(false);
                  }
                  audioNotifier.setTimerPreset(rec.recommendedTimer);
                  await audioNotifier.play();

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Playing AI recommended soundscape: ${rec.primaryTrack.title}', style: const TextStyle(fontSize: 18)),
                        backgroundColor: const Color(0xFF006687),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.play_circle_fill_rounded, size: 32),
                label: const Text('Play Recommended Soundscape'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
