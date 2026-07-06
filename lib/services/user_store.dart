import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class UserStore {
  static const _key = 'jawan_users_v1';

  static Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  static Future<List<AppUser>> loadUsers() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> saveUsers(List<AppUser> users) async {
    final prefs = await _prefs();
    final list = users.map((u) => u.toJson()).toList();
    return prefs.setString(_key, json.encode(list));
  }

  static Future<bool> register(AppUser user) async {
    final users = await loadUsers();
    final exists = users.any((u) => u.email == user.email);
    if (exists) return false;
    users.add(user);
    return saveUsers(users);
  }

  static Future<AppUser?> login(String email, String password) async {
    try {
      final users = await loadUsers();
      final user = users.firstWhere((u) => u.email == email && u.password == password);
      if (user.isBlocked) return null;
      return user;
    } catch (_) {
      return null;
    }
  }

  static Future<void> blockUser(String email) async {
    final users = await loadUsers();
    final idx = users.indexWhere((u) => u.email == email);
    if (idx == -1) return;
    users[idx].isBlocked = true;
    await saveUsers(users);
  }

  static Future<void> unblockUser(String email) async {
    final users = await loadUsers();
    final idx = users.indexWhere((u) => u.email == email);
    if (idx == -1) return;
    users[idx].isBlocked = false;
    await saveUsers(users);
  }

  static Future<void> updateUser(AppUser user) async {
    final users = await loadUsers();
    final idx = users.indexWhere((u) => u.email == user.email);
    if (idx == -1) return;
    users[idx] = user;
    await saveUsers(users);
  }

  static Future<void> deleteUser(String email) async {
    final users = await loadUsers();
    users.removeWhere((u) => u.email == email);
    await saveUsers(users);
  }
}
