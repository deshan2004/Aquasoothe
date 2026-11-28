import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_sound_recommender.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';

class AISoundMatcherDialog extends ConsumerStatefulWidget {
  const AISoundMatcherDialog({super.key});

  @override
  ConsumerState<AISoundMatcherDialog> createState() => _AISoundMatcherDialogState();
}

class _AISoundMatcherDialogState extends ConsumerState<AISoundMatcherDialog> {
  UserMoodState _selectedMood = UserMoodState.insomnia;
  AISoundRecommendation? _recommendation;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _analyzeAndRecommend();
  }

  void _analyzeAndRecommend() {
    setState(() => _isAnalyzing = true);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _recommendation = AISoundRecommender.recommendSound(mood: _selectedMood);
          _isAnalyzing = false;
        });
      }
    });
  }

  String _getMoodLabelSi(UserMoodState mood) {
    switch (mood) {
      case UserMoodState.stressed:
        return 'මානසික ආතතිය හෝ චකිතය';
      case UserMoodState.insomnia:
        return 'නින්ද නොයාම හෝ අපහසුව';
      case UserMoodState.lightSleeper:
        return 'බාහිර ශබ්ද නිසා නින්ද කැඩීම';
      case UserMoodState.windDown:
        return 'සන්සුන් විවේකය සහ කියවීම';
      case UserMoodState.exhausted:
        return 'ශාරීරික තෙහෙට්ටුව සහ වේදනාව';
    }
  }

  String _getMoodDescSi(UserMoodState mood) {
    switch (mood) {
      case UserMoodState.stressed:
        return 'හදවතේ ස්පන්දනය සන්සුන් කර සිත නිවාලයි';
      case UserMoodState.insomnia:
        return 'ඉක්මනින් ගැඹුරු සුව නින්දකට මඟ පාදයි';
      case UserMoodState.lightSleeper:
        return 'ගෙදර දොරේ හා වාහන ශබ්ද බාධා අවම කරයි';
      case UserMoodState.windDown:
        return 'රාත්‍රී කාලයේ මනසට සාමකාමී පරිසරයක් සදයි';
      case UserMoodState.exhausted:
        return 'මාංශ පේශිවල තෙහෙට්ටුව ලිහිල් කර සුවය සලසයි';
    }
  }

  String _getTrackTitleSi(String id) {
    switch (id) {
      case 'waterfall':
        return 'දිය ඇල්ලේ නාදය';
      case 'ocean':
        return 'සාගර රළ ශබ්දය';
      case 'rainfall':
        return 'සුවදායී වැසි නාදය';
      case 'pink_noise':
        return 'සන්සුන් Pink Noise තරංග';
      case 'brown_noise':
        return 'ගැඹුරු Brown Noise තරංග';
      case 'forest':
        return 'වනපෙතේ සුළං රැල්ල';
      case 'crickets':
        return 'රාත්‍රී රැහැයි නාදය';
      default:
        return 'ස්වභාවික නාදය';
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioNotifier = ref.read(audioServiceProvider);
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
                : Colors.white.withValues(alpha: 0.94),
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

                // Senior-Friendly Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF0C4648)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSi ? 'AI සුව නින්දේ නාද නිර්දේශකය' : 'AI Soundscape Matcher',
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
                                ? 'ඔබගේ සිතේ සුවතාවයට වඩාත්ම ගැළපෙන නාදය තෝරාගන්න'
                                : 'Personalized nature acoustics tailored for deep rest',
                            style: TextStyle(
                              fontSize: 13,
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

                // Question Prompt
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isSi
                              ? 'මේ මොහොතේ ඔබේ සිතට හෝ ගතට දැනෙන අවශ්‍යතාවය කුමක්ද?'
                              : 'How are you feeling right now?',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Senior-Friendly Mood Cards
                ...UserMoodState.values.map((mood) {
                  final isSelected = _selectedMood == mood;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ScaleButton(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedMood = mood);
                        _analyzeAndRecommend();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF0284C7).withValues(alpha: 0.25) : const Color(0xFFE0F2FE))
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0284C7)
                                : (isDark ? Colors.white12 : Colors.black12),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0284C7)
                                    : (isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.15)),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(mood.emoji, style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSi ? _getMoodLabelSi(mood) : mood.label,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? (isDark ? Colors.white : const Color(0xFF0369A1)) : textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSi ? _getMoodDescSi(mood) : mood.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? (isDark ? Colors.white70 : const Color(0xFF0C4648))
                                          : subtitleColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0284C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // AI Recommendation Output Glass Card
                if (_isAnalyzing)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(color: Color(0xFF0284C7), strokeWidth: 2.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isSi ? 'AI එක මඟින් වඩාත් ගැළපෙන නාදය තෝරමින් පවතී...' : 'Analyzing acoustic profiles...',
                            style: TextStyle(fontSize: 13, color: subtitleColor, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_recommendation != null) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF1E3A5F).withValues(alpha: 0.6),
                                const Color(0xFF0C2433).withValues(alpha: 0.8),
                              ]
                            : [
                                const Color(0xFFE0F2FE),
                                const Color(0xFFF0FDF4),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                          blurRadius: 16,
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
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded, color: Color(0xFF0284C7), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  isSi ? 'AI නිර්දේශිත ප්‍රතිඵලය' : 'AI Match Result',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                '${_recommendation!.matchPercentage}% ${isSi ? 'ගැළපීමක්' : 'Match'}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Primary Track Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_recommendation!.primaryTrack.icon, color: const Color(0xFF0284C7), size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSi ? 'ප්‍රධාන නාදය (Primary)' : 'Primary Sound',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtitleColor),
                                  ),
                                  Text(
                                    isSi
                                        ? _getTrackTitleSi(_recommendation!.primaryTrack.id)
                                        : _recommendation!.primaryTrack.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (_recommendation!.secondaryTrack != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_recommendation!.secondaryTrack!.icon, color: const Color(0xFFD97706), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSi ? 'පසුබිමින් මිශ්‍ර වන නාදය (Secondary)' : 'Layered Secondary',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtitleColor),
                                    ),
                                    Text(
                                      isSi
                                          ? _getTrackTitleSi(_recommendation!.secondaryTrack!.id)
                                          : _recommendation!.secondaryTrack!.title,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF0284C7)),
                            const SizedBox(width: 6),
                            Text(
                              isSi
                                  ? 'නිර්දේශිත ටයිමරය: ${_recommendation!.recommendedTimer.minutes == 0 ? "මුළු රාත්‍රිය පුරාම" : "${_recommendation!.recommendedTimer.minutes} මිනිත්තු"}'
                                  : 'Timer Recommendation: ${_recommendation!.recommendedTimer.label}',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: subtitleColor),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1),
                        ),

                        Text(
                          _recommendation!.aiReasoning,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withValues(alpha: 0.85),
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Big Senior-Friendly Play Button
                  ScaleButton(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
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
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF70D6CE)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isSi
                                        ? '🎶 AI නිර්දේශිත ${rec.primaryTrack.title} නාදය වාදනය වේ'
                                        : '🎶 Playing AI recommended soundscape: ${rec.primaryTrack.title}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            isSi ? 'නිර්දේශිත නාදය අසන්න (Play)' : 'Play Recommended Soundscape',
                            style: const TextStyle(
                              fontSize: 15.5,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
