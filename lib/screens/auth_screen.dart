import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_model.dart';
import '../providers/auth_provider.dart';
import '../providers/custom_sound_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_sound_recommender.dart';
import '../widgets/scale_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/ai_sound_reveal_sheet.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false; // false = Login, true = Create Account
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // AI Sound Personalization preferences on Sign-up
  UserMoodState _selectedMood = UserMoodState.insomnia;
  String _selectedEnvironment = 'ocean'; // 'ocean', 'rainfall', 'waterfall', 'forest', 'brown_noise'
  String _selectedDepth = 'balanced'; // 'soft', 'balanced', 'deep'

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSi = ref.watch(settingsProvider).isSinhala;
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                            color: (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.08 : 0.65),
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
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1F2F0),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                _isSignUp ? Icons.water_drop_rounded : Icons.waves_rounded,
                                size: 32,
                                color: const Color(0xFF0C4648),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Matching Dual-Tone Accented Brand Name
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Aqua',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Soothe',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B),
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: (isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B))
                                      .withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Main Glassmorphic Form Card
                    GlassCard(
                      borderRadius: 28,
                      blur: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26.0),
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          // Heading
                          Text(
                            _isSignUp
                                ? (isSi ? 'ගිණුමක් සාදන්න' : 'Begin Your Journey')
                                : (isSi ? 'නැවත පිවිසෙන්න' : 'Welcome Back'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Subtitle
                          Text(
                            _isSignUp
                                ? (isSi
                                    ? 'ඔබේ නින්ද සහ සුවතාවයට ගැලපෙන AI ශබ්ද සකසන්න.'
                                    : 'Create an account & craft your personalized sleep sound.')
                                : (isSi
                                    ? 'AquaSoothe සමඟින් ඔබේ සුවබර ගමන අඛණ්ඩව කරගෙන යන්න.'
                                    : 'Sign in to continue your restorative journey with AquaSoothe.'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: subtitleColor,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 22),

                          if (_errorMessage != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 22),
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

                          // Form Fields
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_isSignUp) ...[
                                  Text(
                                    isSi ? 'නම' : 'Name',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nameController,
                                    style: TextStyle(fontSize: 15, color: textColor),
                                    decoration: InputDecoration(
                                      hintText: isSi ? 'උදා: කසුන් පෙරේරා' : 'e.g., Jane Smith',
                                      hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.6), fontSize: 14),
                                      prefixIcon: Icon(Icons.person_outline_rounded, color: subtitleColor, size: 20),
                                      filled: true,
                                      fillColor: (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.55)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: textColor, width: 1.5),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return isSi ? 'කරුණාකර ඔබගේ නම ඇතුළත් කරන්න' : 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Email Field
                                Text(
                                  isSi ? 'විද්‍යුත් තැපෑල (Email)' : 'Email Address',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(fontSize: 15, color: textColor),
                                  decoration: InputDecoration(
                                    hintText: _isSignUp ? 'your@email.com' : (isSi ? 'ඔබගේ Email ලිපිනය' : 'Enter your email'),
                                    hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.6), fontSize: 14),
                                    prefixIcon: Icon(Icons.mail_outline_rounded, color: subtitleColor, size: 20),
                                    filled: true,
                                    fillColor: (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.55)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: textColor, width: 1.5),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                      return isSi ? 'වලංගු Email ලිපිනයක් ඇතුළත් කරන්න' : 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Password Field
                                Text(
                                  isSi ? 'මුරපදය (Password)' : 'Password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(fontSize: 15, color: textColor),
                                  decoration: InputDecoration(
                                    hintText: _isSignUp ? '••••••••' : (isSi ? 'මුරපදය ඇතුළත් කරන්න' : 'Enter your password'),
                                    hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.6), fontSize: 14),
                                    prefixIcon: Icon(Icons.lock_outline_rounded, color: subtitleColor, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: subtitleColor,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                    filled: true,
                                    fillColor: (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.55)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: textColor, width: 1.5),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.length < 4) {
                                      return isSi ? 'මුරපදය සඳහා අවම වශයෙන් අකුරු 4ක් අවශ්‍යයි' : 'Password must be at least 4 characters';
                                    }
                                    return null;
                                  },
                                ),

                                // Integrated AI Sleep & Sound Questionnaire (Only on Sign-up)
                                if (_isSignUp) ...[
                                  const SizedBox(height: 18),
                                  _buildAIQuestionnaireSection(isDark, textColor, subtitleColor, isSi),
                                ],

                                const SizedBox(height: 24),

                                // Submit Button
                                ScaleButton(
                                  onTap: _isLoading ? null : _submitAuthForm,
                                  child: Container(
                                    width: double.infinity,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF0C4648),
                                          const Color(0xFF165C5F),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 1.2,
                                      ),
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
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                if (_isSignUp) ...[
                                                  const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
                                                  const SizedBox(width: 8),
                                                ],
                                                Text(
                                                  _isSignUp
                                                      ? (isSi ? 'ගිණුම සාදා AI ශබ්දය සකසන්න' : 'Create & Generate Sound')
                                                      : (isSi ? 'පිවිසෙන්න' : 'Sign In'),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

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
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                              _errorMessage = null;
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

                    const SizedBox(height: 16),

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
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                                    fontSize: 14,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive Frosted Glass Questionnaire embedded inside Sign-up form
  Widget _buildAIQuestionnaireSection(bool isDark, Color textColor, Color subtitleColor, bool isSi) {
    final accentColor = isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: isDark ? 0.06 : 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSi ? 'AI ශබ්ද පැතිකඩ සැකසුම' : 'AI Sound Personalization',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isSi
                ? 'ඔබගේ අවශ්‍යතාවය අනුව ගිණුම සාදන විටම AI මඟින් සුවිශේෂී ශබ්දයක් නිර්මාණය කෙරේ.'
                : 'Answer 3 quick preferences so AI can formulate your bespoke soundscape upon sign-up.',
            style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.3),
          ),

          const SizedBox(height: 14),

          // Question 1: Sleep Challenge
          Text(
            isSi ? '1. ඔබගේ ප්‍රධාන නින්දේ අවශ්‍යතාවය:' : '1. What is your primary sleep goal?',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSelectChip(
                label: isSi ? 'නින්ද නොයාම' : 'Insomnia',
                emoji: '🌙',
                isSelected: _selectedMood == UserMoodState.insomnia,
                onTap: () => setState(() => _selectedMood = UserMoodState.insomnia),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'ආතතිය / සිතුවිලි' : 'Racing Thoughts',
                emoji: '🧠',
                isSelected: _selectedMood == UserMoodState.stressed,
                onTap: () => setState(() => _selectedMood = UserMoodState.stressed),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'බාහිර ශබ්ද' : 'Light Sleeper',
                emoji: '🔊',
                isSelected: _selectedMood == UserMoodState.lightSleeper,
                onTap: () => setState(() => _selectedMood = UserMoodState.lightSleeper),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'සන්සුන් විවේකය' : 'Wind Down',
                emoji: '📖',
                isSelected: _selectedMood == UserMoodState.windDown,
                onTap: () => setState(() => _selectedMood = UserMoodState.windDown),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'තෙහෙට්ටුව' : 'Fatigue',
                emoji: '🥱',
                isSelected: _selectedMood == UserMoodState.exhausted,
                onTap: () => setState(() => _selectedMood = UserMoodState.exhausted),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Question 2: Nature Ambience Preference
          Text(
            isSi ? '2. වඩාත් සන්සුන් වන ජල පරිසරය:' : '2. Preferred acoustic water environment:',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSelectChip(
                label: isSi ? 'සාගර රළ' : 'Ocean Waves',
                emoji: '🌊',
                isSelected: _selectedEnvironment == 'ocean',
                onTap: () => setState(() => _selectedEnvironment = 'ocean'),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'මෘදු වැස්ස' : 'Soft Rain',
                emoji: '🌧️',
                isSelected: _selectedEnvironment == 'rainfall',
                onTap: () => setState(() => _selectedEnvironment = 'rainfall'),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'දිය ඇල්ල' : 'Waterfall',
                emoji: '💧',
                isSelected: _selectedEnvironment == 'waterfall',
                onTap: () => setState(() => _selectedEnvironment = 'waterfall'),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'වන ලැහැබ' : 'Forest Breeze',
                emoji: '🌲',
                isSelected: _selectedEnvironment == 'forest',
                onTap: () => setState(() => _selectedEnvironment = 'forest'),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'ගැඹුරු නාද' : 'Brown Noise',
                emoji: '🌌',
                isSelected: _selectedEnvironment == 'brown_noise',
                onTap: () => setState(() => _selectedEnvironment = 'brown_noise'),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Question 3: Sound Depth
          Text(
            isSi ? '3. ශබ්දයේ ගැඹුර සහ තීව්‍රතාව:' : '3. Desired sound depth & texture:',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSelectChip(
                label: isSi ? 'මෘදු' : 'Gentle & Soft',
                emoji: '🌿',
                isSelected: _selectedDepth == 'soft',
                onTap: () => setState(() => _selectedDepth = 'soft'),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'සමබර' : 'Balanced',
                emoji: '🌊',
                isSelected: _selectedDepth == 'balanced',
                onTap: () => setState(() => _selectedDepth = 'balanced'),
                isDark: isDark,
              ),
              _buildSelectChip(
                label: isSi ? 'ගැඹුරු ආවරණය' : 'Deep Masking',
                emoji: '🔊',
                isSelected: _selectedDepth == 'deep',
                onTap: () => setState(() => _selectedDepth = 'deep'),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeTeal = isDark ? const Color(0xFF70D6CE) : const Color(0xFF00897B);

    return ScaleButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeTeal.withValues(alpha: 0.18)
              : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeTeal
                : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? activeTeal
                    : (isDark ? Colors.white70 : const Color(0xFF4D6D6F)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);

      if (_isSignUp) {
        await authNotifier.signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

        // 1. Generate customized AI sound recommendation
        final recommendation = AISoundRecommender.recommendSound(mood: _selectedMood);

        // 2. Map preferred sound asset
        final defaultTracks = SoundTrack.defaultTracks;
        final selectedTrack = defaultTracks.firstWhere(
          (t) => t.id == _selectedEnvironment,
          orElse: () => recommendation.primaryTrack,
        );

        String titleSuffix;
        if (_selectedEnvironment == 'ocean') {
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

        final bespokeTitle = 'Bespoke $titleSuffix';
        final bespokeId = 'ai_bespoke_${DateTime.now().millisecondsSinceEpoch}';

        final bespokeTrack = SoundTrack(
          id: bespokeId,
          title: bespokeTitle,
          description: '${recommendation.aiReasoning} Formulated with $_selectedDepth acoustic depth for ${_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "you"}.',
          assetPath: selectedTrack.assetPath,
          icon: selectedTrack.icon,
          category: 'AI Personalized',
        );

        // 3. Save to custom sound repository and set as active default
        await ref.read(customSoundProvider.notifier).saveCustomSound(bespokeTrack);
        await ref.read(settingsProvider.notifier).setLastUsedSoundId(bespokeTrack.id);

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
}
