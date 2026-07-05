import '../models/app_user.dart';

class UserStore {
  static final List<AppUser> _users = [];

  static Future<bool> register(AppUser user) async {
    final exists = _users.any((u) => u.email == user.email);
    if (exists) return false;

    _users.add(user);
    return true;
  }

  static Future<AppUser?> login(String email, String password) async {
    try {
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );

      if (user.isBlocked) return null;

      return user;
    } catch (_) {
      return null;
    }
  }

  static Future<List<AppUser>> loadUsers() async {
    return _users;
  }

  static void blockUser(String email) {
    final user = _users.firstWhere((u) => u.email == email);
    user.isBlocked = true;
  }

  static void unblockUser(String email) {
    final user = _users.firstWhere((u) => u.email == email);
    user.isBlocked = false;
  }
}
