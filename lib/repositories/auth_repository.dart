import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  static const String _userKey = 'aquasoothe_current_user_v1';
  static const String _usersDbKey = 'aquasoothe_registered_users_v1';

  final SharedPreferences _prefs;
  fb_auth.FirebaseAuth get _firebaseAuth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  AuthRepository(this._prefs);

  UserModel? getCurrentUser() {
    // 1. Check Firebase current user if available
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null) {
        return UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? (fbUser.isAnonymous ? 'Guest User' : 'User'),
          email: fbUser.email ?? (fbUser.isAnonymous ? 'guest@aquasoothe.app' : ''),
          isGuest: fbUser.isAnonymous,
          createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
        );
      }
    } catch (_) {}

    // 2. Fallback to local SharedPreferences
    final rawJson = _prefs.getString(_userKey);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(rawJson));
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser != null) {
        await fbUser.updateDisplayName(name.trim());

        final userModel = UserModel(
          id: fbUser.uid,
          name: name.trim(),
          email: cleanEmail,
          isGuest: false,
          createdAt: DateTime.now(),
        );

        try {
          await _firestore.collection('users').doc(fbUser.uid).set(userModel.toJson());
        } catch (_) {}

        await _prefs.setString(_userKey, jsonEncode(userModel.toJson()));
        return userModel;
      }
    } catch (e) {
      if (e is fb_auth.FirebaseAuthException) {
        throw Exception(e.message ?? 'Firebase Authentication Error');
      }
    }

    // Local fallback
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: cleanEmail,
      isGuest: false,
      createdAt: DateTime.now(),
    );

    final dbMap = _getUsersDb();
    dbMap[cleanEmail] = {
      'user': newUser.toJson(),
      'password': password,
    };
    await _prefs.setString(_usersDbKey, jsonEncode(dbMap));
    await _prefs.setString(_userKey, jsonEncode(newUser.toJson()));
    return newUser;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser != null) {
        UserModel? userModel;
        try {
          final doc = await _firestore.collection('users').doc(fbUser.uid).get();
          if (doc.exists && doc.data() != null) {
            userModel = UserModel.fromJson(doc.data()!);
          }
        } catch (_) {}

        userModel ??= UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? cleanEmail.split('@').first,
          email: cleanEmail,
          isGuest: false,
          createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
        );

        await _prefs.setString(_userKey, jsonEncode(userModel.toJson()));
        return userModel;
      }
    } catch (e) {
      if (e is fb_auth.FirebaseAuthException) {
        throw Exception(e.message ?? 'Login failed. Check your credentials.');
      }
    }

    // Local DB fallback
    final dbMap = _getUsersDb();
    if (!dbMap.containsKey(cleanEmail)) {
      throw Exception('Account with email $cleanEmail not found. Please sign up.');
    }

    final record = dbMap[cleanEmail];
    if (record['password'] != password) {
      throw Exception('Incorrect password. Please try again.');
    }

    final user = UserModel.fromJson(record['user']);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<UserModel> loginAsGuest() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      final fbUser = credential.user;
      if (fbUser != null) {
        final guestUser = UserModel(
          id: fbUser.uid,
          name: 'Guest User',
          email: 'guest@aquasoothe.app',
          isGuest: true,
          createdAt: DateTime.now(),
        );

        try {
          await _firestore.collection('users').doc(fbUser.uid).set(guestUser.toJson());
        } catch (_) {}

        await _prefs.setString(_userKey, jsonEncode(guestUser.toJson()));
        return guestUser;
      }
    } catch (_) {}

    // Fallback local guest
    final guestUser = UserModel(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest User',
      email: 'guest@aquasoothe.app',
      isGuest: true,
      createdAt: DateTime.now(),
    );

    await _prefs.setString(_userKey, jsonEncode(guestUser.toJson()));
    return guestUser;
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    await _prefs.remove(_userKey);
  }

  Map<String, dynamic> _getUsersDb() {
    final rawJson = _prefs.getString(_usersDbKey);
    if (rawJson == null || rawJson.isEmpty) return {};
    try {
      return jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
