import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_model.dart';
import '../providers/custom_sound_provider.dart';
import '../providers/audio_provider.dart';
import '../services/ai_sound_generator_service.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/scale_button.dart';
import '../widgets/glass_card.dart';

class AISoundGeneratorScreen extends ConsumerStatefulWidget {
  const AISoundGeneratorScreen({super.key});

  @override
  ConsumerState<AISoundGeneratorScreen> createState() => _AISoundGeneratorScreenState();
}

class _AISoundGeneratorScreenState extends ConsumerState<AISoundGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  SoundTrack? _generatedSound;
  bool _isSaved = false;

  final List<String> _samplePrompts = [
    'Soft rain falling on a roof with night crickets',
    'Gentle ocean waves with warm pink noise',
    'Cascading waterfall roar with brown noise',
    'Whispering forest breeze with soft summer rain',
    'Deep thunder rumble with continuous rain',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioNotifier = ref.watch(audioServiceProvider);
    final isPlaying = _generatedSound != null &&
        audioNotifier.isPlaying &&
        audioNotifier.currentTrack.id == _generatedSound!.id;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ScaleButton(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.12),
              ),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textColor),
          ),
        ),
        title: Text(
          'AI Sound Studio',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Ambient Background Aura Blobs
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.25 : 0.2),
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
                color: const Color(0xFF0C4648).withValues(alpha: isDark ? 0.3 : 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
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
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Glassmorphic Gradient Header Banner
                  GlassCard(
                    borderRadius: 24,
                    blur: 18,
                    padding: const EdgeInsets.all(22),
                    margin: EdgeInsets.zero,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0284C7).withValues(alpha: isDark ? 0.85 : 0.9),
                        const Color(0xFF0369A1).withValues(alpha: isDark ? 0.92 : 0.96),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderColor: Colors.white.withValues(alpha: 0.4),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Soundscape Synthesis',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Describe your dream acoustic environment. Neural DSP & AI synthesize it instantly.',
                                style: TextStyle(fontSize: 14, color: Color(0xFFE0F2FE), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Prompt Input Frosted Glass Container
                  Text(
                    'Describe Sleep Atmosphere',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GlassCard(
                    borderRadius: 20,
                    blur: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: EdgeInsets.zero,
                    child: TextField(
                      controller: _promptController,
                      maxLines: 3,
                      style: TextStyle(fontSize: 16, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'e.g. Soft rain falling on a roof with night crickets and gentle ocean waves...',
                        hintStyle: TextStyle(fontSize: 15, color: subtitleColor.withValues(alpha: 0.7)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Sample Prompts Chips
                  Text(
                    'Inspiring Presets',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _samplePrompts.map((prompt) {
                      return ScaleButton(
                        onTap: () {
                          setState(() {
                            _promptController.text = prompt;
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.tips_and_updates_rounded, size: 15, color: Color(0xFF0284C7)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      prompt,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Synthesize Interactive Gradient Button
                  ScaleButton(
                    onTap: _isGenerating ? null : _generateAISound,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                _isGenerating ? 'Synthesizing Soundscape...' : 'Generate AI Soundscape',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Synthesis Result / Progress Card
                  if (_isGenerating)
                    GlassCard(
                      borderRadius: 24,
                      blur: 18,
                      padding: const EdgeInsets.all(24),
                      margin: EdgeInsets.zero,
                      child: Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF0284C7)),
                            const SizedBox(height: 16),
                            Text(
                              'Synthesizing Audio Frequency Spectrum...',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Generating seamless 44.1kHz audio loop on your device',
                              style: TextStyle(fontSize: 13, color: subtitleColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_generatedSound != null) ...[
                    GlassCard(
                      borderRadius: 24,
                      blur: 18,
                      padding: const EdgeInsets.all(20),
                      margin: EdgeInsets.zero,
                      borderColor: const Color(0xFF0284C7).withValues(alpha: 0.6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Icon(_generatedSound!.icon, size: 26, color: const Color(0xFF0284C7)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AI Soundscape Synthesized!',
                                      style: TextStyle(fontSize: 13, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _generatedSound!.title,
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                                    ),
                                  ],
                                ),
                              ),
                              AudioVisualizer(isPlaying: isPlaying, height: 26),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            _generatedSound!.description,
                            style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.3),
                          ),

                          const SizedBox(height: 18),

                          // Controls Row: Play & Save
                          Row(
                            children: [
                              Expanded(
                                child: ScaleButton(
                                  onTap: () async {
                                    if (isPlaying) {
                                      await audioNotifier.pause();
                                    } else {
                                      await audioNotifier.selectTrack(_generatedSound!);
                                      await audioNotifier.play();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isPlaying
                                          ? const Color(0xFFF8AB80)
                                          : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFEFF8F6)),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isPlaying
                                            ? Colors.white.withValues(alpha: 0.6)
                                            : (isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFF0C4648).withValues(alpha: 0.2)),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          color: isPlaying ? const Color(0xFF4D2411) : textColor,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isPlaying ? 'Pause' : 'Preview',
                                          style: TextStyle(
                                            color: isPlaying ? const Color(0xFF4D2411) : textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ScaleButton(
                                  onTap: _isSaved
                                      ? null
                                      : () async {
                                          final messenger = ScaffoldMessenger.of(context);
                                          await ref.read(customSoundProvider.notifier).saveCustomSound(_generatedSound!);
                                          if (!mounted) return;
                                          setState(() => _isSaved = true);
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text('Saved to "My Custom AI Sounds" library!', style: TextStyle(fontSize: 16)),
                                              backgroundColor: Color(0xFF16A34A),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: _isSaved ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isSaved ? const Color(0xFF16A34A) : const Color(0xFF0284C7)).withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isSaved ? Icons.check_circle_rounded : Icons.bookmark_add_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _isSaved ? 'Saved!' : 'Save Sound',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAISound() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description or tap an inspiring preset!', style: TextStyle(fontSize: 16)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedSound = null;
      _isSaved = false;
    });

    try {
      final newSound = await AISoundGeneratorService.generateSoundFromPrompt(prompt);
      if (mounted) {
        setState(() {
          _generatedSound = newSound;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generation error: $e', style: const TextStyle(fontSize: 16)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}
