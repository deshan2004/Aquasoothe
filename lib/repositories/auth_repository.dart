import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/sql_api_service.dart';

class AuthRepository {
  static const String _userKey = 'aquasoothe_current_user_v1';
  static const String _usersDbKey = 'aquasoothe_registered_users_v1';

  final SharedPreferences _prefs;
  fb_auth.FirebaseAuth get _firebaseAuth => fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  AuthRepository(this._prefs);

  UserModel? getCurrentUser() {
    // 1. Check Firebase current user if available (only permanent registered accounts)
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null && !fbUser.isAnonymous) {
        return UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? 'User',
          email: fbUser.email ?? '',
          isGuest: false,
          createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
        );
      }
    } catch (_) {}

    // 2. Fallback to local SharedPreferences
    final rawJson = _prefs.getString(_userKey);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final user = UserModel.fromJson(jsonDecode(rawJson));
      if (user.isGuest) return null;
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? gender,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Try Microsoft SQL Server (MS SQL) backend first
    try {
      final sqlUser = await SqlApiService.signUp(
        name: name,
        email: cleanEmail,
        password: password,
      );
      if (sqlUser != null) {
        final withGender = UserModel(
          id: sqlUser.id,
          name: sqlUser.name,
          email: sqlUser.email,
          isGuest: sqlUser.isGuest,
          gender: gender ?? sqlUser.gender,
          createdAt: sqlUser.createdAt,
        );
        await _prefs.setString(_userKey, jsonEncode(withGender.toJson()));
        return withGender;
      }
    } catch (_) {}

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
          gender: gender,
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
      gender: gender,
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

    // 1. Try Microsoft SQL Server (MS SQL) backend first
    try {
      final sqlUser = await SqlApiService.login(
        email: cleanEmail,
        password: password,
      );
      if (sqlUser != null) {
        await _prefs.setString(_userKey, jsonEncode(sqlUser.toJson()));
        return sqlUser;
      }
    } catch (_) {}

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

  Future<UserModel> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? '1054170301134-s4v24lhaot063776f0gtjbt3ssmai36d.apps.googleusercontent.com'
          : null,
      serverClientId: '1054170301134-grf2mqogvm55nukb9ur4oae0qed0v1v2.apps.googleusercontent.com',
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled by user');
    }

    final name = googleUser.displayName ?? 'Google User';
    final email = googleUser.email.trim().toLowerCase();

    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fbUserCredential = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = fbUserCredential.user;

      final uid = fbUser?.uid ?? 'google_${googleUser.id}';

      // Check if user already exists in Firestore and has gender set
      String? existingGender;
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          existingGender = doc.data()!['gender'] as String?;
        }
      } catch (_) {}

      final userModel = UserModel(
        id: uid,
        name: fbUser?.displayName ?? name,
        email: fbUser?.email ?? email,
        isGuest: false,
        gender: existingGender,
        createdAt: fbUser?.metadata.creationTime ?? DateTime.now(),
      );

      try {
        await _firestore.collection('users').doc(uid).set(userModel.toJson(), SetOptions(merge: true));
      } catch (_) {}

      await _prefs.setString(_userKey, jsonEncode(userModel.toJson()));
      return userModel;
    } catch (e) {
      if (e is Exception && e.toString().contains('cancelled')) {
        rethrow;
      }
      // Resilient fallback with Google account profile details
      final userModel = UserModel(
        id: 'google_${googleUser.id}',
        name: name,
        email: email,
        isGuest: false,
        createdAt: DateTime.now(),
      );
      await _prefs.setString(_userKey, jsonEncode(userModel.toJson()));
      return userModel;
    }
  }

  Future<UserModel> updateGender(String gender) async {
    final currentUser = getCurrentUser();
    final updated = (currentUser ?? UserModel(
      id: _firebaseAuth.currentUser?.uid ?? 'user',
      name: _firebaseAuth.currentUser?.displayName ?? 'User',
      email: _firebaseAuth.currentUser?.email ?? '',
      createdAt: DateTime.now(),
    )).copyWith(gender: gender);

    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null) {
        await _firestore.collection('users').doc(fbUser.uid).set(
          {'gender': gender},
          SetOptions(merge: true),
        );
      }
    } catch (_) {}

    await _prefs.setString(_userKey, jsonEncode(updated.toJson()));
    return updated;
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
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
