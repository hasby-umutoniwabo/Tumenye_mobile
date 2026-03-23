import 'package:flutter_test/flutter_test.dart';
import 'package:tumenye/core/constants/app_constants.dart';

void main() {
  group('AppStrings', () {
    test('app name is TUMENYE', () => expect(AppStrings.appName, 'TUMENYE'));
    test('tagline is non-empty', () => expect(AppStrings.tagline.isNotEmpty, true));
  });

  group('PrefKeys', () {
    test('all keys are unique', () {
      final keys = [PrefKeys.themeMode, PrefKeys.language, PrefKeys.offlineMode,
        PrefKeys.dailyReminders, PrefKeys.dataUsageMode, PrefKeys.isLoggedIn];
      expect(keys.toSet().length, keys.length);
    });
  });

  group('ModuleData', () {
    test('sample list has 4 modules', () => expect(sampleModules.length, 4));
    test('word progress is 0.8', () => expect(
        sampleModules.firstWhere((m) => m.id == 'word').progress, closeTo(0.8, 0.001)));
    test('safety is locked', () => expect(
        sampleModules.firstWhere((m) => m.id == 'safety').isLocked, true));
    test('email progress is 0', () => expect(
        sampleModules.firstWhere((m) => m.id == 'email').progress, 0.0));
    test('no division by zero when totalLessons is 0', () {
      const m = ModuleData(id:'x',title:'x',totalLessons:0,
          completedLessons:0,colorValue:0xFF000000,iconKey:'x');
      expect(m.progress, 0.0);
    });
    test('progress never exceeds 1.0', () {
      for (final m in sampleModules) {
        expect(m.progress, lessThanOrEqualTo(1.0));
        expect(m.progress, greaterThanOrEqualTo(0.0));
      }
    });
  });
}