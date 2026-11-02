import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_model.dart';
import '../providers/auth_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/custom_sound_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_sound_recommender.dart';
import '../widgets/scale_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/ai_sound_reveal_sheet.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool initialIsSignUp;
  const AuthScreen({super.key, this.initialIsSignUp = false});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isSignUp; // false = Login, true = Create Account
  bool _isGoogleRegistration = false;
  int _signUpStep = 0; // 0 = Credentials, 1 = Sleep Goal, 2 = Environment, 3 = Sound Depth
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedGender = 'female'; // 'female', 'male'

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // AI Sound Personalization preferences on Sign-up
  UserMoodState _selectedMood = UserMoodState.insomnia;
  bool _isCustomMood = false;
  final _customGoalController = TextEditingController();
  final _customGoalFocus = FocusNode();

  String _selectedEnvironment = 'ocean'; // 'ocean', 'rainfall', 'waterfall', 'forest', 'brown_noise', 'custom'
  bool _isCustomEnvironment = false;
  final _customEnvironmentController = TextEditingController();
  final _customEnvironmentFocus = FocusNode();

  String _selectedDepth = 'balanced'; // 'soft', 'balanced', 'deep'

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _customGoalController.dispose();
    _customEnvironmentController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _customGoalFocus.dispose();
    _customEnvironmentFocus.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_signUpStep == 0) {
      if (!_isGoogleRegistration) {
        if (!_formKey.currentState!.validate()) return;
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _errorMessage = ref.read(settingsProvider).isSinhala
                ? 'මුරපද එකිනෙකට නොගැලපේ'
                : 'Passwords do not match';
          });
          return;
        }
      }
    }
    if (_signUpStep == 1 && _isCustomMood && _customGoalController.text.trim().isEmpty) {
      _customGoalController.text = 'Personal Sleep Relief';
    }
    if (_signUpStep == 2 && _isCustomEnvironment && _customEnvironmentController.text.trim().isEmpty) {
      _customEnvironmentController.text = 'Natural Ambient Harmony';
    }
    HapticFeedback.lightImpact();
    setState(() {
      _signUpStep++;
      _errorMessage = null;
    });
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_signUpStep > 0) _signUpStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSi = ref.watch(settingsProvider).isSinhala;
    final primaryColor = isDark ? Colors.white : const Color(0xFF0C4648);
    final accentColor = isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B);
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Background Aura Blobs
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
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Frosted Glass Logo Badge
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.65),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.7),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.2 : 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1F2F0),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                _isSignUp ? Icons.water_drop_rounded : Icons.waves_rounded,
                                size: 30,
                                color: const Color(0xFF0C4648),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Matching Dual-Tone Accented Brand Name
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Aqua',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Soothe',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: accentColor.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Main Glassmorphic Form Card
                    GlassCard(
                      borderRadius: 28,
                      blur: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Bar with Step Progress (when signing up and in steps 1, 2, 3)
                          if (_isSignUp && _signUpStep > 0) ...[
                            Row(
                              children: [
                                ScaleButton(
                                  onTap: _previousStep,
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (isDark ? Colors.white : primaryColor).withValues(alpha: 0.08),
                                      border: Border.all(
                                        color: (isDark ? Colors.white : primaryColor).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: Icon(Icons.arrow_back_rounded, size: 18, color: textColor),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isSi
                                            ? 'AI පියවර $_signUpStep / 3'
                                            : 'AI Sound Step $_signUpStep of 3',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: accentColor,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: _signUpStep / 3.0,
                                          minHeight: 5,
                                          backgroundColor: (isDark ? Colors.white : primaryColor).withValues(alpha: 0.1),
                                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Heading & Subtitle (Step specific)
                          _buildStepHeader(isSi, textColor, subtitleColor),

                          const SizedBox(height: 18),

                          if (_errorMessage != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Step 0: Stable, direct text fields (No AnimatedSwitcher around Form to ensure reliable keyboard focus)
                          if (!_isSignUp || _signUpStep == 0)
                            _buildCredentialsForm(isDark, textColor, subtitleColor, isSi)
                          else
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.04, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildQuestionnaireStep(isDark, textColor, subtitleColor, isSi, accentColor),
                            ),

                          const SizedBox(height: 22),

                          // Step Action Buttons
                          _buildStepActionButtons(isDark, textColor, subtitleColor, isSi),

                          // Google Sign-In divider & button (only on login or step 0 of signup)
                          if ((!_isSignUp || _signUpStep == 0) && !_isGoogleRegistration) ...[
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                  child: Text(
                                    isSi ? 'හෝ' : 'OR',
                                    style: TextStyle(
                                      color: subtitleColor.withValues(alpha: 0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _buildGoogleSignInButton(isDark, textColor, subtitleColor, isSi),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (!_isGoogleRegistration) ...[
                      if (!_isSignUp) ...[
                        ScaleButton(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isSi ? 'මුරපදය නැවත සැකසීමේ උපදෙස් ඔබගේ Email වෙත යැවිනි.' : 'Password reset instructions sent to your email.'),
                                backgroundColor: const Color(0xFF0C4648),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              isSi ? 'මුරපදය අමතකද?' : 'Forgot Password?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: subtitleColor,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Switch between Sign in and Create Account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUp
                                ? (isSi ? 'දැනටමත් ගිණුමක් තිබේද?' : 'Already have an account?')
                                : (isSi ? 'නව පරිශීලකයෙක්ද?' : "Don't have an account?"),
                            style: TextStyle(color: subtitleColor, fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          ScaleButton(
                            onTap: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                                _signUpStep = 0;
                                _errorMessage = null;
                                _confirmPasswordController.clear();
                              });
                            },
                            child: Text(
                              _isSignUp ? (isSi ? 'පිවිසෙන්න' : 'Sign In') : (isSi ? 'ගිණුමක් සාදන්න' : 'Create Account'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Guest Login Frosted Glass Pill
                      ScaleButton(
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          await ref.read(authProvider.notifier).loginAsGuest();
                          if (!mounted) return;
                          navigator.pushReplacement(
                            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_outline_rounded, size: 18, color: subtitleColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    isSi ? 'අමුත්තෙකු ලෙස ඉදිරියට යන්න' : 'Continue as Guest',
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(bool isSi, Color textColor, Color subtitleColor) {
    if (!_isSignUp) {
      return Column(
        children: [
          Text(
            isSi ? 'නැවත පිවිසෙන්න' : 'Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSi ? 'AquaSoothe සමඟින් ඔබේ සුවබර ගමන අඛණ්ඩව කරගෙන යන්න.' : 'Sign in to continue your restorative sleep journey.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: subtitleColor, height: 1.3),
          ),
        ],
      );
    }

    switch (_signUpStep) {
      case 0:
        return Column(
          children: [
            Text(
              _isGoogleRegistration
                  ? (isSi ? 'සුවතා පැතිකඩ සකසන්න' : 'Personalize Your Profile')
                  : (isSi ? 'ගිණුමක් සාදන්න' : 'Create Account'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isGoogleRegistration
                  ? (isSi
                      ? 'ඔබගේ Google ගිණුම සම්බන්ධ විය. AI නින්දේ පැතිකඩ සැකසීමට ඔබේ ස්ත්‍රී/පුරුෂ භාවය තෝරන්න.'
                      : 'Signed in with Google! Select your gender to personalize your sleep goals.')
                  : (isSi ? 'මුලින්ම ඔබගේ ගිණුමේ මූලික තොරතුරු ඇතුළත් කරන්න.' : 'First, enter your basic account credentials.'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: subtitleColor, height: 1.3),
            ),
          ],
        );
      case 1:
        final String step1Title = _selectedGender == 'female'
            ? (isSi ? 'ඔබගේ සුව නින්ද සහ සුවතාවයේ ඉලක්කය කුමක්ද?' : 'What is your feminine sleep & wellness goal?')
            : (isSi ? 'ඔබගේ ප්‍රධාන නින්ද සහ කායික විවේක ඉලක්කය කුමක්ද?' : 'What is your recovery & sleep goal?');
        final String step1Subtitle = _selectedGender == 'female'
            ? (isSi ? 'ඔබගේ ශරීරයට සහ සුවතාවයට ගැලපෙන acoustic frequencies හඳුනා ගැනීමට තෝරන්න.' : 'Tailored acoustic frequencies for feminine wellness, emotional calm & restorative sleep.')
            : (isSi ? 'දවසේ දැඩි පීඩනය සහ මාංශපේශී විවේකය සඳහා ගැලපෙන ශබ්ද හඳුනා ගැනීමට තෝරන්න.' : 'Calibrated acoustic frequencies for athletic recovery, burnout decompression & deep sleep.');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step1Title,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              step1Subtitle,
              style: TextStyle(fontSize: 13, color: subtitleColor, height: 1.3),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSi ? 'වඩාත් සන්සුන් වන ජල පරිසරය කුමක්ද?' : 'Preferred acoustic environment?',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isSi ? 'ඔබව ඉක්මනින් නින්දට රැගෙන යන ස්වභාවික නාදය තෝරන්න.' : 'Choose the natural acoustic texture that relaxes your mind most.',
              style: TextStyle(fontSize: 13, color: subtitleColor, height: 1.3),
            ),
          ],
        );
      case 3:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSi ? 'ශබ්දයේ ගැඹුර සහ තීව්‍රතාවය තෝරන්න' : 'Desired sound depth & masking?',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isSi ? 'ඔබේ කාමරයේ පසුබිම් පරිසරයට අනුව ශබ්දයේ ඝනකම සකසන්න.' : 'How rich or dense would you like your personalized sound blanket?',
              style: TextStyle(fontSize: 13, color: subtitleColor, height: 1.3),
            ),
          ],
        );
    }
  }

  Widget _buildCredentialsForm(bool isDark, Color textColor, Color subtitleColor, bool isSi) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isGoogleRegistration) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(7),
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isNotEmpty ? _nameController.text : 'Google User',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _emailController.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          isSi ? 'සම්බන්ධයි' : 'Connected',
                          style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Text(
              isSi ? 'ස්ත්‍රී / පුරුෂ භාවය (Gender)' : 'Select Your Gender',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildGenderCard(
                    title: isSi ? 'ස්ත්‍රී (Female)' : 'Female',
                    emoji: '👩',
                    isSelected: _selectedGender == 'female',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedGender = 'female';
                        _isCustomMood = false;
                        _selectedMood = UserMoodState.windDown;
                      });
                    },
                    isDark: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildGenderCard(
                    title: isSi ? 'පුරුෂ (Male)' : 'Male',
                    emoji: '👨',
                    isSelected: _selectedGender == 'male',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedGender = 'male';
                        _isCustomMood = false;
                        _selectedMood = UserMoodState.exhausted;
                      });
                    },
                    isDark: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ] else ...[
            if (_isSignUp) ...[
              Text(
                isSi ? 'නම' : 'Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                enableSuggestions: false,
                enableInteractiveSelection: true,
                keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
                style: TextStyle(fontSize: 15, color: textColor),
                decoration: _buildInputDecoration(isSi ? 'උදා: කසුන් පෙරේරා' : 'e.g., Jane Smith', Icons.person_outline_rounded, isDark, subtitleColor, textColor),
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                validator: (val) => val == null || val.trim().isEmpty ? (isSi ? 'කරුණාකර නම ඇතුළත් කරන්න' : 'Please enter your name') : null,
              ),
              const SizedBox(height: 14),

              Text(
                isSi ? 'ස්ත්‍රී / පුරුෂ භාවය (Gender)' : 'Gender',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderCard(
                      title: isSi ? 'ස්ත්‍රී (Female)' : 'Female',
                      emoji: '👩',
                      isSelected: _selectedGender == 'female',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedGender = 'female';
                          _isCustomMood = false;
                          _selectedMood = UserMoodState.windDown;
                        });
                      },
                      isDark: isDark,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildGenderCard(
                      title: isSi ? 'පුරුෂ (Male)' : 'Male',
                      emoji: '👨',
                      isSelected: _selectedGender == 'male',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedGender = 'male';
                          _isCustomMood = false;
                          _selectedMood = UserMoodState.exhausted;
                        });
                      },
                      isDark: isDark,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            Text(
              isSi ? 'විද්‍යුත් තැපෑල (Email)' : 'Email Address',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableInteractiveSelection: true,
              keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
              style: TextStyle(fontSize: 15, color: textColor),
              decoration: _buildInputDecoration('your@email.com', Icons.mail_outline_rounded, isDark, subtitleColor, textColor),
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
              validator: (val) => val == null || !val.contains('@') ? (isSi ? 'වලංගු Email ලිපිනයක් ඇතුළත් කරන්න' : 'Enter a valid email') : null,
            ),
            const SizedBox(height: 14),

            Text(
              isSi ? 'මුරපදය (Password)' : 'Password',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
              obscureText: _obscurePassword,
              enableInteractiveSelection: true,
              keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
              style: TextStyle(fontSize: 15, color: textColor),
              decoration: InputDecoration(
                hintText: isSi ? 'මුරපදය ඇතුළත් කරන්න' : 'Enter your password',
                hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.6), fontSize: 13.5),
                prefixIcon: Icon(Icons.lock_outline_rounded, color: subtitleColor, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: subtitleColor, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: isDark ? 0.05 : 0.55),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: textColor, width: 1.5),
                ),
              ),
              onFieldSubmitted: (_) => _isSignUp ? FocusScope.of(context).requestFocus(_confirmPasswordFocus) : _submitAuthForm(),
              validator: (val) => val == null || val.length < 4 ? (isSi ? 'අවම වශයෙන් අකුරු 4ක් අවශ්‍යයි' : 'Password must be at least 4 characters') : null,
            ),

            if (_isSignUp) ...[
              const SizedBox(height: 14),
              Text(
                isSi ? 'මුරපදය තහවුරු කරන්න (Confirm Password)' : 'Confirm Password',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                textInputAction: TextInputAction.done,
                obscureText: _obscureConfirmPassword,
                enableInteractiveSelection: true,
                keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
                style: TextStyle(fontSize: 15, color: textColor),
                decoration: InputDecoration(
                  hintText: isSi ? 'මුරපදය නැවත ඇතුළත් කරන්න' : 'Re-enter your password',
                  hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.6), fontSize: 13.5),
                  prefixIcon: Icon(Icons.lock_reset_rounded, color: subtitleColor, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: subtitleColor, size: 20),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: isDark ? 0.05 : 0.55),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: textColor, width: 1.5),
                  ),
                ),
                onFieldSubmitted: (_) => _nextStep(),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return isSi ? 'කරුණාකර මුරපදය තහවුරු කරන්න' : 'Please confirm your password';
                  }
                  if (val != _passwordController.text) {
                    return isSi ? 'මුරපද එකිනෙකට නොගැලපේ' : 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionnaireStep(bool isDark, Color textColor, Color subtitleColor, bool isSi, Color accentColor) {
    // Step 1: Sleep Goal
    if (_signUpStep == 1) {
      if (_selectedGender == 'female') {
        return Column(
          key: const ValueKey('step_1_female_goals'),
          children: [
            _buildOptionCard(
              title: isSi ? 'හෝමෝන සමතුලිතතාවය සහ සුව නින්ද' : 'Hormonal & Cycle Comfort',
              subtitle: isSi ? 'හෝමෝන වෙනස්වීම්, ඔසප් වේදනා හා කායික අපහසුතා සමනය' : 'Soothes cycle shifts, PMS, cramps & hormonal restlessness',
              emoji: '🌸',
              isSelected: !_isCustomMood && _selectedMood == UserMoodState.windDown,
              onTap: () => setState(() {
                _isCustomMood = false;
                _selectedMood = UserMoodState.windDown;
              }),
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              accentColor: accentColor,
            ),
            _buildOptionCard(
              title: isSi ? 'අධික සිතුවිලි සහ කාන්සාව' : 'Racing Thoughts & Emotional Fatigue',
              subtitle: isSi ? 'දවසේ වැඩකටයුතු සහ පවුලේ වගකීම් නිසා මනස වෙහෙසීම' : 'Relieves anxiety, mental chatter & evening overload',
              emoji: '🧠',
              isSelected: !_isCustomMood && _selectedMood == UserMoodState.stressed,
              onTap: () => setState(() {
                _isCustomMood = false;
                _selectedMood = UserMoodState.stressed;
              }),
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              accentColor: accentColor,
            ),
            _buildOptionCard(
              title: isSi ? 'නින්ද නොයාම (Insomnia)' : 'Difficulty Falling Asleep (Insomnia)',
              subtitle: isSi ? 'නින්ද ළඟා වීමට පැය භාගයකට වඩා ගතවීම' : 'Takes 30+ minutes to drift into calm sleep',
              emoji: '🌙',
              isSelected: !_isCustomMood && _selectedMood == UserMoodState.insomnia,
              onTap: () => setState(() {
                _isCustomMood = false;
                _selectedMood = UserMoodState.insomnia;
              }),
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              accentColor: accentColor,
            ),
            _buildOptionCard(
              title: isSi ? 'සම සහ ශරීරය ප්‍රකෘතිමත් වීම (Beauty Sleep)' : 'Cellular & Beauty Restoration',
              subtitle: isSi ? 'ප්‍රබෝධමත් උදෑසනක් සහ දීප්තිමත් සමක් සඳහා ගැඹුරු නින්ද' : 'Deep REM rejuvenation for glowing skin & cell renewal',
              emoji: '✨',
              isSelected: !_isCustomMood && _selectedMood == UserMoodState.lightSleeper,
              onTap: () => setState(() {
                _isCustomMood = false;
                _selectedMood = UserMoodState.lightSleeper;
              }),
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              accentColor: accentColor,
            ),
            _buildOptionCard(
              title: isSi ? 'බාහිර ශබ්ද නිසා නින්ද කැඩීම' : 'Sensitive to Household & External Noise',
              subtitle: isSi ? 'දරුවන්ගේ හෝ ගෙදර දොරේ කුඩා ශබ්දයකින් වුවද ගැස්සී අවදි වීම' : 'Easily awakened by baby, family or traffic noise',
              emoji: '🔊',
              isSelected: !_isCustomMood && _selectedMood == UserMoodState.exhausted,
              onTap: () => setState(() {
                _isCustomMood = false;
                _selectedMood = UserMoodState.exhausted;
              }),
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              accentColor: accentColor,
            ),
            _buildOptionCard(
              title: isSi ? 'වෙනත් විශේෂිත අවශ්‍යතාවක් (Custom Need)' : 'Something Else / Custom Need',
              subtitle: isSi ? 'ඔබට අවශ්‍ය වෙනත් ඕනෑම දෙයක් මෙහි ලියා ඉල්ලන්න' : 'Describe your specific sleep need or condition',
              emoji: '✍️',
              isSelected: _isCustomMood,
              onTap: () {
                setState(() => _isCustomMood = true);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) _customGoalFocus.requestFocus();
                });
              },
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              accentColor: accentColor,
            ),
            if (_isCustomMood)
              _buildCustomInputField(
                headerLabel: isSi ? 'ඔබගේ අවශ්‍යතාවය මෙහි සඳහන් කරන්න:' : 'Describe your custom sleep challenge:',
                hintText: isSi
                    ? 'උදා: ගර්භණී සමයේ නින්ද, කන් වල නාදය (Tinnitus), මෙනෝපෝස් අපහසුතා...'
                    : 'e.g., Pregnancy sleep, tinnitus relief, menopause heat flashes...',
                controller: _customGoalController,
                focusNode: _customGoalFocus,
                isDark: isDark,
                textColor: textColor,
                subtitleColor: subtitleColor,
                accentColor: accentColor,
              ),
          ],
        );
      }

      // Male specific goals
      return Column(
        key: const ValueKey('step_1_male_goals'),
        children: [
          _buildOptionCard(
            title: isSi ? 'මාංශපේශී ප්‍රකෘතිමත් වීම (Muscle Strain)' : 'Athletic & Muscle Recovery',
            subtitle: isSi ? 'දැඩි වෙහෙස සහ කායවර්ධන/ක්‍රීඩා පසු මාංශපේශී විවේකය' : 'Relieves soreness, tension & accelerates physical repair',
            emoji: '💪',
            isSelected: !_isCustomMood && _selectedMood == UserMoodState.exhausted,
            onTap: () => setState(() {
              _isCustomMood = false;
              _selectedMood = UserMoodState.exhausted;
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'රැකියා ආතතිය සහ බර්න්අවුට් (Burnout)' : 'Workplace Pressure & Mental Burnout',
            subtitle: isSi ? 'දවසේ අධික රැකියා පීඩනය සහ මානසික තෙහෙට්ටුව දුරුකිරීම' : 'Releases occupational overload & clears intense cognitive fatigue',
            emoji: '💼',
            isSelected: !_isCustomMood && _selectedMood == UserMoodState.stressed,
            onTap: () => setState(() {
              _isCustomMood = false;
              _selectedMood = UserMoodState.stressed;
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'නින්ද නොයාම (Insomnia)' : 'Difficulty Falling Asleep (Insomnia)',
            subtitle: isSi ? 'නින්ද ළඟා වීමට පැය භාගයකට වඩා ගතවීම' : 'Takes 30+ minutes to drift into sleep',
            emoji: '🌙',
            isSelected: !_isCustomMood && _selectedMood == UserMoodState.insomnia,
            onTap: () => setState(() {
              _isCustomMood = false;
              _selectedMood = UserMoodState.insomnia;
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'ගොරවීම සහ බාහිර ශබ්ද ආවරණය' : 'Snoring Mask & Heavy Sleep Shield',
            subtitle: isSi ? 'ගැඹුරු ඝන නින්දක් සඳහා බාහිර ශබ්ද සහ බාධා ආවරණය කිරීම' : 'Deep acoustic blanket for uninterrupted delta wave sleep',
            emoji: '🛡️',
            isSelected: !_isCustomMood && _selectedMood == UserMoodState.lightSleeper,
            onTap: () => setState(() {
              _isCustomMood = false;
              _selectedMood = UserMoodState.lightSleeper;
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'සන්සුන් විවේකය (Screen Decompression)' : 'Evening Wind Down & Mind Quieting',
            subtitle: isSi ? 'නින්දට පෙර තිර භාවිතය (Screen time) පසු මනස නිවීම' : 'Decompresses nervous system after blue light & screens',
            emoji: '📖',
            isSelected: !_isCustomMood && _selectedMood == UserMoodState.windDown,
            onTap: () => setState(() {
              _isCustomMood = false;
              _selectedMood = UserMoodState.windDown;
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'වෙනත් විශේෂිත අවශ්‍යතාවක් (Custom Need)' : 'Something Else / Custom Need',
            subtitle: isSi ? 'ඔබට අවශ්‍ය වෙනත් ඕනෑම දෙයක් මෙහි ලියා ඉල්ලන්න' : 'Describe your specific sleep need or condition',
            emoji: '✍️',
            isSelected: _isCustomMood,
            onTap: () {
              setState(() => _isCustomMood = true);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _customGoalFocus.requestFocus();
              });
            },
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          if (_isCustomMood)
            _buildCustomInputField(
              headerLabel: isSi ? 'ඔබගේ අවශ්‍යතාවය මෙහි සඳහන් කරන්න:' : 'Describe your custom sleep challenge:',
              hintText: isSi
                  ? 'උදා: සේවා මුර නින්ද (Shift work), කන් වල නාදය (Tinnitus), අධික තෙහෙට්ටුව...'
                  : 'e.g., Shift work sleep cycles, tinnitus ringing, heavy physical exhaustion...',
              controller: _customGoalController,
              focusNode: _customGoalFocus,
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              accentColor: accentColor,
            ),
        ],
      );
    }

    // Step 2: Environment
    if (_signUpStep == 2) {
      return Column(
        key: const ValueKey('step_2_environment'),
        children: [
          _buildOptionCard(
            title: isSi ? 'සාගර රළ පහර (Ocean Waves)' : 'Ocean Waves & Sea Breeze',
            subtitle: isSi ? 'හුස්ම ගැනීමේ රිද්මයට සමාන සාගර නාද' : 'Rhythmic rolling swells mimic calm breathing',
            emoji: '🌊',
            isSelected: !_isCustomEnvironment && _selectedEnvironment == 'ocean',
            onTap: () => setState(() {
              _isCustomEnvironment = false;
              _selectedEnvironment = 'ocean';
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'මෘදු වැසි ශබ්දය (Soothing Rain)' : 'Soft Rain on Leaves & Canopy',
            subtitle: isSi ? 'මනස සනසන ස්වභාවික වැසි බිංදු' : 'Gentle drops create a safe acoustic shelter',
            emoji: '🌧️',
            isSelected: !_isCustomEnvironment && _selectedEnvironment == 'rainfall',
            onTap: () => setState(() {
              _isCustomEnvironment = false;
              _selectedEnvironment = 'rainfall';
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'කඳුකර දිය ඇල්ල (Waterfall)' : 'Cascading Waterfall',
            subtitle: isSi ? 'ගැඹුරු ස්ථාවර දිය දහරාව' : 'Steady, robust fresh water cascades',
            emoji: '💧',
            isSelected: !_isCustomEnvironment && _selectedEnvironment == 'waterfall',
            onTap: () => setState(() {
              _isCustomEnvironment = false;
              _selectedEnvironment = 'waterfall';
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'වන ලැහැබ (Forest Breeze)' : 'Gentle Forest Breeze & Pine',
            subtitle: isSi ? 'සුවදායී වන අරණක සුළං රැළි' : 'Whispering leaves and tranquil woodland canopy',
            emoji: '🌲',
            isSelected: !_isCustomEnvironment && _selectedEnvironment == 'forest',
            onTap: () => setState(() {
              _isCustomEnvironment = false;
              _selectedEnvironment = 'forest';
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'ගැඹුරු බ්‍රවුන් නාදය (Brown Noise)' : 'Deep Brown Noise Harmonic',
            subtitle: isSi ? 'මනසේ සිතුවිලි නිහඬ කරන ගැඹුරු නාදය' : 'Rich low-frequency rumble that calms cortex',
            emoji: '🌌',
            isSelected: !_isCustomEnvironment && _selectedEnvironment == 'brown_noise',
            onTap: () => setState(() {
              _isCustomEnvironment = false;
              _selectedEnvironment = 'brown_noise';
            }),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          _buildOptionCard(
            title: isSi ? 'වෙනත් ස්වභාවික නාදයක් (Custom Ambience)' : 'Other / Custom Soundscape',
            subtitle: isSi ? 'ඔබ කැමති වෙනත් ඕනෑම ස්වභාවික ශබ්දයක් ලියන්න' : 'Type any custom natural soundscape you prefer',
            emoji: '✨',
            isSelected: _isCustomEnvironment,
            onTap: () {
              setState(() => _isCustomEnvironment = true);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _customEnvironmentFocus.requestFocus();
              });
            },
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            accentColor: accentColor,
          ),
          if (_isCustomEnvironment)
            _buildCustomInputField(
              headerLabel: isSi ? 'කැමති ශබ්දය හෝ පරිසරය මෙහි සඳහන් කරන්න:' : 'Describe your preferred acoustic soundscape:',
              hintText: isSi
                  ? 'උදා: ගිනි මැලයක ශබ්දය (Campfire), ගංගා දිය දහරාව, රාත්‍රී රැහැයි නාදය...'
                  : 'e.g., Crackling campfire, gentle river stream, midnight crickets...',
              controller: _customEnvironmentController,
              focusNode: _customEnvironmentFocus,
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              accentColor: accentColor,
            ),
        ],
      );
    }

    // Step 3: Sound Depth
    return Column(
      key: const ValueKey('step_3_sound_depth'),
      children: [
        _buildOptionCard(
          title: isSi ? 'මෘදු සහ සියුම් (Gentle & Soft)' : 'Soft & Delicate Spectrum',
          subtitle: isSi ? 'නිහඬ නිදන කාමර සඳහා ඉතා මෘදු නාදය' : 'Light, gentle background layer for quiet bedrooms',
          emoji: '🌿',
          isSelected: _selectedDepth == 'soft',
          onTap: () => setState(() => _selectedDepth = 'soft'),
          isDark: isDark,
          textColor: textColor,
          subtitleColor: subtitleColor,
          accentColor: accentColor,
        ),
        _buildOptionCard(
          title: isSi ? 'සමබර සහ ස්වභාවික (Balanced & Rich)' : 'Balanced & Immersive',
          subtitle: isSi ? 'ස්වභාවික නින්දකට වඩාත්ම නිර්දේශිතයි' : 'Organic full-spectrum resonance for restorative sleep',
          emoji: '🌊',
          isSelected: _selectedDepth == 'balanced',
          onTap: () => setState(() => _selectedDepth = 'balanced'),
          isDark: isDark,
          textColor: textColor,
          subtitleColor: subtitleColor,
          accentColor: accentColor,
        ),
        _buildOptionCard(
          title: isSi ? 'ගැඹුරු ආවරණ නාදය (Deep Acoustic Blanket)' : 'Deep Acoustic Blanket (High Masking)',
          subtitle: isSi ? 'බාහිර සියලු බාධාකාරී ශබ්ද මනාව වසා දමයි' : 'Thick, low-end shielding to mask outside disturbances',
          emoji: '🔊',
          isSelected: _selectedDepth == 'deep',
          onTap: () => setState(() => _selectedDepth = 'deep'),
          isDark: isDark,
          textColor: textColor,
          subtitleColor: subtitleColor,
          accentColor: accentColor,
        ),
      ],
    );
  }

  Widget _buildStepActionButtons(bool isDark, Color textColor, Color subtitleColor, bool isSi) {
    if (!_isSignUp) {
      // Normal Sign In
      return ScaleButton(
        onTap: _isLoading ? null : _submitAuthForm,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0C4648), Color(0xFF165C5F)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C4648).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isSi ? 'පිවිසෙන්න' : 'Sign In',
                        style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                    ],
                  ),
          ),
        ),
      );
    }

    // Sign Up Steps
    if (_signUpStep < 3) {
      final String buttonLabel = _signUpStep == 0
          ? (isSi ? 'ඉදිරියට' : 'Continue')
          : (isSi ? 'ඊළඟ පියවර' : 'Next Step');

      return ScaleButton(
        onTap: _nextStep,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0C4648), Color(0xFF1B706E)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C4648).withValues(alpha: 0.32),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                buttonLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
            ],
          ),
        ),
      );
    }

    // Final Step 3: Complete Sign Up & Generate Sound
    return ScaleButton(
      onTap: _isLoading ? null : _submitAuthForm,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0C4648), Color(0xFF1B706E), Color(0xFF00897B)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C4648).withValues(alpha: 0.38),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      isSi ? 'ගිණුම සාදා නිමකරන්න' : 'Create & Finish',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.3),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGenderCard({
    required String title,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
  }) {
    final activeColor = isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B);
    return ScaleButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.24 : 0.14)
              : Colors.white.withValues(alpha: isDark ? 0.05 : 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.14),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? activeColor : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Elegant Frosted Glass Selectable Card for Step-by-Step Questions
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    required Color accentColor,
  }) {
    return ScaleButton(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          accentColor.withValues(alpha: isDark ? 0.32 : 0.20),
                          accentColor.withValues(alpha: isDark ? 0.15 : 0.07),
                        ]
                      : [
                          Colors.white.withValues(alpha: isDark ? 0.08 : 0.68),
                          Colors.white.withValues(alpha: isDark ? 0.03 : 0.35),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.85)
                      : (isDark ? Colors.white.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.85)),
                  width: isSelected ? 1.6 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.25)
                        : (isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF0C4648).withValues(alpha: 0.05)),
                    blurRadius: isSelected ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.45),
                    blurRadius: 1,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: isDark ? 0.06 : 0.5),
                      border: Border.all(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: isDark ? 0.15 : 0.7),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : const Color(0xFF0C4648)).withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? (isDark ? Colors.white : accentColor) : textColor,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 2.5),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white.withValues(alpha: isDark ? 0.04 : 0.25),
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : (isDark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.18)),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(Icons.check_rounded, size: 15, color: Colors.white),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Elegant Frosted Glass Custom Input Field for Other / User-Specified Requirements
  Widget _buildCustomInputField({
    required String headerLabel,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  Colors.white.withValues(alpha: isDark ? 0.05 : 0.55),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.7),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.4),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 16, color: accentColor),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        headerLabel,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.done,
                  maxLines: 2,
                  minLines: 1,
                  keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
                  style: TextStyle(fontSize: 13.5, color: textColor),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: subtitleColor.withValues(alpha: 0.65),
                      fontSize: 12.5,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: isDark ? 0.06 : 0.65),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accentColor, width: 1.4),
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

  InputDecoration _buildInputDecoration(String hint, IconData icon, bool isDark, Color subtitleColor, Color textColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.6), fontSize: 14),
      prefixIcon: Icon(icon, color: subtitleColor, size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: isDark ? 0.05 : 0.55),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: textColor, width: 1.5),
      ),
    );
  }

  String _formatDisplayName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).map((part) {
      if (part.length <= 1) return part.toUpperCase();
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _submitAuthForm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);

      if (_isSignUp) {
        if (_isGoogleRegistration) {
          await authNotifier.updateGender(_selectedGender);
        } else {
          final formattedName = _formatDisplayName(_nameController.text);
          await authNotifier.signUp(
            name: formattedName.isNotEmpty ? formattedName : _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            gender: _selectedGender,
          );
        }

        // 1. Generate customized AI sound recommendation
        UserMoodState moodForRecommender = _selectedMood;
        if (_isCustomMood && _customGoalController.text.trim().isNotEmpty) {
          final query = _customGoalController.text.trim().toLowerCase();
          if (query.contains('tinnitus') || query.contains('noise') || query.contains('mask') || query.contains('ear')) {
            moodForRecommender = UserMoodState.lightSleeper;
          } else if (query.contains('stress') || query.contains('anxi') || query.contains('panic') || query.contains('worry')) {
            moodForRecommender = UserMoodState.stressed;
          } else if (query.contains('body') || query.contains('pain') || query.contains('fatigue') || query.contains('exhaust') || query.contains('muscle') || query.contains('tired')) {
            moodForRecommender = UserMoodState.exhausted;
          } else if (query.contains('read') || query.contains('peace') || query.contains('calm') || query.contains('relax') || query.contains('meditat')) {
            moodForRecommender = UserMoodState.windDown;
          } else {
            moodForRecommender = UserMoodState.insomnia;
          }
        }

        final recommendation = AISoundRecommender.recommendSound(mood: moodForRecommender);

        // 2. Map preferred sound asset
        final defaultTracks = SoundTrack.defaultTracks;
        final selectedTrack = defaultTracks.firstWhere(
          (t) => t.id == _selectedEnvironment,
          orElse: () => recommendation.primaryTrack,
        );

        String titleSuffix;
        if (_isCustomEnvironment && _customEnvironmentController.text.trim().isNotEmpty) {
          titleSuffix = _customEnvironmentController.text.trim();
        } else if (_isCustomMood && _customGoalController.text.trim().isNotEmpty) {
          titleSuffix = _customGoalController.text.trim();
        } else if (_selectedEnvironment == 'ocean') {
          titleSuffix = 'Ocean Sanctuary';
        } else if (_selectedEnvironment == 'rainfall') {
          titleSuffix = 'Twilight Rain';
        } else if (_selectedEnvironment == 'waterfall') {
          titleSuffix = 'Cascading Haven';
        } else if (_selectedEnvironment == 'forest') {
          titleSuffix = 'Forest Serenity';
        } else {
          titleSuffix = 'Deep Acoustic Calm';
        }

        // Cap title length gracefully
        if (titleSuffix.length > 24) {
          titleSuffix = '${titleSuffix.substring(0, 24)}...';
        }

        final bespokeTitle = 'Bespoke $titleSuffix';
        final bespokeId = 'ai_bespoke_${DateTime.now().millisecondsSinceEpoch}';

        String customReasoning = recommendation.aiReasoning;
        if (_isCustomMood && _customGoalController.text.trim().isNotEmpty) {
          customReasoning = 'Specially tailored for "${_customGoalController.text.trim()}". $customReasoning';
        }
        if (_isCustomEnvironment && _customEnvironmentController.text.trim().isNotEmpty) {
          customReasoning += ' Blended with requested "${_customEnvironmentController.text.trim()}" harmonic profile.';
        }

        final bespokeTrack = SoundTrack(
          id: bespokeId,
          title: bespokeTitle,
          description: '$customReasoning Formulated with $_selectedDepth acoustic depth for ${_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "you"}.',
          assetPath: selectedTrack.assetPath,
          icon: selectedTrack.icon,
          category: 'AI Personalized',
        );

        // 3. Save to custom sound repository and set as active default
        await ref.read(customSoundProvider.notifier).saveCustomSound(bespokeTrack);
        await ref.read(settingsProvider.notifier).setLastUsedSoundId(bespokeTrack.id);
        await ref.read(audioServiceProvider).selectTrack(bespokeTrack);

        if (!mounted) return;

        // 4. Reveal newly crafted sound with interactive preview modal
        showAISoundRevealModal(
          context,
          soundTrack: bespokeTrack,
          matchPercentage: recommendation.matchPercentage,
          reasoning: bespokeTrack.description,
          onContinue: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            );
          },
        );
        return;
      } else {
        if (!_formKey.currentState!.validate()) {
          setState(() => _isLoading = false);
          return;
        }

        await authNotifier.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.signInWithGoogle();

      final currentUser = ref.read(authProvider);

      if (!mounted) return;

      // If existing user already has gender and personalized sound setup, proceed straight to home!
      if (currentUser != null && currentUser.gender != null && currentUser.gender!.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
        return;
      }

      // If new Google user or questions not yet answered, route to questionnaire!
      if (currentUser != null) {
        _nameController.text = currentUser.name;
        _emailController.text = currentUser.email;
      }

      setState(() {
        _isSignUp = true;
        _isGoogleRegistration = true;
        _signUpStep = 0; // Show Google connection badge & Gender selection
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '').trim();
      if (!msg.toLowerCase().contains('cancelled') && !msg.toLowerCase().contains('canceled')) {
        setState(() {
          _errorMessage = msg;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGoogleSignInButton(bool isDark, Color textColor, Color subtitleColor, bool isSi) {
    return ScaleButton(
      onTap: _isLoading ? null : _handleGoogleSignIn,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GoogleLogo(size: 22),
            const SizedBox(width: 12),
            Text(
              isSi ? 'Google ගිණුමෙන් පිවිසෙන්න' : 'Continue with Google',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Blue
    final bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final bluePath = Path()
      ..moveTo(23.745, 12.27)
      ..cubicTo(23.745, 11.47, 23.675, 10.72, 23.545, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.51)
      ..lineTo(18.6, 14.51)
      ..cubicTo(18.31, 16.03, 17.46, 17.33, 16.2, 18.19)
      ..lineTo(16.2, 21.24)
      ..lineTo(20.08, 21.24)
      ..cubicTo(22.35, 19.15, 23.745, 16.07, 23.745, 12.27)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Green
    final greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;
    final greenPath = Path()
      ..moveTo(12.0, 24.0)
      ..cubicTo(15.24, 24.0, 17.95, 22.92, 19.93, 21.09)
      ..lineTo(16.05, 18.04)
      ..cubicTo(14.97, 18.76, 13.6, 19.2, 12.0, 19.2)
      ..cubicTo(8.88, 19.2, 6.23, 17.1, 5.28, 14.27)
      ..lineTo(1.27, 14.27)
      ..lineTo(1.27, 17.42)
      ..cubicTo(3.25, 21.27, 7.31, 24.0, 12.0, 24.0)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Yellow
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final yellowPath = Path()
      ..moveTo(5.28, 14.27)
      ..cubicTo(5.03, 13.55, 4.9, 12.78, 4.9, 12.0)
      ..cubicTo(4.9, 11.22, 5.03, 10.45, 5.28, 9.73)
      ..lineTo(5.28, 6.58)
      ..lineTo(1.27, 6.58)
      ..cubicTo(0.46, 8.2, 0.0, 10.04, 0.0, 12.0)
      ..cubicTo(0.0, 13.96, 0.46, 15.8, 1.27, 17.42)
      ..lineTo(5.28, 14.27)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red
    final redPaint = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;
    final redPath = Path()
      ..moveTo(12.0, 4.8)
      ..cubicTo(13.77, 4.8, 15.35, 5.41, 16.6, 6.6)
      ..lineTo(20.02, 3.18)
      ..cubicTo(17.95, 1.19, 15.24, 0.0, 12.0, 0.0)
      ..cubicTo(7.31, 0.0, 3.25, 2.73, 1.27, 6.58)
      ..lineTo(5.28, 9.73)
      ..cubicTo(6.23, 6.9, 8.88, 4.8, 12.0, 4.8)
      ..close();
    canvas.drawPath(redPath, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
