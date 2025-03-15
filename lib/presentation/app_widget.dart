import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_expenses/application/app/app_bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/main/main_page.dart';
import 'package:my_expenses/presentation/shared/extensions/app_theme_type_extensions.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/loading.dart';
import 'package:my_expenses/presentation/splash/splash_screen.dart';

class AppWidget extends StatefulWidget {
  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  Locale? _currentLocale;

  @override
  Widget build(BuildContext context) {
    final delegates = <LocalizationsDelegate>[
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
    return BlocConsumer<AppBloc, AppState>(
      listener: (ctx, state) async {
        switch (state) {
          case AppStateLoadedState():
            final locale = _getLocale(state.language);
            final localeChanged =
                _currentLocale != null &&
                (_currentLocale!.languageCode != locale.languageCode || _currentLocale!.countryCode != locale.countryCode);
            final bloc = ctx.read<AppBloc>();
            if (localeChanged) {
              debugPrint('Language changed');
              final s = await S.delegate.load(locale);
              final translations = s.getBackgroundTranslations();
              bloc.add(AppEvent.registerRecurringBackgroundTask(translations: translations));
            }

            _currentLocale = locale;
          default:
            break;
        }
      },
      builder:
          (ctx, state) => switch (state) {
            AppStateLoadingState() => MaterialApp(
              home: SplashScreen(),
              theme: AppAccentColorType.orange.getThemeData(AppThemeType.dark),
              themeMode: ThemeMode.dark,
              localizationsDelegates: delegates,
              supportedLocales: S.delegate.supportedLocales,
              scrollBehavior: MyCustomScrollBehavior(),
            ),
            final AppStateLoadedState state when state.bgTaskIsRunning => MaterialApp(
              theme: state.accentColor.getThemeData(state.theme),
              localizationsDelegates: delegates,
              supportedLocales: S.delegate.supportedLocales,
              home: const Loading(),
              scrollBehavior: MyCustomScrollBehavior(),
            ),
            AppStateLoadedState() => MaterialApp(
              home: const MainPage(),
              theme: state.accentColor.getThemeData(state.theme),
              //Without this, the lang won't be reloaded
              locale: _getLocale(state.language),
              localizationsDelegates: delegates,
              supportedLocales: S.delegate.supportedLocales,
              scrollBehavior: MyCustomScrollBehavior(),
            ),
          },
    );
  }

  Locale _getLocale(LanguageModel model) => Locale(model.code, model.countryCode);
}

// Since 2.5 the scroll behavior changed on desktop,
// this keeps the old one working
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
