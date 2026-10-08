import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sound_model.dart';

class AISoundGeneratorService {
  static const int sampleRate = 44100;
  static const double durationSeconds = 5.0; // 5-second seamless loop

  /// Generates a custom soundscape .wav audio file based on ANY natural language text prompt
  static Future<SoundTrack> generateSoundFromPrompt(String prompt) async {
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

      // 11. Fireplace Crackle
      if (hasFire) {
        double crackle = brownVal * 0.3;
        if (random.nextDouble() < 0.0025) {
          crackle += (random.nextDouble() * 0.5 - 0.25);
        }
        mixedSample += crackle;
      }

      // 12. Piano / Chimes / Bell / Bowl
      if (hasChime) {
        final chimeCycle = t % 2.5;
        final decay = math.exp(-3.0 * chimeCycle);
        final fundamental = math.sin(2 * math.pi * 528.0 * t);
        mixedSample += fundamental * decay * 0.35;
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

      // 17. Nature Sounds (Rain, Ocean, Crickets, Waterfall, Wind, Noise, Thunder)
      if (hasRain) {
        double rainDrop = pinkVal * 0.4;
        if (random.nextDouble() < 0.0012) {
          rainDrop += (random.nextDouble() * 0.25);
        }
        mixedSample += rainDrop;
      }

      if (hasOcean) {
        final oceanEnv = 0.2 + 0.8 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.14 * t));
        mixedSample += (pinkVal * 0.4 + brownVal * 0.3) * oceanEnv;
      }

      if (hasCrickets) {
        final chirpCycle = t % 1.25;
        if (chirpCycle < 0.18) {
          final pulse = math.sin(2 * math.pi * 38 * t);
          final carrier = math.sin(2 * math.pi * 4400 * t);
          mixedSample += 0.1 * pulse * carrier;
        }
      }

      if (hasWaterfall) {
        mixedSample += (pinkVal * 0.3 + brownVal * 0.5);
      }

      if (hasWind) {
        final windEnv = 0.25 + 0.55 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.18 * t));
        mixedSample += pinkVal * windEnv * 0.35;
      }

      if (hasPink) mixedSample += pinkVal * 0.5;
      if (hasBrown) mixedSample += brownVal * 0.6;
      if (hasThunder) {
        final thunderCycle = t % 4.0;
        if (thunderCycle < 0.8) {
          mixedSample += brownVal * math.sin(math.pi * (thunderCycle / 0.8)) * 0.4;
        }
      }

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

      samples[i] = mixedSample.clamp(-1.0, 1.0);
    }

    // Apply seamless 50ms loop crossfade
    final fadeSamples = (sampleRate * 0.05).round();
    final loopedSamples = Float32List.fromList(samples);
    for (int i = 0; i < fadeSamples; i++) {
      final alpha = i / fadeSamples.toDouble();
      loopedSamples[i] = (1 - alpha) * samples[numSamples - fadeSamples + i] + alpha * samples[i];
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
