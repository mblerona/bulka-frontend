import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/l10n/locale_controller.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/routing/app_router.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/core/theme/app_theme.dart';
import 'package:bulka_frontend/l10n/app_localizations.dart';
import 'package:bulka_frontend/services/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Saved language, or the phone's language on first launch.
  await LocaleController.instance.load();
  // Draw behind the system bars on every Android version (Android 15+ forces
  // this anyway), so layouts look the same on all devices. Screens and the
  // bottom nav bar pad themselves with the system insets.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  // When the session can't be refreshed any more, drop the user and send
  // them back to Login from wherever they are.
  ApiClient.instance.onSessionExpired = () {
    AuthController.instance.clearSession();
    appRouter.go(AppRoutes.login);
  };
  runApp(BulkaApp(router: appRouter));
}

class BulkaApp extends StatefulWidget {
  const BulkaApp({super.key, required this.router});

  /// [appRouter] in the app; tests pass their own.
  final GoRouter router;

  @override
  State<BulkaApp> createState() => _BulkaAppState();
}

class _BulkaAppState extends State<BulkaApp> {
  final LocaleController _locale = LocaleController.instance;

  @override
  void initState() {
    super.initState();
    _locale.addListener(_handleLocaleChanged);
  }

  @override
  void dispose() {
    _locale.removeListener(_handleLocaleChanged);
    super.dispose();
  }

  /// Screens read their text through `AppStrings`, which doesn't make them
  /// rebuild on its own, so every open screen is rebuilt here. This keeps
  /// the navigation history (no restart) and each screen's state.
  void _handleLocaleChanged() {
    setState(() {});
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bulka',
      // Routes are in lib/core/routing/app_router.dart. Debug builds start
      // on the dev screen launcher, release builds on Splash.
      routerConfig: widget.router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Also translates Flutter's own widgets (date pickers, copy/paste).
      locale: _locale.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
