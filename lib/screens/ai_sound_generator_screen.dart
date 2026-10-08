import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_model.dart';
import '../providers/custom_sound_provider.dart';
import '../providers/audio_provider.dart';
import '../services/ai_sound_generator_service.dart';
import '../widgets/audio_visualizer.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Generative Sound Studio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF006687), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prompt Your AI Soundscape',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Describe your dream sleep environment and AI will synthesize it for you!',
                          style: TextStyle(fontSize: 15, color: Color(0xFFE0F2FE)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Prompt Input Area
            const Text(
              'Enter Prompt Description:',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _promptController,
              maxLines: 3,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'e.g. Soft rain falling on a roof with night crickets and gentle ocean waves...',
                hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),

            const SizedBox(height: 16),

            // Sample Prompts Chips
            const Text(
              'Try Sample Prompts:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _samplePrompts.map((prompt) {
                return ActionChip(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  avatar: const Icon(Icons.tips_and_updates_rounded, size: 18, color: Color(0xFF006687)),
                  label: Text(prompt, style: const TextStyle(fontSize: 14)),
                  backgroundColor: const Color(0xFFF0F9FF),
                  side: const BorderSide(color: Color(0xFF0284C7)),
                  onPressed: () {
                    setState(() {
                      _promptController.text = prompt;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Generate Action Button
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateAISound,
              icon: const Icon(Icons.auto_awesome_rounded, size: 28),
              label: Text(_isGenerating ? 'Synthesizing Soundscape...' : 'Generate AI Soundscape'),
            ),

            const SizedBox(height: 28),

            // AI Synthesis Result Card
            if (_isGenerating)
              const ContainerProgressCard()
            else if (_generatedSound != null) ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF006687), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF006687),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_generatedSound!.icon, size: 30, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI Soundscape Generated!',
                                style: TextStyle(fontSize: 15, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _generatedSound!.title,
                                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                              ),
                            ],
                          ),
                        ),
                        AudioVisualizer(isPlaying: isPlaying, height: 30),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _generatedSound!.description,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF475569)),
                    ),

                    const SizedBox(height: 20),

                    // Controls Row: Play & Save
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isPlaying ? Colors.orange.shade800 : Colors.white,
                              foregroundColor: isPlaying ? Colors.white : const Color(0xFF006687),
                            ),
                            onPressed: () async {
                              if (isPlaying) {
                                await audioNotifier.pause();
                              } else {
                                await audioNotifier.selectTrack(_generatedSound!);
                                await audioNotifier.play();
                              }
                            },
                            icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28),
                            label: Text(isPlaying ? 'Pause' : 'Preview'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSaved ? const Color(0xFF15803D) : const Color(0xFF006687),
                            ),
                            onPressed: _isSaved
                                ? null
                                : () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    await ref.read(customSoundProvider.notifier).saveCustomSound(_generatedSound!);
                                    if (!mounted) return;
                                    setState(() => _isSaved = true);
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Saved to "My Custom AI Sounds" library!', style: TextStyle(fontSize: 18)),
                                        backgroundColor: Color(0xFF15803D),
                                      ),
                                    );
                                  },
                            icon: Icon(_isSaved ? Icons.check_circle_rounded : Icons.bookmark_add_rounded, size: 28),
                            label: Text(_isSaved ? 'Saved!' : 'Save Sound'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateAISound() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description or tap a sample prompt!', style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.orange,
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
          SnackBar(content: Text('Generation error: $e', style: const TextStyle(fontSize: 18))),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}

class ContainerProgressCard extends StatelessWidget {
  const ContainerProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF006687)),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF006687)),
          SizedBox(height: 16),
          Text(
            'Synthesizing Audio Frequency Spectrum...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
          ),
          SizedBox(height: 6),
          Text(
            'Generating seamless 44.1kHz audio loop on your device',
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
