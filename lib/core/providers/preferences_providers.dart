import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) { _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getString(PrefKeys.themeMode) == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }
  Future<void> toggle() async {
    final p = await SharedPreferences.getInstance();
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await p.setString(PrefKeys.themeMode, state == ThemeMode.dark ? 'dark' : 'light');
  }
}
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((_) => ThemeModeNotifier());

class BoolPrefNotifier extends StateNotifier<bool> {
  final String key;
  final bool defaultVal;
  BoolPrefNotifier(this.key, this.defaultVal) : super(defaultVal) { _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getBool(key) ?? defaultVal;
  }
  Future<void> toggle() async {
    final p = await SharedPreferences.getInstance();
    state = !state;
    await p.setBool(key, state);
  }
}
final offlineModeProvider = StateNotifierProvider<BoolPrefNotifier, bool>(
    (_) => BoolPrefNotifier(PrefKeys.offlineMode, false));
final remindersProvider = StateNotifierProvider<BoolPrefNotifier, bool>(
    (_) => BoolPrefNotifier(PrefKeys.dailyReminders, true));
final dataUsageProvider = StateNotifierProvider<BoolPrefNotifier, bool>(
    (_) => BoolPrefNotifier(PrefKeys.dataUsageMode, false));

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('English') { _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getString(PrefKeys.language) ?? 'English';
  }
  Future<void> set(String lang) async {
    final p = await SharedPreferences.getInstance();
    state = lang;
    await p.setString(PrefKeys.language, lang);
  }
}
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((_) => LanguageNotifier());