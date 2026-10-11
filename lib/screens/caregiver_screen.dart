import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/caregiver_provider.dart';
import '../providers/hydration_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/scale_button.dart';
import '../widgets/glass_card.dart';

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Aura Blobs
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF0C4648) : const Color(0xFFBDE4E1)).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF163C42) : const Color(0xFFD5ECE7)).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8AB80).withValues(alpha: isDark ? 0.12 : 0.18),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                  const SizedBox(height: 4),
                  Text(
                    'Allow a trusted family member or caregiver to monitor your hydration & sleep logs.',
                    style: TextStyle(
                      fontSize: 15,
                      color: subtitleColor,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Master Toggle Switch Glass Card
                  GlassCard(
                    borderRadius: 22,
                    blur: 16,
                    padding: const EdgeInsets.all(20.0),
                    margin: EdgeInsets.zero,
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
                                  color: isEnabled ? const Color(0xFF16A34A) : subtitleColor,
                                  fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: isEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF70D6CE),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: isDark ? const Color(0xFF32545A) : const Color(0xFFCBE3DF),
                          onChanged: (val) async {
                            await caregiverNotifier.toggleEnabled(val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isEnabled) ...[
                    // Pair Code Box Glass Card
                    _buildInviteCodeCard(context, caregiverSettings, caregiverNotifier, textColor, subtitleColor, isDark),

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
                    _buildCaregiverViewPreview(context, hydrationState, audioNotifier, caregiverSettings, textColor, subtitleColor, isDark),
                  ] else ...[
                    _buildDisabledNotice(textColor, subtitleColor, isDark),
                  ],

                  // Space for floating bottom glass dock
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCodeCard(
    BuildContext context,
    caregiverSettings,
    caregiverNotifier,
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    return GlassCard(
      borderRadius: 22,
      blur: 16,
      padding: const EdgeInsets.all(22),
      margin: EdgeInsets.zero,
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
          const SizedBox(height: 8),
          Text(
            'Share this code with your trusted caregiver to pair their device:',
            style: TextStyle(fontSize: 14, color: subtitleColor),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF0C4648) : const Color(0xFF0C4648)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  caregiverSettings.inviteCode,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3.0,
                  ),
                ),
                ScaleButton(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: caregiverSettings.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pair code copied to clipboard!', style: TextStyle(fontSize: 16)),
                        backgroundColor: Color(0xFF0C4648),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8AB80),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 16, color: Color(0xFF4D2411)),
                        SizedBox(width: 6),
                        Text('Copy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4D2411))),
                      ],
                    ),
                  ),
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
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    final goal = hydrationState.goal;
    final totalMl = hydrationState.todayTotalMl;
    final isMet = totalMl >= goal.dailyTargetMl;

    return GlassCard(
      borderRadius: 22,
      blur: 16,
      padding: const EdgeInsets.all(22),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_rounded, size: 22, color: textColor),
              const SizedBox(width: 8),
              Text(
                'Caregiver: ${caregiverSettings.caregiverName}',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          Divider(height: 24, color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1)),
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
                  color: isMet ? const Color(0xFF16A34A) : textColor,
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

  Widget _buildDisabledNotice(Color textColor, Color subtitleColor, bool isDark) {
    return GlassCard(
      borderRadius: 22,
      blur: 16,
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Icon(Icons.shield_outlined, size: 50, color: subtitleColor),
          const SizedBox(height: 12),
          Text(
            'Your Privacy is Protected',
            style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Caregiver sharing is completely optional. Turn on the switch above anytime to share your progress.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.4),
          ),
        ],
      ),
    );
  }
}
