import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/preferences_providers.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/firestore_service.dart';
import 'firebase_options.dart';

/// Handles Material localizations for ALL locales.
/// For locales supported by Flutter (en, fr, …) it delegates normally.
/// For unsupported locales (e.g. Kinyarwanda / rw) it falls back to English,
/// so widgets like AlertDialog, DatePicker etc. still render without crashing.
class _MaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final d = GlobalMaterialLocalizations.delegate;
    return d.isSupported(locale)
        ? d.load(locale)
        : d.load(const Locale('en'));
  }

  @override
  bool shouldReload(_MaterialLocalizationsDelegate old) => false;
}

/// Same catch-all pattern for Cupertino localizations.
class _CupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final d = GlobalCupertinoLocalizations.delegate;
    return d.isSupported(locale)
        ? d.load(locale)
        : d.load(const Locale('en'));
  }

  @override
  bool shouldReload(_CupertinoLocalizationsDelegate old) => false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await FirestoreService().seedInitialData();
  } catch (_) {}
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('rw'),
        Locale('fr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: TumenyeApp()),
    ),
  );
}

class TumenyeApp extends ConsumerWidget {
  const TumenyeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // When the signed-in user changes (login / logout / switch account),
    // reload the theme so each user sees their own saved preference.
    ref.listen(authStateProvider, (prev, next) {
      final prevUid = prev?.value?.uid;
      final nextUid = next.value?.uid;
      if (prevUid != nextUid && nextUid != null) {
        ref.read(themeModeProvider.notifier).reloadForUid(nextUid);
      }
    });

    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Tumenye',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: [
        EasyLocalization.of(context)!.delegate,
        const _MaterialLocalizationsDelegate(),
        const _CupertinoLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
