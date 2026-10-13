import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';

/// Global helper function to display the AquaSoothe "How It Works" guide sheet
void showHowItWorksModal(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => const HowItWorksSheet(),
  );
}

class HowItWorksSheet extends ConsumerStatefulWidget {
  const HowItWorksSheet({super.key});

  @override
  ConsumerState<HowItWorksSheet> createState() => _HowItWorksSheetState();
}

class _HowItWorksSheetState extends ConsumerState<HowItWorksSheet> {
  // Local language toggle override (defaults to app settings)
  bool? _localIsSinhala;

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final isSi = _localIsSinhala ?? settingsState.isSinhala;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTeal = const Color(0xFF0C4648);
    final accentTeal = const Color(0xFF00897B);
    final titleColor = isDark ? const Color(0xFFE3F5F3) : primaryTeal;
    final bodyColor = isDark ? const Color(0xFF9DC2C0) : const Color(0xFF5B787A);

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.90,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.45 : 0.18),
            blurRadius: 36,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF132A2F).withValues(alpha: 0.82),
                        const Color(0xFF0C1D21).withValues(alpha: 0.88),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.80),
                        const Color(0xFFEAF6F4).withValues(alpha: 0.74),
                      ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.90),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Ambient Frosted Glass Aura Glow Blobs behind content
                Positioned(
                  top: -50,
                  right: -40,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00897B).withValues(alpha: isDark ? 0.18 : 0.14),
                    ),
                  ),
                ),
                Positioned(
                  top: 240,
                  left: -60,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF80DEEA).withValues(alpha: isDark ? 0.14 : 0.22),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  right: -30,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF8AB80).withValues(alpha: isDark ? 0.12 : 0.15),
                    ),
                  ),
                ),

                // Main Content Column
                Column(
                  children: [
                    // Drag Indicator Bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 14, bottom: 8),
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Sheet Top Bar: App Identity & Language Switch & Close
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          // Frosted Glass Brand Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF00897B).withValues(alpha: 0.22)
                                  : Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF70D6CE).withValues(alpha: 0.35)
                                    : Colors.white.withValues(alpha: 0.85),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentTeal.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline_rounded, size: 15, color: accentTeal),
                                const SizedBox(width: 6),
                                Text(
                                  isSi ? 'යෙදුම් මඟපෙන්වීම' : 'App Guide',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: accentTeal,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // Frosted Sinhala / English Toggle Pill
                          ScaleButton(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _localIsSinhala = !isSi;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.18)
                                      : Colors.white.withValues(alpha: 0.85),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.translate_rounded, size: 14, color: titleColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    isSi ? 'English' : 'සිංහල',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: titleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Frosted Glass Close Button
                          ScaleButton(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.65),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.18)
                                      : Colors.white.withValues(alpha: 0.85),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(Icons.close_rounded, size: 18, color: titleColor),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, thickness: 0.8, color: Colors.transparent),

                    // Scrollable Walkthrough Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero Glass Introduction Header
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF1B494F).withValues(alpha: 0.75)
                                          : Colors.white.withValues(alpha: 0.85),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.20)
                                            : Colors.white.withValues(alpha: 0.95),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentTeal.withValues(alpha: 0.25),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.waves_rounded,
                                          size: 40,
                                          color: accentTeal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    isSi ? 'AquaSoothe භාවිතා කරන්නේ කෙසේද?' : 'How AquaSoothe Works',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: titleColor,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isSi
                                        ? 'සුවබර නින්ද, සුවදායී ජල සමීකරණය සහ දෛනික යහපැවැත්ම පහසුවෙන්ම ලබාගන්න.'
                                        : 'Your complete guide to peaceful sleep, mindful hydration, and daily calm.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: bodyColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Guide Step 1: Ambient Water Sounds
                            _buildGlassGuideCard(
                              isDark: isDark,
                              stepNumber: '1',
                              icon: Icons.water_drop_rounded,
                              iconColor: const Color(0xFF00ACC1),
                              badgeColor: const Color(0xFFE0F7FA),
                              badgeDarkColor: const Color(0xFF006064),
                              title: isSi ? 'සුවබර ජල ශබ්ද සහ සුව නින්ද' : 'Soothing Water Soundscapes',
                              subtitle: isSi
                                  ? 'විද්‍යාත්මකව තහවුරු කළ ජල ශබ්ද මඟින් ඔබේ මනස සන්සුන් කර නින්ද පහසු කරයි.'
                                  : 'Natural water acoustics induce delta/theta brainwaves to relieve stress & insomnia.',
                              tips: isSi
                                  ? [
                                      'ශබ්ද (Sounds) පිටුවට ගොස් වැසි, සාගර රළ, දිය ඇලි හෝ රෝස ඝෝෂාව තෝරන්න.',
                                      'නින්ද ගිය පසු ස්වයංක්‍රීයව ශබ්දය නැවතීමට Sleep Timer (විනාඩි 15 - 60) යොදන්න.',
                                      'වෙනත් යෙදුම් භාවිතා කරන විටත් පසුබිමෙන් (Background) ශබ්ද වාදනය වේ.',
                                    ]
                                  : [
                                      'Explore the "Sounds" tab for gentle rain, ocean waves, waterfalls, & pink noise.',
                                      'Set an Auto-Sleep Timer (15 to 60 mins) to smoothly fade audio as you fall asleep.',
                                      'Audio continues playing effortlessly in the background while your phone is locked.',
                                    ],
                            ),

                            const SizedBox(height: 16),

                            // Guide Step 2: Smart Hydration & Weather Sync
                            _buildGlassGuideCard(
                              isDark: isDark,
                              stepNumber: '2',
                              icon: Icons.local_drink_rounded,
                              iconColor: const Color(0xFF0288D1),
                              badgeColor: const Color(0xFFE1F5FE),
                              badgeDarkColor: const Color(0xFF01579B),
                              title: isSi ? 'ස්මාර්ට් ජල සමීකරණය & කාලගුණය' : 'Smart Hydration & Weather Sync',
                              subtitle: isSi
                                  ? 'ඔබේ ප්‍රදේශයේ උෂ්ණත්වය සහ ආර්ද්‍රතාවයට අනුව ජල අවශ්‍යතාවය ගණනය කෙරේ.'
                                  : 'Live temperature & humidity dynamically calibrate your daily water target.',
                              tips: isSi
                                  ? [
                                      'මුල් පිටුවේ ඇති +150ml, +250ml හෝ +500ml ඉක්මන් බොත්තම් මඟින් තත්පරයකින් සටහන් කරන්න.',
                                      'උණුසුම් දිනයන්හිදී ඔබට වැඩිපුර ජලය පානය කිරීමට බුද්ධිමත් සිහිකැඳවීම් ලැබේ.',
                                      'ජල ප්‍රගතිය 100% කරා ළඟාවන අයුරු සජීවීව නිරීක්ෂණය කරන්න.',
                                    ]
                                  : [
                                      'Log hydration in 1 second using +150ml, +250ml, or +500ml quick-add buttons.',
                                      'High temperatures or humidity automatically boost hydration recommendations.',
                                      'Watch the fluid reservoir fill as you stay on top of your daily goal.',
                                    ],
                            ),

                            const SizedBox(height: 16),

                            // Guide Step 3: Gentle Wakeup Alarm
                            _buildGlassGuideCard(
                              isDark: isDark,
                              stepNumber: '3',
                              icon: Icons.alarm_rounded,
                              iconColor: const Color(0xFFF57C00),
                              badgeColor: const Color(0xFFFFF3E0),
                              badgeDarkColor: const Color(0xFFE65100),
                              title: isSi ? 'මෘදු අවදිවීමේ සීනුව' : 'Gentle Wakeup Alarm',
                              subtitle: isSi
                                  ? 'කලබලකාරී ඝෝෂාකාරී ශබ්ද වෙනුවට මෘදු ජල නාද සමඟ නැවුම්ව අවදි වන්න.'
                                  : 'Gradually ascending ocean tones awaken you peacefully without morning shock.',
                              tips: isSi
                                  ? [
                                      'මුල් පිටුවේ ඇති "Gentle Alarm" බොත්තම ඔබා ඔබේ අවදිවන වේලාව සකසන්න.',
                                      'ශබ්දයේ තීව්‍රතාවය සෙමෙන් වැඩිවන බැවින් හෘද ස්පන්දනය වැඩිවීම වළක්වයි.',
                                      'උදෑසන විනාඩි 5ක අමතර විවේකයක් සඳහා Snooze පහසුකම භාවිතා කරන්න.',
                                    ]
                                  : [
                                      'Tap the Gentle Alarm pill on Home to configure your serene morning wakeup.',
                                      'Progressive volume prevents abrupt cortisol spikes and morning fatigue.',
                                      'Includes a smart gentle snooze for those extra few restful minutes.',
                                    ],
                            ),

                            const SizedBox(height: 16),

                            // Guide Step 4: Medication Reminders & Caregiver Link
                            _buildGlassGuideCard(
                              isDark: isDark,
                              stepNumber: '4',
                              icon: Icons.medication_rounded,
                              iconColor: const Color(0xFF8E24AA),
                              badgeColor: const Color(0xFFF3E5F5),
                              badgeDarkColor: const Color(0xFF4A148C),
                              title: isSi ? 'ඖෂධ සහ භාරකරු රැකවරණය' : 'Medication & Caregiver Safety',
                              subtitle: isSi
                                  ? 'නියමිත වේලාවට බෙහෙත් ගැනීම සහ ආදරණීයයන්ට දැනුම්දීමේ පහසුකම.'
                                  : 'Timely prescription adherence with optional family peace-of-mind alerts.',
                              tips: isSi
                                  ? [
                                      'උදෑසන, දහවල් හෝ රාත්‍රී බෙහෙත් වර්ග නියමිත මාත්‍රාව සමඟ ලියාපදිංචි කරන්න.',
                                      'බෙහෙත් ගත් පසු එක ටැප් එකකින් "ලබා ගත්තා" ලෙස සලකුණු කරන්න.',
                                      'භාරකරු (Caregiver) ගිණුම සම්බන්ධ කර ඔබගේ සුවදුක් සමීපතමයන්ට පහසුවෙන් හුවමාරු කරන්න.',
                                    ]
                                  : [
                                      'Register morning, afternoon, and night prescriptions with dosage instructions.',
                                      'Tap to mark doses as taken and keep an immutable health log.',
                                      'Link a family caregiver email to give loved ones total peace of mind.',
                                    ],
                            ),

                            const SizedBox(height: 16),

                            // Guide Step 5: Sinhala & English Voice Assistant
                            _buildGlassGuideCard(
                              isDark: isDark,
                              stepNumber: '5',
                              icon: Icons.mic_rounded,
                              iconColor: const Color(0xFF00897B),
                              badgeColor: const Color(0xFFE0F2F1),
                              badgeDarkColor: const Color(0xFF004D40),
                              title: isSi ? 'සිංහල & English හඬ සහායක' : 'Bilingual Voice Assistant',
                              subtitle: isSi
                                  ? 'ටයිප් කිරීමකින් තොරව ඔබේ කටහඬින් ජලය සටහන් කිරීම සහ ශබ්ද පාලනය.'
                                  : 'Hands-free voice recognition supporting both Sinhala and English commands.',
                              tips: isSi
                                  ? [
                                      'ඉහළ දකුණු කෙළවරේ ඇති "හඬ" (Voice) බොත්තම ඔබන්න.',
                                      'උදාහරණ: "වතුර 250ml බිව්වා" හෝ "වැසි නාදය දමන්න" ලෙස පවසන්න.',
                                      'විධානය හඳුනාගත් විගස ජලය සටහන් වීම හෝ ශබ්දය වාදනය වීම සිදුවේ.',
                                    ]
                                  : [
                                      'Tap the "Voice" button at the top-right header anytime.',
                                      'Speak naturally: e.g. "Log 250ml water" or "Play rain sound".',
                                      'Instantly registers actions without having to navigate through screens.',
                                    ],
                            ),

                            const SizedBox(height: 16),

                            // Guide Step 6: 4-7-8 Breathing Technique
                            _buildGlassGuideCard(
                              isDark: isDark,
                              stepNumber: '6',
                              icon: Icons.air_rounded,
                              iconColor: const Color(0xFF43A047),
                              badgeColor: const Color(0xFFE8F5E9),
                              badgeDarkColor: const Color(0xFF1B5E20),
                              title: isSi ? '4-7-8 සන්සුන් හුස්ම ගැනීමේ අභ්‍යාසය' : '4-7-8 Restorative Breathing',
                              subtitle: isSi
                                  ? 'ස්නායු පද්ධතිය සැහැල්ලු කර විනාඩි කිහිපයකින් ආතතිය දුරු කරන්න.'
                                  : 'Calms the sympathetic nervous system to slow heart rate before bedtime.',
                              tips: isSi
                                  ? [
                                      'මුල් පිටුවේ ඇති "සන්සුන් හුස්ම ගැනීමේ අභ්‍යාසය" කාඩ්පත ඔබන්න.',
                                      'තිරයේ ඇති වෘත්තය ප්‍රසාරණය වන විට හුස්ම ගන්න, රඳවා ගන්න සහ පිටකරන්න.',
                                      'නින්දට පෙර වට 3-4ක් සම්පූර්ණ කිරීමෙන් ඉක්මනින් නින්ද ළඟා වේ.',
                                    ]
                                  : [
                                      'Tap the Calm Breathing card on your Home dashboard.',
                                      'Follow the pulsing visual ring: Inhale (4s), Hold (7s), Exhale (8s).',
                                      'Just 3-4 cycles before bed significantly improves deep REM sleep.',
                                    ],
                            ),

                            const SizedBox(height: 28),

                            // Primary "Get Started / Done" Action Button
                            ScaleButton(
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0C4648), Color(0xFF1B706E), Color(0xFF00897B)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0C4648).withValues(alpha: 0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      isSi ? 'තේරුම් ගත්තා • භාවිතය අරඹන්න' : 'Got It • Start Exploring',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Authentic Glassmorphic Guide Card with translucent gradient, frosted blur, and crisp glass border highlights
  Widget _buildGlassGuideCard({
    required bool isDark,
    required String stepNumber,
    required IconData icon,
    required Color iconColor,
    required Color badgeColor,
    required Color badgeDarkColor,
    required String title,
    required String subtitle,
    required List<String> tips,
  }) {
    final primaryTeal = const Color(0xFF0C4648);
    final titleTextColor = isDark ? const Color(0xFFE3F5F3) : primaryTeal;
    final bodyTextColor = isDark ? const Color(0xFF9DC2C0) : const Color(0xFF5B787A);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF193B42).withValues(alpha: 0.65),
                      const Color(0xFF10262B).withValues(alpha: 0.50),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.78),
                      const Color(0xFFE2F4F1).withValues(alpha: 0.55),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.90),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.30 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon Badge with glass tint
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? badgeDarkColor.withValues(alpha: 0.70)
                          : badgeColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.80),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(icon, size: 24, color: isDark ? Colors.white : iconColor),
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
                            fontFamily: 'serif',
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: titleTextColor,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: bodyTextColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Frosted Inner Tips Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.75),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: tips.map((tip) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0, right: 8.0),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: iconColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: iconColor.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? const Color(0xFFC5E5E2) : const Color(0xFF325254),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
