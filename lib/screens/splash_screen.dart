import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      _navigateToTarget();
    });
  }

  void _navigateToTarget() {
    if (!mounted) return;

    final user = ref.read(authProvider);
    final settingsState = ref.read(settingsProvider);
    final isOnboardingCompleted = settingsState.isOnboardingCompleted;

    Widget targetScreen;
    if (user == null) {
      targetScreen = const AuthScreen();
    } else if (!isOnboardingCompleted) {
      targetScreen = const OnboardingScreen();
    } else {
      targetScreen = const MainNavigationScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;

    final primaryColor = isDark ? Colors.white : const Color(0xFF0C4648);
    final accentTeal = isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Frosted Glass Background Aura Blobs
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF0C4648) : const Color(0xFFBDE4E1)).withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF163C42) : const Color(0xFFD5ECE7)).withValues(alpha: 0.42),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: -30,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8AB80).withValues(alpha: isDark ? 0.18 : 0.28),
              ),
            ),
          ),

          // Central Frosted Glass Showcase Panel
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 38),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    const Color(0xFF132B30).withValues(alpha: 0.76),
                                    const Color(0xFF0C1D21).withValues(alpha: 0.60),
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.82),
                                    const Color(0xFFEAF6F4).withValues(alpha: 0.60),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.16)
                                : Colors.white.withValues(alpha: 0.90),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.35 : 0.08),
                              blurRadius: 36,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Glowing Halo behind Frosted Glass Logo Badge
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentTeal.withValues(alpha: _glowAnimation.value),
                                        blurRadius: 36,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: child,
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                  child: Container(
                                    width: 106,
                                    height: 106,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (isDark ? Colors.white : Colors.white)
                                          .withValues(alpha: isDark ? 0.10 : 0.75),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.85),
                                        width: 1.8,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.30 : 0.10),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.waves_rounded,
                                          size: 52,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 26),

                            // Dual-Tone Accented Brand Title matching the App Header
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Aqua',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: primaryColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Soothe',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: accentTeal,
                                      letterSpacing: -0.5,
                                      shadows: [
                                        Shadow(
                                          color: accentTeal.withValues(alpha: 0.35),
                                          blurRadius: 14,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Tagline in Frosted Glass Pill
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.08 : 0.65),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.16 : 0.85),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentTeal.withValues(alpha: 0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    isSi ? 'සුව නින්ද  •  ස්මාර්ට් ජල සමීකරණය' : 'Mindful Hydration  •  Restorative Sleep',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: subtitleColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Subtle Pulsing Loading Indicator in Accent Teal
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(accentTeal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
