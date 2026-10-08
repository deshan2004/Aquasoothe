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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);
    final cardBg = isDark ? const Color(0xFF13272C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3A40) : const Color(0xFFD6EBE8);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              Text(
                'Caregiver Connection',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Allow a trusted family member or caregiver to monitor your hydration & sleep logs.',
                style: TextStyle(
                  fontSize: 15,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Master Toggle Switch Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13272C) : const Color(0xFFE8F6F4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Caregiver Sharing',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEnabled ? 'Active - Progress is being shared' : 'Disabled - Private mode',
                            style: TextStyle(
                              fontSize: 14,
                              color: isEnabled ? const Color(0xFF70D6CE) : subtitleColor,
                              fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isEnabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: isDark ? const Color(0xFF32545A) : const Color(0xFFCBE3DF),
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
                _buildInviteCodeCard(context, caregiverSettings, caregiverNotifier, isDark, textColor, subtitleColor, cardBg, cardBorder),

                const SizedBox(height: 24),

                // Live Caregiver Feed Preview Card
                Text(
                  'Caregiver Feed Preview',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCaregiverViewPreview(context, hydrationState, audioNotifier, caregiverSettings, isDark, textColor, subtitleColor, cardBg, cardBorder),
              ] else ...[
                _buildDisabledNotice(isDark, textColor, subtitleColor, cardBg, cardBorder),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteCodeCard(
    BuildContext context,
    caregiverSettings,
    caregiverNotifier,
    bool isDark,
    Color textColor,
    Color subtitleColor,
    Color cardBg,
    Color cardBorder,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
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
          Text(
            'YOUR UNIQUE PAIR CODE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Share this code with your trusted caregiver to pair their phone:',
            style: TextStyle(fontSize: 15, color: subtitleColor),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B191C) : const Color(0xFF0C4648),
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
    bool isDark,
    Color textColor,
    Color subtitleColor,
    Color cardBg,
    Color cardBorder,
  ) {
    final goal = hydrationState.goal;
    final totalMl = hydrationState.todayTotalMl;
    final isMet = totalMl >= goal.dailyTargetMl;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_rounded, size: 22, color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648)),
              const SizedBox(width: 8),
              Text(
                'Caregiver: ${caregiverSettings.caregiverName}',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          Divider(height: 24, color: cardBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Intake', style: TextStyle(fontSize: 15, color: subtitleColor)),
              Text(
                '$totalMl / ${goal.dailyTargetMl} ml',
                style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status Alert', style: TextStyle(fontSize: 15, color: subtitleColor)),
              Text(
                isMet ? 'Goal Completed' : 'On Track',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isMet ? (isDark ? const Color(0xFF70D6CE) : const Color(0xFF15803D)) : textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Last Synced', style: TextStyle(fontSize: 15, color: subtitleColor)),
              Text(
                DateFormat('h:mm a').format(DateTime.now()),
                style: TextStyle(fontSize: 15, color: subtitleColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledNotice(
    bool isDark,
    Color textColor,
    Color subtitleColor,
    Color cardBg,
    Color cardBorder,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, size: 54, color: subtitleColor),
          const SizedBox(height: 14),
          Text(
            'Your Privacy is Protected',
            style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Caregiver sharing is completely optional. Turn on the switch above anytime to share your progress.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: subtitleColor, height: 1.4),
          ),
        ],
      ),
    );
  }
}
