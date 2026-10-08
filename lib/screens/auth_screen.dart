import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Icon Badge
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F2F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _isSignUp ? Icons.water_drop_rounded : Icons.waves_rounded,
                        size: 36,
                        color: const Color(0xFF0C4648),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Form Container (White Card in Sign Up mode)
                Container(
                  width: double.infinity,
                  padding: _isSignUp ? const EdgeInsets.all(24.0) : EdgeInsets.zero,
                  decoration: _isSignUp
                      ? BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0C4648).withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : null,
                  child: Column(
                    children: [
                      // Heading
                      Text(
                        _isSignUp ? 'Begin Your Journey' : 'Welcome Back',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C4648),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        _isSignUp
                            ? 'Step into a more mindful rhythm.'
                            : 'Sign in to continue your restorative journey with AquaSoothe.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF5B787A),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 28),

                      if (_errorMessage != null) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade800, fontSize: 14, fontWeight: FontWeight.w600),
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
                              const Text(
                                'Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0C4648),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'e.g., Jane Smith',
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                  prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                                  filled: true,
                                  fillColor: _isSignUp ? const Color(0xFFF8FAF9) : Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFD0E5E2)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFD0E5E2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFF0C4648), width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email Field
                            const Text(
                              'Email Address',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0C4648),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: _isSignUp ? 'your@email.com' : 'Enter your email',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                                filled: true,
                                fillColor: _isSignUp ? const Color(0xFFF8FAF9) : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFD0E5E2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFD0E5E2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFF0C4648), width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Password Field
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0C4648),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: _isSignUp ? '........' : 'Enter your password',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                                filled: true,
                                fillColor: _isSignUp ? const Color(0xFFF8FAF9) : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFD0E5E2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFD0E5E2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFF0C4648), width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 4) {
                                  return 'Password must be at least 4 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0C4648),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _submitAuthForm,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _isSignUp ? 'Create Account' : 'Sign In',
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (_isSignUp) ...[
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward_rounded, size: 20),
                                          ],
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (!_isSignUp) ...[
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset instructions sent to your email.'),
                          backgroundColor: Color(0xFF0C4648),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C4648),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Footer Switcher Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp ? 'Already have an account?' : 'New to AquaSoothe?',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5B787A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isSignUp ? 'Sign In' : 'Create Account',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C4648),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Guest Login
                TextButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await ref.read(authProvider.notifier).loginAsGuest();
                    if (!mounted) return;
                    navigator.pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    );
                  },
                  icon: const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF5B787A)),
                  label: const Text(
                    'Continue as Guest',
                    style: TextStyle(color: Color(0xFF5B787A), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
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
      final navigator = Navigator.of(context);

      if (_isSignUp) {
        await authNotifier.signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await authNotifier.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
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
