import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/localization/app_translations.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';

enum BreathingPattern {
  sleep478,
  box4444,
  gentle46,
}

enum BreathPhase {
  inhale,
  holdIn,
  exhale,
  holdOut,
}

/// Global helper to show the Breathing Exercise Modal Sheet
void showBreathingExerciseModal(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => const BreathingExerciseSheet(),
  );
}

class BreathingExerciseSheet extends ConsumerStatefulWidget {
  const BreathingExerciseSheet({super.key});

  @override
  ConsumerState<BreathingExerciseSheet> createState() => _BreathingExerciseSheetState();
}

class _BreathingExerciseSheetState extends ConsumerState<BreathingExerciseSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _countdownTimer;

  BreathingPattern _pattern = BreathingPattern.sleep478;
  BreathPhase _currentPhase = BreathPhase.inhale;

  bool _isActive = true;
  int _secondsRemaining = 4;
  int _completedCycles = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this);
    _startPhase(BreathPhase.inhale);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  int _getPhaseDuration(BreathPhase phase) {
    switch (_pattern) {
      case BreathingPattern.sleep478:
        switch (phase) {
          case BreathPhase.inhale:
            return 4;
          case BreathPhase.holdIn:
            return 7;
          case BreathPhase.exhale:
            return 8;
          case BreathPhase.holdOut:
            return 0;
        }
      case BreathingPattern.box4444:
        return 4;
      case BreathingPattern.gentle46:
        switch (phase) {
          case BreathPhase.inhale:
            return 4;
          case BreathPhase.holdIn:
            return 0;
          case BreathPhase.exhale:
            return 6;
          case BreathPhase.holdOut:
            return 0;
        }
    }
  }

  void _startPhase(BreathPhase phase) {
    _countdownTimer?.cancel();
    _currentPhase = phase;
    _secondsRemaining = _getPhaseDuration(phase);

    // Haptic pulse when transitioning phases
    HapticFeedback.mediumImpact();

    // Configure animation
    switch (phase) {
      case BreathPhase.inhale:
        _animController.duration = Duration(seconds: _secondsRemaining);
        _animController.forward(from: 0.0);
        break;
      case BreathPhase.holdIn:
      case BreathPhase.holdOut:
        break;
      case BreathPhase.exhale:
        _animController.duration = Duration(seconds: _secondsRemaining);
        _animController.reverse(from: 1.0);
        break;
    }

    if (!_isActive) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        _moveToNextPhase();
      }
    });
  }

  void _moveToNextPhase() {
    switch (_pattern) {
      case BreathingPattern.sleep478:
        if (_currentPhase == BreathPhase.inhale) {
          _startPhase(BreathPhase.holdIn);
        } else if (_currentPhase == BreathPhase.holdIn) {
          _startPhase(BreathPhase.exhale);
        } else {
          setState(() => _completedCycles++);
          _startPhase(BreathPhase.inhale);
        }
        break;
      case BreathingPattern.box4444:
        if (_currentPhase == BreathPhase.inhale) {
          _startPhase(BreathPhase.holdIn);
        } else if (_currentPhase == BreathPhase.holdIn) {
          _startPhase(BreathPhase.exhale);
        } else if (_currentPhase == BreathPhase.exhale) {
          _startPhase(BreathPhase.holdOut);
        } else {
          setState(() => _completedCycles++);
          _startPhase(BreathPhase.inhale);
        }
        break;
      case BreathingPattern.gentle46:
        if (_currentPhase == BreathPhase.inhale) {
          _startPhase(BreathPhase.exhale);
        } else {
          setState(() => _completedCycles++);
          _startPhase(BreathPhase.inhale);
        }
        break;
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _startPhase(_currentPhase);
      } else {
        _countdownTimer?.cancel();
        _animController.stop();
      }
    });
    HapticFeedback.selectionClick();
  }

  void _selectPattern(BreathingPattern pattern) {
    if (_pattern == pattern) return;
    setState(() {
      _pattern = pattern;
      _completedCycles = 0;
      _startPhase(BreathPhase.inhale);
    });
  }

  String _getPhaseText(bool isSi) {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return AppStrings.inhale(isSi);
      case BreathPhase.holdIn:
      case BreathPhase.holdOut:
        return AppStrings.hold(isSi);
      case BreathPhase.exhale:
        return AppStrings.exhale(isSi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTeal = const Color(0xFF0C4648);
    final softCyan = const Color(0xFF5ED1C7);
    final softPeach = const Color(0xFFFFAE85);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF13272C).withValues(alpha: 0.88),
                      const Color(0xFF0C1F23).withValues(alpha: 0.92),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.86),
                      const Color(0xFFE6F5F3).withValues(alpha: 0.88),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.75),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.4 : 0.16),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),

                // Header with title, icon, and close button (NO OVERFLOW - using Expanded)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.1),
                        border: Border.all(
                          color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                      child: Icon(Icons.air_rounded, size: 22, color: isDark ? Colors.white : primaryTeal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.breathingTitle(isSi),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.breathingSubtitle(isSi),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : const Color(0xFF5A7275),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Frosted Glass Pattern Selection Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildPatternPill(
                        title: AppStrings.pattern478(isSi),
                        pattern: BreathingPattern.sleep478,
                        isDark: isDark,
                        primaryTeal: primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      _buildPatternPill(
                        title: AppStrings.patternBox(isSi),
                        pattern: BreathingPattern.box4444,
                        isDark: isDark,
                        primaryTeal: primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      _buildPatternPill(
                        title: AppStrings.patternGentle(isSi),
                        pattern: BreathingPattern.gentle46,
                        isDark: isDark,
                        primaryTeal: primaryTeal,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Interactive Animated Frosted Glass Breathing Orb
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.1),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      height: 220,
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          // Expansion scale based on phase
                          double orbScale;
                          if (_currentPhase == BreathPhase.inhale) {
                            orbScale = 0.68 + (_animController.value * 0.32);
                          } else if (_currentPhase == BreathPhase.exhale) {
                            orbScale = 0.68 + (_animController.value * 0.32);
                          } else {
                            orbScale = _currentPhase == BreathPhase.holdIn ? 1.0 : 0.68;
                          }

                          // Colors by phase
                          Color orbColor1;
                          Color orbColor2;
                          if (_currentPhase == BreathPhase.holdIn || _currentPhase == BreathPhase.holdOut) {
                            orbColor1 = softPeach;
                            orbColor2 = const Color(0xFFF89966);
                          } else {
                            orbColor1 = const Color(0xFF1E676B);
                            orbColor2 = primaryTeal;
                          }

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Ambient Frosted Ripple Ring
                              Container(
                                width: 220 * orbScale,
                                height: 220 * orbScale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (_currentPhase == BreathPhase.holdIn ? softPeach : softCyan)
                                      .withValues(alpha: 0.16),
                                ),
                              ),
                              // Middle Glass Aura Ring
                              Container(
                                width: 185 * orbScale,
                                height: 185 * orbScale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: orbColor1.withValues(alpha: 0.24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // Core Luminous Frosted Glass Bubble
                              Container(
                                width: 146 * orbScale,
                                height: 146 * orbScale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      orbColor1.withValues(alpha: 0.95),
                                      orbColor2,
                                    ],
                                    center: Alignment.topLeft,
                                    radius: 0.85,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: orbColor2.withValues(alpha: 0.4),
                                      blurRadius: 26,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$_secondsRemaining',
                                      style: const TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    Text(
                                      _currentPhase == BreathPhase.holdIn || _currentPhase == BreathPhase.holdOut
                                          ? 'SEC'
                                          : (_currentPhase == BreathPhase.inhale ? '▲ IN' : '▼ OUT'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withValues(alpha: 0.85),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Phase Instruction Text inside a Frosted Glass Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.16),
                      width: 1.2,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _getPhaseText(isSi),
                      key: ValueKey(_currentPhase),
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : primaryTeal,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Completed Cycles Counter
                Text(
                  AppStrings.completedCycles(isSi, _completedCycles),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF5A7275),
                  ),
                ),

                const SizedBox(height: 24),

                // Controls: Play / Pause Premium Frosted Glass Button
                ScaleButton(
                  onTap: _togglePlayPause,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isActive
                                ? [
                                    const Color(0xFF0C4648).withValues(alpha: 0.95),
                                    const Color(0xFF1E676B).withValues(alpha: 0.95),
                                  ]
                                : [
                                    const Color(0xFFFFAE85).withValues(alpha: 0.95),
                                    const Color(0xFFF89966).withValues(alpha: 0.95),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isActive ? primaryTeal : const Color(0xFFF8AB80)).withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: _isActive ? Colors.white : const Color(0xFF4D2411),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isActive ? AppStrings.pauseBreathing(isSi) : AppStrings.startBreathing(isSi),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isActive ? Colors.white : const Color(0xFF4D2411),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatternPill({
    required String title,
    required BreathingPattern pattern,
    required bool isDark,
    required Color primaryTeal,
  }) {
    final isSelected = _pattern == pattern;

    return ScaleButton(
      onTap: () => _selectPattern(pattern),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFF0C4648).withValues(alpha: 0.92),
                    const Color(0xFF1E676B).withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.65)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5ED1C7).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: isDark ? 0.2 : 0.85),
            width: 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0C4648).withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : primaryTeal),
          ),
        ),
      ),
    );
  }
}
