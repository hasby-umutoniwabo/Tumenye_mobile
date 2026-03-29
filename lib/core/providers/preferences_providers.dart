import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Returns a SharedPreferences key scoped to the current signed-in user.
/// If no user is logged in (e.g. on the auth screen) falls back to "guest".
/// This ensures that User A's dark mode setting doesn't bleed into User B's.
String _userKey(String base) {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  return '${base}_$uid';
}

// ─── Theme ────────────────────────────────────────────────────────────────────

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getString(_userKey(PrefKeys.themeMode)) == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  /// Called with the new uid when the signed-in user changes.
  /// Passing uid directly avoids the race where currentUser is still null.
  Future<void> reloadForUid(String uid) async {
    final p = await SharedPreferences.getInstance();
    state = p.getString('${PrefKeys.themeMode}_$uid') == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> toggle() async {
    final p = await SharedPreferences.getInstance();
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await p.setString(
        _userKey(PrefKeys.themeMode), state == ThemeMode.dark ? 'dark' : 'light');
  }
}

// Not autoDispose — TumenyeApp (root) always watches this, so it can never
// be auto-disposed. Instead, reload() is called on auth user changes.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
        (_) => ThemeModeNotifier());

// ─── Generic bool preference ──────────────────────────────────────────────────

class BoolPrefNotifier extends StateNotifier<bool> {
  final String baseKey;
  final bool defaultVal;
  BoolPrefNotifier(this.baseKey, this.defaultVal) : super(defaultVal) {
    _load();
  }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getBool(_userKey(baseKey)) ?? defaultVal;
  }

  Future<void> toggle() async {
    final p = await SharedPreferences.getInstance();
    state = !state;
    await p.setBool(_userKey(baseKey), state);
  }
}

final offlineModeProvider =
    StateNotifierProvider.autoDispose<BoolPrefNotifier, bool>(
        (_) => BoolPrefNotifier(PrefKeys.offlineMode, false));

final remindersProvider =
    StateNotifierProvider.autoDispose<BoolPrefNotifier, bool>(
        (_) => BoolPrefNotifier(PrefKeys.dailyReminders, true));

final dataUsageProvider =
    StateNotifierProvider.autoDispose<BoolPrefNotifier, bool>(
        (_) => BoolPrefNotifier(PrefKeys.dataUsageMode, false));

// ─── Language ─────────────────────────────────────────────────────────────────

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('English') {
    _load();
  }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getString(_userKey(PrefKeys.language)) ?? 'English';
  }

  Future<void> set(String lang) async {
    final p = await SharedPreferences.getInstance();
    state = lang;
    await p.setString(_userKey(PrefKeys.language), lang);
  }
}

final languageProvider =
    StateNotifierProvider.autoDispose<LanguageNotifier, String>(
        (_) => LanguageNotifier());

// ─── Daily Goal ───────────────────────────────────────────────────────────────

/// Daily learning goal in minutes (15 / 20 / 30 / 45 / 60).
/// Per-user: each account's goal is saved and restored independently.
class DailyGoalNotifier extends StateNotifier<int> {
  DailyGoalNotifier() : super(30) {
    _load();
  }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getInt(_userKey(PrefKeys.dailyGoalMinutes)) ?? 30;
  }

  Future<void> set(int minutes) async {
    final p = await SharedPreferences.getInstance();
    state = minutes;
    await p.setInt(_userKey(PrefKeys.dailyGoalMinutes), minutes);
  }
}

final dailyGoalProvider =
    StateNotifierProvider.autoDispose<DailyGoalNotifier, int>(
        (_) => DailyGoalNotifier());

// ─── Notifications last seen ──────────────────────────────────────────────────

/// Stores the epoch-ms of the last time this user opened the notifications screen.
/// The home screen uses it to show a badge only for items newer than this timestamp.
class NotifLastSeenNotifier extends StateNotifier<DateTime> {
  NotifLastSeenNotifier() : super(DateTime.fromMillisecondsSinceEpoch(0)) {
    _load();
  }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final ms = p.getInt(_userKey(PrefKeys.notifLastSeen)) ?? 0;
    state = DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markSeen() async {
    final now = DateTime.now();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_userKey(PrefKeys.notifLastSeen), now.millisecondsSinceEpoch);
    state = now;
  }
}

final notifLastSeenProvider =
    StateNotifierProvider.autoDispose<NotifLastSeenNotifier, DateTime>(
        (_) => NotifLastSeenNotifier());
