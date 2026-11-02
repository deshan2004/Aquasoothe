import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound_model.dart';

class CustomSoundRepository {
  final SharedPreferences _prefs;
  final String _userKey;

  fb_auth.FirebaseAuth get _firebaseAuth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CustomSoundRepository(this._prefs, {this._userKey = 'guest_'});

  String get _customSoundsKey => '${_userKey}custom_ai_sounds_v1';

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

    // Sync with Firestore if user is authenticated
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('custom_sounds')
            .doc(sound.id)
            .set({
              'id': sound.id,
              'title': sound.title,
              'description': sound.description,
              'assetPath': sound.assetPath,
              'iconCode': sound.icon.codePoint,
              'category': sound.category,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    } catch (_) {}
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
