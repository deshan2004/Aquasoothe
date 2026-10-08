import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hydration_model.dart';
import '../providers/hydration_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../widgets/aquasoothe_header.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F6),
      body: SafeArea(
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
                  _buildStep1Welcome(),
                  _buildStep2HydrationGoal(),
                  _buildStep3Schedule(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Welcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Welcome to AquaSoothe',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4648),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your quiet space for deep restorative sleep & mindful daytime hydration.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5B787A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C4648).withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildFeatureRow(
                  Icons.waves_rounded,
                  'Sleep Soundscapes',
                  'Soothing ambient water and noise tracks with 30s volume fade-out.',
                ),
                const Divider(height: 32, color: Color(0xFFD6EBE8)),
                _buildFeatureRow(
                  Icons.water_drop_rounded,
                  'Hydration Tracking',
                  'Spaced daytime water goals tailored to keep you healthy and energized.',
                ),
                const Divider(height: 32, color: Color(0xFFD6EBE8)),
                _buildFeatureRow(
                  Icons.people_outline_rounded,
                  'Caregiver Connection',
                  'Optional private sharing code to keep trusted family informed.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F2F0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 28, color: const Color(0xFF0C4648)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C4648),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFF5B787A)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2HydrationGoal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Hydration Goal',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4648),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set your target daily water intake. Medical guidelines recommend around 2,000 ml.',
            style: TextStyle(fontSize: 16, color: Color(0xFF5B787A), height: 1.4),
          ),
          const SizedBox(height: 28),

          // Big Goal Display Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6F4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  '$_selectedTargetMl ml',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C4648),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Equivalent to ~${(_selectedTargetMl / 250).toStringAsFixed(1)} standard cups',
                  style: const TextStyle(fontSize: 15, color: Color(0xFF5B787A)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Incremental Goal Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0C4648),
                  side: const BorderSide(color: Color(0xFF0C4648)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onPressed: () {
                  setState(() {
                    _selectedTargetMl = (_selectedTargetMl - 250).clamp(1000, 4000);
                  });
                },
                icon: const Icon(Icons.remove_rounded, size: 22),
                label: const Text('- 250 ml', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C4648),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onPressed: () {
                  setState(() {
                    _selectedTargetMl = (_selectedTargetMl + 250).clamp(1000, 4000);
                  });
                },
                icon: const Icon(Icons.add_rounded, size: 22),
                label: const Text('+ 250 ml', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Schedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daytime Schedule',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4648),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AquaSoothe schedules water reminders only during your waking hours.',
            style: TextStyle(fontSize: 16, color: Color(0xFF5B787A), height: 1.4),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD6EBE8)),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFF8AB80), size: 30),
                  title: const Text('Wake Up Time', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0C4648))),
                  trailing: Text(_wakeTime.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C4648))),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _wakeTime);
                    if (picked != null) setState(() => _wakeTime = picked);
                  },
                ),
                const Divider(height: 20, color: Color(0xFFD6EBE8)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.nightlight_round, color: Color(0xFF0C4648), size: 30),
                  title: const Text('Bedtime', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0C4648))),
                  trailing: Text(_sleepTime.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C4648))),
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

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2EFEF))),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0C4648),
                  side: const BorderSide(color: Color(0xFF0C4648)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C4648),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                if (_currentPage < 2) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  await _completeOnboarding();
                }
              },
              child: Text(
                _currentPage == 2 ? 'Get Started' : 'Next Step',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
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
