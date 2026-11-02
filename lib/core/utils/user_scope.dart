import '../../models/user_model.dart';

/// Helper to generate isolated SharedPreferences and cache keys per user account.
/// Ensures each registered account has their own isolated data sandbox,
/// while Guest mode operates in a separate guest sandbox.
class UserScope {
  static String getKey(UserModel? user) {
    if (user == null || user.isGuest) {
      return 'guest_';
    }
    final email = user.email.trim().toLowerCase();
    if (email.isNotEmpty) {
      final safeEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      return 'user_${safeEmail}_';
    }
    final safeId = user.id.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'user_${safeId.isNotEmpty ? safeId : "default"}_';
  }
}
