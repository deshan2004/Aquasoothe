import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';
import 'voice_assistant_sheet.dart';

/// Reusable AquaSoothe logo and brand title widget.
class AquaSootheHeader extends StatelessWidget {
  final bool isCentered;
  final double iconSize;
  final double fontSize;
  final bool showImageLogo;
  final bool showVoiceButton;
  final Widget? trailing;

  const AquaSootheHeader({
    super.key,
    this.isCentered = false,
    this.iconSize = 34,
    this.fontSize = 26,
    this.showImageLogo = true,
    this.showVoiceButton = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : const Color(0xFF0C4648);

    final logoWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showImageLogo)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C4648).withValues(alpha: 0.08),
                  blurRadius: 6,
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
        const SizedBox(width: 10),
        Text(
          'AquaSoothe',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );

    if (isCentered) {
      return Center(child: logoWidget);
    }

    final voiceAction = trailing ?? (showVoiceButton ? const VoiceAssistantHeaderButton() : null);

    if (voiceAction != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logoWidget,
          voiceAction,
        ],
      );
    }

    return logoWidget;
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
