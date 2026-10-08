import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound_model.dart';

class CustomSoundRepository {
  static const String _customSoundsKey = 'aquasoothe_custom_ai_sounds_v1';
  final SharedPreferences _prefs;

  CustomSoundRepository(this._prefs);

  List<SoundTrack> getCustomSounds() {
    final rawJson = _prefs.getString(_customSoundsKey);
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((e) {
        final iconCode = e['iconCode'] as int? ?? Icons.auto_awesome_rounded.codePoint;
        return SoundTrack(
          id: e['id'] as String,
          title: e['title'] as String,
          description: e['description'] as String,
          assetPath: e['assetPath'] as String,
          icon: _getIconFromCode(iconCode),
          category: 'AI Custom',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomSound(SoundTrack sound) async {
    final list = getCustomSounds();
    list.insert(0, sound);
    
    final jsonList = list.map((s) => {
          'id': s.id,
          'title': s.title,
          'description': s.description,
          'assetPath': s.assetPath,
          'iconCode': s.icon.codePoint,
          'category': s.category,
        }).toList();

    await _prefs.setString(_customSoundsKey, jsonEncode(jsonList));
  }

  Future<void> deleteCustomSound(String id) async {
    final list = getCustomSounds();
    list.removeWhere((s) => s.id == id);
    
    final jsonList = list.map((s) => {
          'id': s.id,
          'title': s.title,
          'description': s.description,
          'assetPath': s.assetPath,
          'iconCode': s.icon.codePoint,
          'category': s.category,
        }).toList();

    await _prefs.setString(_customSoundsKey, jsonEncode(jsonList));
  }

  IconData _getIconFromCode(int codePoint) {
    if (codePoint == Icons.grain_rounded.codePoint) return Icons.grain_rounded;
    if (codePoint == Icons.waves_rounded.codePoint) return Icons.waves_rounded;
    if (codePoint == Icons.nightlight_round.codePoint) return Icons.nightlight_round;
    if (codePoint == Icons.water_rounded.codePoint) return Icons.water_rounded;
    if (codePoint == Icons.park_rounded.codePoint) return Icons.park_rounded;
    return Icons.auto_awesome_rounded;
  }
}
