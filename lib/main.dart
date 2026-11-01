import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/blocs/app_bloc_providers.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/core/routing/app_router.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/core/theme/app_theme.dart';
import 'package:bulka_frontend/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Saved language, or the phone's language on first launch.
  final initialLocale = await LocaleBloc.loadInitialLocale();
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
  runApp(BulkaApp(router: appRouter, initialLocale: initialLocale));
}

class BulkaApp extends StatelessWidget {
  const BulkaApp({
    super.key,
    required this.router,
    this.initialLocale = const Locale('mk'),
  });

  /// [appRouter] in the app; tests pass their own.
  final GoRouter router;
  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    return AppBlocProviders(
      initialLocale: initialLocale,
      child: MultiBlocListener(
        listeners: [
          // Screens read their text through `AppStrings`, which doesn't make
          // them rebuild on its own, so every open screen is rebuilt here.
          // This keeps the navigation history and each screen's state.
          BlocListener<LocaleBloc, LocaleState>(
            listener: (context, _) {
              void rebuild(Element element) {
                element.markNeedsBuild();
                element.visitChildren(rebuild);
              }

              (context as Element).visitChildren(rebuild);
            },
          ),
          // The session can't be refreshed any more: back to Login from
          // wherever the user is.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                current.operation == AuthOperation.sessionExpired &&
                previous.operation != AuthOperation.sessionExpired,
            listener: (context, _) => router.go(AppRoutes.login),
          ),
        ],
        child: BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) => MaterialApp.router(
            title: 'Bulka',
            // Routes are in lib/core/routing/app_router.dart. Debug builds
            // start on the dev screen launcher, release builds on Splash.
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            // Also translates Flutter's own widgets (date pickers, copy/paste).
            locale: localeState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      ),
    );
  }
}
