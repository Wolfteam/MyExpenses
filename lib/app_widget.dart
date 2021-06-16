import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_expenses/bloc/app/app_bloc.dart';
import 'package:my_expenses/bloc/drawer/drawer_bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/ui/pages/main_page.dart';
import 'package:my_expenses/ui/widgets/loading.dart';
import 'package:my_expenses/ui/widgets/splash_screen.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final delegates = <LocalizationsDelegate>[
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
    return BlocBuilder<AppBloc, AppState>(
      builder: (ctx, state) => state.map(
        loaded: (state) {
          if (state.bgTaskIsRunning) {
            return MaterialApp(
              theme: state.theme,
              localizationsDelegates: delegates,
              supportedLocales: S.delegate.supportedLocales,
              home: Loading(),
            );
          }

          ctx.read<DrawerBloc>().add(const DrawerEvent.init());
          final locale = Locale(state.language.code, state.language.countryCode);
          return MaterialApp(
            home: MainPage(),
            theme: state.theme,
            //Without this, the lang won't be reloaded
            locale: locale,
            localizationsDelegates: delegates,
            supportedLocales: S.delegate.supportedLocales,
          );
        },
        loading: (state) {
          if (state.theme == null) {
            context.read<AppBloc>().add(const AppEvent.loadTheme());
          }

          return MaterialApp(
            home: SplashScreen(),
            theme: state.theme,
            localizationsDelegates: delegates,
            supportedLocales: S.delegate.supportedLocales,
          );
        },
      ),
    );
  }
}
