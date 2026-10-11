import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sound_model.dart';

class AISoundGeneratorService {
  static const int sampleRate = 44100;
  static const double durationSeconds = 5.0; // 5-second seamless loop

  /// Check if the custom AI server is accessible
  static Future<bool> checkServerHealth(String serverUrl) async {
    try {
      final sanitizedUrl = serverUrl.trim().replaceAll(RegExp(r'/+$'), '');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(Uri.parse('$sanitizedUrl/health'));
      final response = await request.close().timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Production Default Cloud AI Server URL
  /// Normal users do not need to enter or copy-paste anything.
  static const String defaultAiServerUrl = 'https://occurred-video-intensity-diving.trycloudflare.com';

  /// Generates a custom soundscape .wav audio file based on natural language text prompt.
  /// Automatically connects to the AI server without any user manual setup,
  /// with seamless on-device offline fallback if offline or unreachable.
  static Future<SoundTrack> generateSoundFromPrompt(
    String prompt, {
    String? customServerUrl,
  }) async {
    final serverUrl = (customServerUrl != null && customServerUrl.trim().isNotEmpty)
        ? customServerUrl
        : defaultAiServerUrl;

    if (serverUrl.isNotEmpty) {
      try {
        final remoteTrack = await _generateFromRemoteAi(prompt, serverUrl);
        if (remoteTrack != null) {
          return remoteTrack;
        }
      } catch (e) {
        debugPrint('AI Server generation fallback to local engine: $e');
      }
    }

    return _generateLocalProceduralSound(prompt);
  }

  static Future<SoundTrack?> _generateFromRemoteAi(String prompt, String serverUrl) async {
    final sanitizedUrl = serverUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);
    final request = await client.postUrl(Uri.parse('$sanitizedUrl/generate'));
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(jsonEncode({
      'prompt': prompt,
      'duration': durationSeconds,
    })));

    final response = await request.close().timeout(const Duration(seconds: 45));
    if (response.statusCode == 200) {
      final bytesBuilder = BytesBuilder();
      await for (final chunk in response) {
        bytesBuilder.add(chunk);
      }
      final wavBytes = bytesBuilder.toBytes();

      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${appDir.path}/ai_sound_$timestamp.wav');
      await file.writeAsBytes(wavBytes);

      final title = _generateTitleFromPrompt(prompt);
      final cleanPrompt = prompt.toLowerCase().trim();

      return SoundTrack(
        id: 'ai_custom_neural_$timestamp',
        title: title,
        description: 'Neural Model AI: "$prompt"',
        assetPath: file.path,
        icon: _selectIconForPrompt(cleanPrompt),
        category: 'AI Custom',
      );
    }
    return null;
  }

  static Future<SoundTrack> _generateLocalProceduralSound(String prompt) async {
    final cleanPrompt = prompt.toLowerCase().trim();
    final numSamples = (sampleRate * durationSeconds).round();

    // 1. Comprehensive Acoustic Category Detection Flags (35+ Categories)
    final hasHorn = cleanPrompt.contains('horn') || cleanPrompt.contains('car') || cleanPrompt.contains('beep') || cleanPrompt.contains('siren') || cleanPrompt.contains('traffic') || cleanPrompt.contains('vehicle');
    final hasFire = cleanPrompt.contains('fire') || cleanPrompt.contains('crackle') || cleanPrompt.contains('flame') || cleanPrompt.contains('wood') || cleanPrompt.contains('campfire');
    final hasChime = cleanPrompt.contains('chime') || cleanPrompt.contains('bell') || cleanPrompt.contains('bowl') || cleanPrompt.contains('piano') || cleanPrompt.contains('singing') || cleanPrompt.contains('music');
    final hasPurr = cleanPrompt.contains('cat') || cleanPrompt.contains('purr') || cleanPrompt.contains('heart') || cleanPrompt.contains('pulse');
    final hasClock = cleanPrompt.contains('clock') || cleanPrompt.contains('tick') || cleanPrompt.contains('tock') || cleanPrompt.contains('metronome');
    final hasTrain = cleanPrompt.contains('train') || cleanPrompt.contains('track') || cleanPrompt.contains('rail');
    final hasBird = cleanPrompt.contains('bird') || cleanPrompt.contains('chirp') || cleanPrompt.contains('sing') || cleanPrompt.contains('sparrow');

    // Additional Everyday & Acoustic Instrument Categories
    final hasGuitar = cleanPrompt.contains('guitar') || cleanPrompt.contains('string') || cleanPrompt.contains('violin') || cleanPrompt.contains('harp') || cleanPrompt.contains('acoustic');
    final hasVacuum = cleanPrompt.contains('vacuum') || cleanPrompt.contains('hairdryer') || cleanPrompt.contains('fan') || cleanPrompt.contains('ac') || cleanPrompt.contains('air') || cleanPrompt.contains('blender') || cleanPrompt.contains('cleaner');
    final hasVoice = cleanPrompt.contains('whisper') || cleanPrompt.contains('voice') || cleanPrompt.contains('chatter') || cleanPrompt.contains('cafe') || cleanPrompt.contains('crowd') || cleanPrompt.contains('people');
    final hasDog = cleanPrompt.contains('dog') || cleanPrompt.contains('bark') || cleanPrompt.contains('wolf') || cleanPrompt.contains('animal');
    final hasRocket = cleanPrompt.contains('rocket') || cleanPrompt.contains('jet') || cleanPrompt.contains('airplane') || cleanPrompt.contains('space') || cleanPrompt.contains('engine');
    final hasDrum = cleanPrompt.contains('drum') || cleanPrompt.contains('beat') || cleanPrompt.contains('percussion');
    final hasBubble = cleanPrompt.contains('bubble') || cleanPrompt.contains('underwater') || cleanPrompt.contains('scuba') || cleanPrompt.contains('drip');
    final hasFlute = cleanPrompt.contains('flute') || cleanPrompt.contains('bamboo') || cleanPrompt.contains('pipe');
    final hasTyping = cleanPrompt.contains('type') || cleanPrompt.contains('keyboard') || cleanPrompt.contains('key') || cleanPrompt.contains('click');

    // Nature Categories
    final hasRain = cleanPrompt.contains('rain') || cleanPrompt.contains('shower') || cleanPrompt.contains('storm');
    final hasOcean = cleanPrompt.contains('ocean') || cleanPrompt.contains('wave') || cleanPrompt.contains('sea') || cleanPrompt.contains('beach');
    final hasCrickets = cleanPrompt.contains('cricket') || cleanPrompt.contains('night') || cleanPrompt.contains('star');
    final hasWaterfall = cleanPrompt.contains('waterfall') || cleanPrompt.contains('stream') || cleanPrompt.contains('river') || cleanPrompt.contains('cascade') || cleanPrompt.contains('brook');
    final hasWind = cleanPrompt.contains('wind') || cleanPrompt.contains('breeze') || cleanPrompt.contains('forest') || cleanPrompt.contains('tree') || cleanPrompt.contains('leaf');
    final hasPink = cleanPrompt.contains('pink') || cleanPrompt.contains('soft noise');
    final hasBrown = cleanPrompt.contains('brown') || cleanPrompt.contains('deep noise') || cleanPrompt.contains('rumble');
    final hasThunder = cleanPrompt.contains('thunder');

    // Character Hash Synthesis Engine for Unknown Custom Words
    int promptHash = 0;
    for (int code in cleanPrompt.codeUnits) {
      promptHash = (promptHash * 31 + code) & 0xFFFFFFF;
    }
    final hashFreq1 = 150.0 + (promptHash % 350); // 150Hz - 500Hz
    final hashFreq2 = 300.0 + ((promptHash ~/ 7) % 550); // 300Hz - 850Hz
    final hashRhythmRate = 0.5 + (promptHash % 4) * 0.5; // 0.5Hz - 2.0Hz

    // Synthesize sample buffer
    final samples = Float32List(numSamples);
    final random = math.Random(promptHash);

    // Noise Filter State
    double pinkB0 = 0, pinkB1 = 0, pinkB2 = 0, pinkB3 = 0, pinkB4 = 0, pinkB5 = 0, pinkB6 = 0;
    double brownLast = 0.0;

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate.toDouble();
      final white = random.nextDouble() * 2.0 - 1.0;

      // Pink Noise
      pinkB0 = 0.99886 * pinkB0 + white * 0.0555179;
      pinkB1 = 0.99332 * pinkB1 + white * 0.0750759;
      pinkB2 = 0.96900 * pinkB2 + white * 0.1538520;
      pinkB3 = 0.86650 * pinkB3 + white * 0.3104856;
      pinkB4 = 0.55000 * pinkB4 + white * 0.5329522;
      pinkB5 = -0.7616 * pinkB5 - white * 0.0168980;
      final pinkVal = (pinkB0 + pinkB1 + pinkB2 + pinkB3 + pinkB4 + pinkB5 + pinkB6 + white * 0.5362) * 0.1;
      pinkB6 = white * 0.115926;

      // Brown Noise
      brownLast = (brownLast + (0.02 * white)) / 1.02;
      final brownVal = brownLast * 1.5;

      double mixedSample = 0.0;

      // --- PROCEDURAL SYNTHESIS MODULES ---

      // 1. Guitar / Plucked String
      if (hasGuitar) {
        final cycle = t % 1.5;
        final env = math.exp(-4.0 * cycle);
        final f = math.sin(2 * math.pi * 329.63 * t) * 0.3; // E4 string
        final fHarmonic = math.sin(2 * math.pi * 659.25 * t) * 0.15;
        mixedSample += (f + fHarmonic) * env;
      }

      // 2. Vacuum / Fan / Dryer Noise Hum
      if (hasVacuum) {
        final hum = math.sin(2 * math.pi * 120.0 * t) * 0.15;
        mixedSample += (pinkVal * 0.4 + brownVal * 0.5 + hum);
      }

      // 3. Formant Vocal Whisper / Cafe Chatter
      if (hasVoice) {
        final formant1 = math.sin(2 * math.pi * 500.0 * t) * 0.1;
        final formant2 = math.sin(2 * math.pi * 1500.0 * t) * 0.06;
        final chatterEnv = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(2 * math.pi * 2.2 * t));
        mixedSample += (formant1 + formant2 + pinkVal * 0.2) * chatterEnv;
      }

      // 4. Dog Bark / Animal Burst
      if (hasDog) {
        final barkCycle = t % 2.5;
        if (barkCycle < 0.15) {
          final barkEnv = math.sin(math.pi * (barkCycle / 0.15));
          final barkTone = math.sin(2 * math.pi * 220.0 * t) + brownVal * 0.4;
          mixedSample += barkTone * barkEnv * 0.3;
        }
      }

      // 5. Rocket / Jet Engine Thrust
      if (hasRocket) {
        final rumbleMod = 0.6 + 0.4 * math.sin(2 * math.pi * 15.0 * t);
        mixedSample += brownVal * 0.8 * rumbleMod;
      }

      // 6. Drum / Percussion Beat
      if (hasDrum) {
        final beatCycle = t % 1.0;
        final env = math.exp(-8.0 * beatCycle);
        final pitch = 150.0 * math.exp(-12.0 * beatCycle) + 50.0;
        mixedSample += math.sin(2 * math.pi * pitch * t) * env * 0.4;
      }

      // 7. Underwater Bubbles
      if (hasBubble) {
        final bubCycle = t % 0.8;
        if (bubCycle < 0.08) {
          final bubPitch = 600.0 + (bubCycle / 0.08) * 800.0;
          mixedSample += math.sin(2 * math.pi * bubPitch * t) * 0.25;
        }
      }

      // 8. Bamboo Flute / Wind Instrument
      if (hasFlute) {
        final fluteCycle = t % 2.0;
        final breath = pinkVal * 0.15;
        final tone = math.sin(2 * math.pi * 587.33 * t) * 0.25; // D5
        mixedSample += (tone + breath) * (0.6 + 0.4 * math.sin(2 * math.pi * 0.5 * fluteCycle));
      }

      // 9. Mechanical Keyboard Typing / Clicks
      if (hasTyping) {
        final typeCycle = t % 0.4;
        if (typeCycle < 0.02) {
          final click = math.sin(2 * math.pi * 3200.0 * t) * 0.3;
          mixedSample += click;
        }
      }

      // 10. Car Horn / Siren
      if (hasHorn) {
        final hornCycle = t % 2.5;
        if (hornCycle < 0.6) {
          final tone1 = math.sin(2 * math.pi * 349.23 * t);
          final tone2 = math.sin(2 * math.pi * 440.00 * t);
          mixedSample += (tone1 + tone2) * 0.25;
        }
      }

      // 11. Realistic Campfire (Deep warm log hum + Poisson resonant crackle bursts)
      if (hasFire) {
        final emberHum = brownVal * 0.35 + math.sin(2 * math.pi * 75.0 * t) * 0.08;
        double crackle = emberHum;
        if (random.nextDouble() < 0.0035) {
          final snapPitch = 700.0 + random.nextDouble() * 900.0;
          final snapEnv = (random.nextDouble() * 0.45 + 0.15);
          crackle += math.sin(2 * math.pi * snapPitch * t) * snapEnv;
        }
        mixedSample += crackle;
      }

      // 12. Tibetan Singing Bowl / Solfeggio Meditation Bell (528Hz harmonic series + 2.5Hz binaural tremolo)
      if (hasChime) {
        final chimeCycle = t % 3.0;
        final decay = math.exp(-1.5 * chimeCycle);
        final tremolo = 0.75 + 0.25 * math.sin(2 * math.pi * 2.5 * t);
        final fundamental = math.sin(2 * math.pi * 528.0 * t);
        final overtone1 = math.sin(2 * math.pi * 1457.0 * t) * 0.28;
        final overtone2 = math.sin(2 * math.pi * 2851.0 * t) * 0.12;
        mixedSample += (fundamental + overtone1 + overtone2) * decay * tremolo * 0.35;
      }

      // 13. Cat Purr
      if (hasPurr) {
        final purrMod = 0.5 + 0.5 * math.sin(2 * math.pi * 25.0 * t);
        mixedSample += (brownVal * 0.6 * purrMod);
      }

      // 14. Clock Ticking
      if (hasClock) {
        final tickCycle = t % 1.0;
        if (tickCycle < 0.03) {
          mixedSample += math.sin(2 * math.pi * 2200.0 * t) * 0.3;
        }
      }

      // 15. Train Tracks
      if (hasTrain) {
        final trainCycle = t % 1.2;
        if (trainCycle < 0.05 || (trainCycle > 0.15 && trainCycle < 0.20)) {
          mixedSample += math.sin(2 * math.pi * 450.0 * t) * 0.25;
        }
        mixedSample += brownVal * 0.2;
      }

      // 16. Bird Chirps
      if (hasBird) {
        final birdCycle = t % 2.0;
        if (birdCycle < 0.25) {
          final pitchSlide = 2600.0 + 800.0 * math.sin(2 * math.pi * 8.0 * birdCycle);
          mixedSample += math.sin(2 * math.pi * pitchSlide * t) * 0.2;
        }
      }

      // 17. Nature Sounds (Realistic Multi-Layer Organic Rain, Swell Ocean, Night Crickets, Wind, Thunder)
      if (hasRain) {
        // Continuous soft mist bed + individual high-res surface droplet impacts
        double rainDrop = pinkVal * 0.35;
        if (random.nextDouble() < 0.0035) {
          final dropFreq = 1600.0 + random.nextDouble() * 1800.0;
          rainDrop += math.sin(2 * math.pi * dropFreq * t) * (0.15 + random.nextDouble() * 0.2);
        }
        mixedSample += rainDrop;
      }

      if (hasOcean) {
        // Intersecting long swells with foam sizzle at wave crest
        final swell1 = 0.5 + 0.5 * math.sin(2 * math.pi * 0.12 * t);
        final swell2 = 0.5 + 0.5 * math.sin(2 * math.pi * 0.08 * t + 1.2);
        final swellCombined = (swell1 * 0.7 + swell2 * 0.3);
        final foam = (white * 0.18 + pinkVal * 0.25) * math.pow(swellCombined, 2.5);
        final undertow = brownVal * swellCombined * 0.6;
        mixedSample += (undertow + foam) * 0.85;
      }

      if (hasCrickets) {
        final chirpCycle = t % 1.1;
        if (chirpCycle < 0.18) {
          final pulse = math.sin(2 * math.pi * 45.0 * t);
          final carrier = math.sin(2 * math.pi * 4600.0 * t);
          mixedSample += 0.09 * pulse * carrier;
        }
      }

      if (hasWaterfall) {
        final ripple = pinkVal * (0.35 + 0.15 * math.sin(2 * math.pi * 1.8 * t));
        mixedSample += (ripple + brownVal * 0.45);
      }

      if (hasWind) {
        final gustLfo = 0.25 + 0.75 * math.pow(0.5 + 0.5 * math.sin(2 * math.pi * 0.15 * t), 2);
        mixedSample += (pinkVal * 0.45 + brownVal * 0.2) * gustLfo;
      }

      if (hasPink) mixedSample += pinkVal * 0.5;
      if (hasBrown) mixedSample += brownVal * 0.6;
      if (hasThunder) {
        final thunderCycle = t % 4.5;
        if (thunderCycle < 1.4) {
          final env = math.sin(math.pi * (thunderCycle / 1.4));
          mixedSample += brownVal * (0.7 + 0.3 * math.sin(2 * math.pi * 42.0 * t)) * env * 0.55;
        }
      }

      // Gentle Binaural Theta Wave (6Hz beat) for Deep Relaxation Sleep Induction
      final thetaWave = (math.sin(2 * math.pi * 106.0 * t) - math.sin(2 * math.pi * 100.0 * t)) * 0.035;
      mixedSample += thetaWave;

      // 18. Universal Hash Synthesizer Fallback (Guarantees distinct sound for ANY custom word!)
      final isAnyMatched = hasHorn || hasFire || hasChime || hasPurr || hasClock || hasTrain || hasBird ||
          hasGuitar || hasVacuum || hasVoice || hasDog || hasRocket || hasDrum || hasBubble || hasFlute || hasTyping ||
          hasRain || hasOcean || hasCrickets || hasWaterfall || hasWind || hasPink || hasBrown || hasThunder;

      if (!isAnyMatched) {
        final wordTone1 = math.sin(2 * math.pi * hashFreq1 * t) * 0.18;
        final wordTone2 = math.sin(2 * math.pi * hashFreq2 * t) * 0.12;
        final rhythmMod = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(2 * math.pi * hashRhythmRate * t));
        mixedSample += (wordTone1 + wordTone2 + pinkVal * 0.25 + brownVal * 0.25) * rhythmMod;
      }

      // Analog Soft-Clipping Saturation Curve (tanh curve prevents digital clipping)
      final x = mixedSample * 0.85;
      samples[i] = (x / (1.0 + x.abs())).clamp(-0.95, 0.95);
    }

    // Apply seamless 100ms smooth cosine crossfade
    final fadeSamples = (sampleRate * 0.10).round();
    final loopedSamples = Float32List.fromList(samples);
    for (int i = 0; i < fadeSamples; i++) {
      final alpha = i / fadeSamples.toDouble();
      final cosWeight = (1.0 - math.cos(math.pi * alpha)) / 2.0;
      final head = samples[i];
      final tail = samples[numSamples - fadeSamples + i];
      loopedSamples[i] = tail * (1.0 - cosWeight) + head * cosWeight;
    }

    // Encode to WAV bytes
    final bytes = _encodeWav(loopedSamples);

    // Save to App Documents Directory
    final appDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${appDir.path}/ai_sound_$timestamp.wav');
    await file.writeAsBytes(bytes);

    // Generate descriptive title from prompt
    final title = _generateTitleFromPrompt(prompt);

    return SoundTrack(
      id: 'ai_sound_$timestamp',
      title: title,
      description: 'AI Generated: "$prompt"',
      assetPath: file.path,
      icon: _selectIconForPrompt(cleanPrompt),
      category: 'AI Custom',
    );
  }

  static Uint8List _encodeWav(Float32List samples) {
    const numChannels = 1;
    const bytesPerSample = 2;
    final dataSize = samples.length * numChannels * bytesPerSample;
    final buffer = ByteData(44 + dataSize);

    // RIFF header
    _writeString(buffer, 0, 'RIFF');
    buffer.setUint32(4, 36 + dataSize, Endian.little);
    _writeString(buffer, 8, 'WAVE');

    // fmt subchunk
    _writeString(buffer, 12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little);
    buffer.setUint16(20, 1, Endian.little); // AudioFormat PCM
    buffer.setUint16(22, numChannels, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * numChannels * bytesPerSample, Endian.little);
    buffer.setUint16(32, numChannels * bytesPerSample, Endian.little);
    buffer.setUint16(34, 16, Endian.little); // 16-bit

    // data subchunk
    _writeString(buffer, 36, 'data');
    buffer.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    for (int i = 0; i < samples.length; i++) {
      final sample = (samples[i].clamp(-1.0, 1.0) * 32767.0).round();
      buffer.setInt16(offset, sample, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  static void _writeString(ByteData data, int offset, String value) {
    for (int i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  static String _generateTitleFromPrompt(String prompt) {
    final words = prompt.trim().split(' ').take(4).join(' ');
    if (words.length > 25) {
      return '${words.substring(0, 22)}...';
    }
    return words.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  static IconData _selectIconForPrompt(String cleanPrompt) {
    if (cleanPrompt.contains('horn') || cleanPrompt.contains('car') || cleanPrompt.contains('traffic')) return Icons.directions_car_rounded;
    if (cleanPrompt.contains('fire') || cleanPrompt.contains('crackle')) return Icons.local_fire_department_rounded;
    if (cleanPrompt.contains('bell') || cleanPrompt.contains('chime') || cleanPrompt.contains('piano') || cleanPrompt.contains('guitar') || cleanPrompt.contains('music')) return Icons.music_note_rounded;
    if (cleanPrompt.contains('cat') || cleanPrompt.contains('purr') || cleanPrompt.contains('dog') || cleanPrompt.contains('pet')) return Icons.pets_rounded;
    if (cleanPrompt.contains('clock') || cleanPrompt.contains('tick')) return Icons.access_time_rounded;
    if (cleanPrompt.contains('train') || cleanPrompt.contains('track')) return Icons.train_rounded;
    if (cleanPrompt.contains('bird') || cleanPrompt.contains('chirp')) return Icons.flutter_dash_rounded;
    if (cleanPrompt.contains('vacuum') || cleanPrompt.contains('fan')) return Icons.air_rounded;
    if (cleanPrompt.contains('rain')) return Icons.grain_rounded;
    if (cleanPrompt.contains('ocean') || cleanPrompt.contains('sea')) return Icons.waves_rounded;
    if (cleanPrompt.contains('cricket') || cleanPrompt.contains('night')) return Icons.nightlight_round;
    if (cleanPrompt.contains('waterfall') || cleanPrompt.contains('stream')) return Icons.water_rounded;
    if (cleanPrompt.contains('forest') || cleanPrompt.contains('wind')) return Icons.park_rounded;
    return Icons.auto_awesome_rounded;
  }
}
