abstract class AppStrings {
  static const appName = 'TUMENYE';
  static const tagline = 'Unlock Your Digital Future';
}

abstract class PrefKeys {
  static const themeMode = 'pref_theme_mode';
  static const language = 'pref_language';
  static const offlineMode = 'pref_offline_mode';
  static const dailyReminders = 'pref_daily_reminders';
  static const dataUsageMode = 'pref_data_usage_mode';
  static const isLoggedIn = 'pref_is_logged_in';
  static const userRole = 'pref_user_role';
}

abstract class UserRole {
  static const student = 'student';
  static const parent = 'parent';
  static const admin = 'admin';
}

class ModuleData {
  final String id;
  final String title;
  final int totalLessons;
  final int completedLessons;
  final bool isLocked;
  final int colorValue;
  final String iconKey;

  const ModuleData({
    required this.id,
    required this.title,
    required this.totalLessons,
    required this.completedLessons,
    this.isLocked = false,
    required this.colorValue,
    required this.iconKey,
  });

  double get progress =>
      totalLessons == 0 ? 0.0 : completedLessons / totalLessons;

  String get subtitle =>
      isLocked ? 'Locked' : '$completedLessons/$totalLessons Lessons';
}

const sampleModules = [
  ModuleData(id: 'word', title: 'Word', totalLessons: 10, completedLessons: 8, colorValue: 0xFF4A90E2, iconKey: 'word'),
  ModuleData(id: 'excel', title: 'Excel', totalLessons: 10, completedLessons: 2, colorValue: 0xFF3DDC84, iconKey: 'excel'),
  ModuleData(id: 'email', title: 'Email', totalLessons: 8, completedLessons: 0, colorValue: 0xFFFF8C42, iconKey: 'email'),
  ModuleData(id: 'safety', title: 'Safety', totalLessons: 6, completedLessons: 0, isLocked: true, colorValue: 0xFF7B61FF, iconKey: 'safety'),
];