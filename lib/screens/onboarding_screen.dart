import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hydration_model.dart';
import '../providers/hydration_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/scale_button.dart';
import '../widgets/glass_card.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  int _selectedTargetMl = 2000;
  final String _preferredUnit = 'ml';
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 0);
  final double _intervalHours = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Aura Blobs
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF0C4648) : const Color(0xFFBDE4E1)).withValues(alpha: 0.38),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF163C42) : const Color(0xFFD5ECE7)).withValues(alpha: 0.32),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -30,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8AB80).withValues(alpha: isDark ? 0.15 : 0.22),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: AquaSootheHeader(isCentered: false),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildStep1Welcome(isDark),
                      _buildStep2HydrationGoal(isDark),
                      _buildStep3Schedule(isDark),
                    ],
                  ),
                ),
                _buildBottomControls(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Welcome(bool isDark) {
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Welcome to AquaSoothe',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your quiet space for deep restorative sleep & mindful daytime hydration.',
            style: TextStyle(
              fontSize: 15,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            borderRadius: 24,
            blur: 18,
            padding: const EdgeInsets.all(22),
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _buildFeatureRow(
                  Icons.waves_rounded,
                  'Sleep Soundscapes',
                  'Soothing ambient water and noise tracks with 30s volume fade-out.',
                  textColor,
                  subtitleColor,
                  isDark,
                ),
                Divider(height: 28, color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1)),
                _buildFeatureRow(
                  Icons.water_drop_rounded,
                  'Hydration Tracking',
                  'Spaced daytime water goals tailored to keep you healthy and energized.',
                  textColor,
                  subtitleColor,
                  isDark,
                ),
                Divider(height: 28, color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1)),
                _buildFeatureRow(
                  Icons.people_outline_rounded,
                  'Caregiver Connection',
                  'Optional private sharing code to keep trusted family informed.',
                  textColor,
                  subtitleColor,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle, Color textColor, Color subtitleColor, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.12),
            ),
          ),
          child: Icon(icon, size: 26, color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: subtitleColor, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2HydrationGoal(bool isDark) {
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Hydration Goal',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set your target daily water intake. Medical guidelines recommend around 2,000 ml.',
            style: TextStyle(fontSize: 15, color: subtitleColor, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Big Goal Display Box in GlassCard
          GlassCard(
            borderRadius: 24,
            blur: 18,
            padding: const EdgeInsets.all(24),
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Text(
                  '$_selectedTargetMl ml',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Equivalent to ~${(_selectedTargetMl / 250).toStringAsFixed(1)} standard cups',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Incremental Goal Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleButton(
                onTap: () {
                  setState(() {
                    _selectedTargetMl = (_selectedTargetMl - 250).clamp(1000, 4000);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.remove_rounded, size: 20, color: textColor),
                      const SizedBox(width: 6),
                      Text('- 250 ml', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ScaleButton(
                onTap: () {
                  setState(() {
                    _selectedTargetMl = (_selectedTargetMl + 250).clamp(1000, 4000);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C4648),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C4648).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 6),
                      Text('+ 250 ml', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Schedule(bool isDark) {
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daytime Schedule',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'AquaSoothe schedules water reminders only during your waking hours.',
            style: TextStyle(fontSize: 15, color: subtitleColor, height: 1.4),
          ),
          const SizedBox(height: 24),

          GlassCard(
            borderRadius: 24,
            blur: 18,
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFF8AB80), size: 28),
                  title: Text('Wake Up Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  trailing: Text(_wakeTime.format(context), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _wakeTime);
                    if (picked != null) setState(() => _wakeTime = picked);
                  },
                ),
                Divider(height: 16, color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.nightlight_round, color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648), size: 28),
                  title: Text('Bedtime', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  trailing: Text(_sleepTime.format(context), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _sleepTime);
                    if (picked != null) setState(() => _sleepTime = picked);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(bool isDark) {
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF13272C) : Colors.white).withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: ScaleButton(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Back',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ScaleButton(
                  onTap: () async {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      await _completeOnboarding();
                    }
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C4648), Color(0xFF165C5F)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4648).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == 2 ? 'Get Started' : 'Next Step',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final newGoal = HydrationGoal(
      dailyTargetMl: _selectedTargetMl,
      preferredUnit: _preferredUnit,
      wakeHour: _wakeTime.hour,
      wakeMinute: _wakeTime.minute,
      sleepHour: _sleepTime.hour,
      sleepMinute: _sleepTime.minute,
      intervalHours: _intervalHours,
    );

    await ref.read(hydrationProvider.notifier).updateGoal(newGoal);
    await NotificationService().scheduleHydrationReminders(newGoal);
    await ref.read(settingsProvider.notifier).setOnboardingCompleted(true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }
}
