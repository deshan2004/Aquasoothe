import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';
import 'voice_assistant_sheet.dart';
import 'how_it_works_sheet.dart';

/// Reusable AquaSoothe logo, accented brand typography, and header actions (Guide & Voice).
class AquaSootheHeader extends ConsumerWidget {
  final bool isCentered;
  final double iconSize;
  final double fontSize;
  final bool showImageLogo;
  final bool showVoiceButton;
  final bool showGuideButton;
  final VoidCallback? onLogoTap;
  final Widget? trailing;

  const AquaSootheHeader({
    super.key,
    this.isCentered = false,
    this.iconSize = 34,
    this.fontSize = 26,
    this.showImageLogo = true,
    this.showVoiceButton = true,
    this.showGuideButton = true,
    this.onLogoTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? Colors.white : const Color(0xFF0C4648);
    final accentTeal = isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B);

    final brandRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showImageLogo)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? accentTeal : const Color(0xFF0C4648)).withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                width: iconSize,
                height: iconSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.waves_rounded,
                  size: iconSize,
                  color: primaryColor,
                ),
              ),
            ),
          )
        else
          Icon(
            Icons.waves_rounded,
            size: iconSize,
            color: primaryColor,
          ),
        const SizedBox(width: 9),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Aqua',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                  letterSpacing: -0.4,
                ),
              ),
              TextSpan(
                text: 'Soothe',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: accentTeal,
                  letterSpacing: -0.4,
                  shadows: [
                    Shadow(
                      color: accentTeal.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Interactive clickable brand logo and title
    final logoWidget = ScaleButton(
      onTap: onLogoTap ?? () => showHowItWorksModal(context),
      child: Tooltip(
        message: isSi ? 'AquaSoothe භාවිත කරන ආකාරය' : 'How AquaSoothe works',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: brandRow,
        ),
      ),
    );

    if (isCentered) {
      return Center(child: logoWidget);
    }

    // Header actions on the right (Guide & Voice buttons)
    Widget? headerActions = trailing;
    if (headerActions == null) {
      final List<Widget> actionItems = [];

      if (showGuideButton) {
        actionItems.add(const HowItWorksHeaderButton());
      }

      if (showVoiceButton) {
        if (actionItems.isNotEmpty) {
          actionItems.add(const SizedBox(width: 8));
        }
        actionItems.add(const VoiceAssistantHeaderButton());
      }

      if (actionItems.isNotEmpty) {
        headerActions = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: actionItems,
        );
      }
    }

    if (headerActions != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logoWidget,
          headerActions,
        ],
      );
    }

    return logoWidget;
  }
}

/// Frosted glass "How It Works" / Guide icon button positioned beside the Voice Assistant
class HowItWorksHeaderButton extends ConsumerWidget {
  const HowItWorksHeaderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTeal = const Color(0xFF0C4648);
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;

    return ScaleButton(
      onTap: () => showHowItWorksModal(context),
      child: Tooltip(
        message: isSi ? 'භාවිතය සහ මඟපෙන්වීම (How it works)' : 'How it works (App Guide)',
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryTeal.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.help_outline_rounded,
              size: 19,
              color: isDark ? Colors.white : primaryTeal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact frosted glass Voice Assistant button for the app header
class VoiceAssistantHeaderButton extends ConsumerWidget {
  const VoiceAssistantHeaderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTeal = const Color(0xFF0C4648);
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;

    return ScaleButton(
      onTap: () => showVoiceAssistantModal(context),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryTeal.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.mic_rounded, size: 18, color: isDark ? Colors.white : primaryTeal),
            const SizedBox(width: 5),
            Text(
              isSi ? 'හඬ' : 'Voice',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : primaryTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
