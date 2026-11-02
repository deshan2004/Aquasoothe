import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'hydration_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepository(prefs);
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(_repository.getCurrentUser());

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String? gender,
  }) async {
    final user = await _repository.signUp(
      name: name,
      email: email,
      password: password,
      gender: gender,
    );
    state = user;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final user = await _repository.login(
      email: email,
      password: password,
    );
    state = user;
  }

  Future<void> loginAsGuest() async {
    final guest = await _repository.loginAsGuest();
    state = guest;
  }

  Future<void> signInWithGoogle() async {
    final user = await _repository.signInWithGoogle();
    state = user;
  }

  Future<void> updateGender(String gender) async {
    final updated = await _repository.updateGender(gender);
    state = updated;
  }

  Future<void> logout() async {
    await _repository.logout();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
