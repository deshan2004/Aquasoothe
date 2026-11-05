import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../models/sound_model.dart';
import '../providers/custom_sound_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';
import 'scale_button.dart';

/// Shows the bottom modal sheet to add custom sounds from phone files or web link
void showAddCustomSoundSheet(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => const AddCustomSoundSheet(),
  );
}

class AddCustomSoundSheet extends ConsumerStatefulWidget {
  const AddCustomSoundSheet({super.key});

  @override
  ConsumerState<AddCustomSoundSheet> createState() => _AddCustomSoundSheetState();
}

class _AddCustomSoundSheetState extends ConsumerState<AddCustomSoundSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isLoading = false;
  String? _statusMessage;
  int _selectedTabIndex = 0; // 0 = Phone File Browser, 1 = Web Browser Link

  IconData _selectedIcon = Icons.music_note_rounded;
  final AudioPlayer _previewPlayer = AudioPlayer();
  bool _isPreviewPlaying = false;

  final List<IconData> _iconChoices = [
    Icons.music_note_rounded,
    Icons.grain_rounded,
    Icons.waves_rounded,
    Icons.water_rounded,
    Icons.park_rounded,
    Icons.nightlight_round,
    Icons.spa_rounded,
    Icons.favorite_rounded,
    Icons.volume_up_rounded,
    Icons.graphic_eq_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _previewPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPreviewPlaying = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  /// 1. Pick audio file from phone's file browser / storage
  Future<void> _pickAudioFileFromPhone() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'],
      );

      if (files.isNotEmpty && files.first.path != null) {
        final rawFile = File(files.first.path!);
        final rawName = files.first.name;
        final sizeBytes = await rawFile.length();

        // Generate clean title from filename
        final cleanTitle = rawName
            .replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')
            .replaceAll(RegExp(r'[-_]'), ' ')
            .trim();

        if (_titleController.text.trim().isEmpty) {
          _titleController.text = cleanTitle;
        }

        setState(() {
          _selectedFile = rawFile;
          _selectedFileName = rawName;
          _selectedFileSize = sizeBytes;
        });

        // Load preview
        try {
          await _previewPlayer.stop();
          await _previewPlayer.setFilePath(rawFile.path);
        } catch (e) {
          debugPrint('Preview load note: $e');
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Could not access file: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 2. Download audio file from web browser link
  Future<void> _downloadFromWebLink() async {
    final url = _urlController.text.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      setState(() {
        _statusMessage = 'Please enter a valid HTTP or HTTPS audio URL.';
      });
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _statusMessage = 'Downloading audio from web...';
    });

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 25));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final docsDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Derive extension
        String ext = 'mp3';
        if (url.toLowerCase().contains('.wav')) ext = 'wav';
        if (url.toLowerCase().contains('.m4a')) ext = 'm4a';

        final savedFile = File('${docsDir.path}/web_audio_$timestamp.$ext');
        await savedFile.writeAsBytes(response.bodyBytes);

        final guessedTitle = url.split('/').last.split('?').first
            .replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')
            .replaceAll(RegExp(r'[-_]'), ' ')
            .trim();

        if (_titleController.text.trim().isEmpty) {
          _titleController.text = guessedTitle.isNotEmpty ? guessedTitle : 'Web Soundscape';
        }

        setState(() {
          _selectedFile = savedFile;
          _selectedFileName = 'web_audio_$timestamp.$ext';
          _selectedFileSize = response.bodyBytes.length;
          _statusMessage = 'Audio downloaded successfully!';
        });

        try {
          await _previewPlayer.stop();
          await _previewPlayer.setFilePath(savedFile.path);
        } catch (_) {}
      } else {
        setState(() {
          _statusMessage = 'Failed to download (HTTP ${response.statusCode}). Check URL.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error downloading: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Toggle preview playback
  Future<void> _togglePreview() async {
    if (_selectedFile == null) return;
    HapticFeedback.selectionClick();
    if (_isPreviewPlaying) {
      await _previewPlayer.pause();
    } else {
      await _previewPlayer.play();
    }
  }

  /// Finalize and save the custom sound
  Future<void> _saveAndAddSound() async {
    if (_selectedFile == null) {
      setState(() {
        _statusMessage = 'Please pick a sound file first.';
      });
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a name for your sound.';
      });
      return;
    }

    setState(() => _isLoading = true);
    await _previewPlayer.stop();

    try {
      // Copy to persistent documents directory so it is never deleted by the OS
      final docsDir = await getApplicationDocumentsDirectory();
      final customDir = Directory('${docsDir.path}/custom_sounds');
      if (!await customDir.exists()) {
        await customDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = _selectedFileName?.split('.').last ?? 'mp3';
      final persistentPath = '${customDir.path}/sound_$timestamp.$fileExt';
      await _selectedFile!.copy(persistentPath);

      final newTrack = SoundTrack(
        id: 'user_sound_$timestamp',
        title: title,
        description: 'Imported audio file (${(_selectedFileSize ?? 0) ~/ 1024} KB)',
        assetPath: persistentPath,
        icon: _selectedIcon,
        category: 'User Custom',
      );

      // Save to Riverpod provider & LocalStorage/Firestore
      await ref.read(customSoundProvider.notifier).saveCustomSound(newTrack);

      // Auto-select and play in audio player
      final audioNotifier = ref.read(audioServiceProvider);
      await audioNotifier.selectTrack(newTrack);
      await audioNotifier.play();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0C4648),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF5ED1C7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"$title" added to your sound library and playing now!',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error saving sound: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTeal = const Color(0xFF0C4648);
    final accentTeal = isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648);
    final goldAmber = const Color(0xFFFFAE85);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.90),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2226) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: goldAmber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.add_to_photos_rounded, color: goldAmber, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSi ? 'දුරකථනයෙන් ශබ්දයක් එකතු කරන්න' : 'Add Sound from Phone',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : primaryTeal,
                            ),
                          ),
                          Text(
                            isSi
                                ? 'MP3, WAV ශබ්ද හෝ Web Link මගින් එක්කරන්න'
                                : 'Select audio from your files, downloads, or web',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),

              // Scrollable Content Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode Selector (Phone Files vs Web Link)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ScaleButton(
                                onTap: () => setState(() => _selectedTabIndex = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedTabIndex == 0
                                        ? (_selectedTabIndex == 0 ? (isDark ? const Color(0xFF1E3A40) : Colors.white) : Colors.transparent)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: _selectedTabIndex == 0
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_open_rounded,
                                        size: 18,
                                        color: _selectedTabIndex == 0 ? accentTeal : (isDark ? Colors.white60 : Colors.black54),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isSi ? 'දුරකථනයේ Files' : 'Phone Storage',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _selectedTabIndex == 0 ? (isDark ? Colors.white : primaryTeal) : (isDark ? Colors.white60 : Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ScaleButton(
                                onTap: () => setState(() => _selectedTabIndex = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedTabIndex == 1
                                        ? (isDark ? const Color(0xFF1E3A40) : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: _selectedTabIndex == 1
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.language_rounded,
                                        size: 18,
                                        color: _selectedTabIndex == 1 ? accentTeal : (isDark ? Colors.white60 : Colors.black54),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isSi ? 'Web Browser Link' : 'Web Audio Link',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _selectedTabIndex == 1 ? (isDark ? Colors.white : primaryTeal) : (isDark ? Colors.white60 : Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tab 0: Phone File Browser
                      if (_selectedTabIndex == 0) ...[
                        ScaleButton(
                          onTap: _pickAudioFileFromPhone,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                              color: (isDark ? const Color(0xFF163238) : const Color(0xFFE8F6F4)).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: (isDark ? const Color(0xFF5ED1C7) : primaryTeal).withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : primaryTeal).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.file_upload_outlined,
                                    size: 32,
                                    color: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isSi ? 'දුරකථනයෙන් ශබ්දය තෝරන්න' : 'Browse Phone Files / Downloads',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : primaryTeal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isSi ? 'MP3, WAV, M4A, AAC, OGG' : 'Supports MP3, WAV, M4A, AAC, OGG',
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Tab 1: Web Link Input
                      if (_selectedTabIndex == 1) ...[
                        Text(
                          isSi ? 'Online Audio Link එකක් ඇතුළත් කරන්න:' : 'Paste direct Web Audio URL:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _urlController,
                                decoration: InputDecoration(
                                  hintText: 'https://example.com/sound.mp3',
                                  hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white30 : Colors.black38),
                                  filled: true,
                                  fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ScaleButton(
                              onTap: _downloadFromWebLink,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  isSi ? 'බාගන්න' : 'Load',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF0C4648) : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Status or Error Message
                      if (_statusMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _statusMessage!,
                                  style: const TextStyle(fontSize: 12.5, color: Colors.amber),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Selected File Details & Preview Box
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFF1E3A40) : const Color(0xFFDDF2EE)).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF5ED1C7).withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: goldAmber.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(_selectedIcon, color: goldAmber, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFileName ?? 'Custom Audio',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark ? Colors.white : primaryTeal,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedFileSize != null
                                          ? '${(_selectedFileSize! / (1024 * 1024)).toStringAsFixed(1)} MB • Ready to save'
                                          : 'Ready to save',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Preview Play Button
                              ScaleButton(
                                onTap: _togglePreview,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF5ED1C7) : primaryTeal,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isPreviewPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: isDark ? const Color(0xFF0C4648) : Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Sound Name Text Field
                        Text(
                          isSi ? 'ශබ්දයේ නම (Title):' : 'Sound Title:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: isSi ? 'උදා: මගේ ප්‍රියතම වැස්ස' : 'e.g. My Favorite Rain',
                            hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white30 : Colors.black38),
                            filled: true,
                            fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Choose an Icon
                        Text(
                          isSi ? 'අයිකනයක් තෝරන්න:' : 'Choose an Icon:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _iconChoices.map((icon) {
                              final isSelected = _selectedIcon == icon;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ScaleButton(
                                  onTap: () => setState(() => _selectedIcon = icon),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark ? const Color(0xFF5ED1C7) : primaryTeal)
                                          : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.8)
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      icon,
                                      size: 20,
                                      color: isSelected
                                          ? (isDark ? const Color(0xFF0C4648) : Colors.white)
                                          : (isDark ? Colors.white70 : Colors.black54),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Submit / Save Button
                      ScaleButton(
                        onTap: _isLoading ? null : _saveAndAddSound,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryTeal, const Color(0xFF1A5A5C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: primaryTeal.withValues(alpha: 0.35),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        isSi ? 'ශබ්දය සුරකින්න (Save Sound)' : 'Save & Play in AquaSoothe',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
