import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/caregiver_provider.dart';
import '../providers/hydration_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/aquasoothe_header.dart';

class CaregiverScreen extends ConsumerWidget {
  const CaregiverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caregiverSettings = ref.watch(caregiverProvider);
    final caregiverNotifier = ref.read(caregiverProvider.notifier);
    final hydrationState = ref.watch(hydrationProvider);
    final audioNotifier = ref.watch(audioServiceProvider);

    final isEnabled = caregiverSettings.isEnabled;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              const AquaSootheHeader(isCentered: false),

              const SizedBox(height: 24),

              // Title & Subtitle
              const Text(
                'Caregiver Connection',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C4648),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Allow a trusted family member or caregiver to monitor your hydration & sleep logs.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF5B787A),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Master Toggle Switch Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6F4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enable Caregiver Sharing',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C4648),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEnabled ? 'Active - Progress is being shared' : 'Disabled - Private mode',
                            style: TextStyle(
                              fontSize: 14,
                              color: isEnabled ? const Color(0xFF15803D) : const Color(0xFF5B787A),
                              fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isEnabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF0C4648),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFCBE3DF),
                      onChanged: (val) async {
                        await caregiverNotifier.toggleEnabled(val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (isEnabled) ...[
                // Pair Code Box Card
                _buildInviteCodeCard(context, caregiverSettings, caregiverNotifier),

                const SizedBox(height: 24),

                // Live Caregiver Feed Preview Card
                const Text(
                  'Caregiver Feed Preview',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C4648),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCaregiverViewPreview(context, hydrationState, audioNotifier, caregiverSettings),
              ] else ...[
                _buildDisabledNotice(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteCodeCard(BuildContext context, caregiverSettings, caregiverNotifier) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4648).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR UNIQUE PAIR CODE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Color(0xFF5B787A),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Share this code with your trusted caregiver to pair their phone:',
            style: TextStyle(fontSize: 15, color: Color(0xFF5B787A)),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0C4648),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  caregiverSettings.inviteCode,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3.0,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8AB80),
                    foregroundColor: const Color(0xFF4D2411),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: caregiverSettings.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pair code copied to clipboard!', style: TextStyle(fontSize: 16)),
                        backgroundColor: Color(0xFF0C4648),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF4D2411)),
                  label: const Text('Copy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4D2411))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverViewPreview(
    BuildContext context,
    hydrationState,
    audioNotifier,
    caregiverSettings,
  ) {
    final goal = hydrationState.goal;
    final totalMl = hydrationState.todayTotalMl;
    final isMet = totalMl >= goal.dailyTargetMl;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6EBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility_rounded, size: 22, color: Color(0xFF0C4648)),
              const SizedBox(width: 8),
              Text(
                'Caregiver: ${caregiverSettings.caregiverName}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0C4648)),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFD6EBE8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today\'s Intake', style: TextStyle(fontSize: 15, color: Color(0xFF5B787A))),
              Text(
                '$totalMl / ${goal.dailyTargetMl} ml',
                style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C4648)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status Alert', style: TextStyle(fontSize: 15, color: Color(0xFF5B787A))),
              Text(
                isMet ? 'Goal Completed' : 'On Track',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isMet ? const Color(0xFF15803D) : const Color(0xFF0C4648),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Last Synced', style: TextStyle(fontSize: 15, color: Color(0xFF5B787A))),
              Text(
                DateFormat('h:mm a').format(DateTime.now()),
                style: const TextStyle(fontSize: 15, color: Color(0xFF5B787A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledNotice() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6EBE8)),
      ),
      child: const Column(
        children: [
          Icon(Icons.shield_outlined, size: 54, color: Color(0xFF5B787A)),
          SizedBox(height: 14),
          Text(
            'Your Privacy is Protected',
            style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0C4648)),
          ),
          SizedBox(height: 8),
          Text(
            'Caregiver sharing is completely optional. Turn on the switch above anytime to share your progress.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Color(0xFF5B787A), height: 1.4),
          ),
        ],
      ),
    );
  }
}
