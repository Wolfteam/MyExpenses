import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/settings/widgets/password_bottom_sheet.dart';
import 'package:my_expenses/presentation/shared/custom_assets.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashScreenBloc>(
      create: (ctx) => Injection.splashScreenBloc..add(const SplashScreenEvent.init()),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashScreenBloc, SplashScreenState>(
      listener: (ctx, state) async {
        await state.map(
          initial: (state) async {
            final translations = S.of(ctx).getBackgroundTranslations();
            if (state.askForFingerPrint) {
              await _authenticateViaFingerPrint(translations);
            } else if (state.askForPassword) {
              await _authenticateViaPassword(translations);
            } else {
              ctx.read<AppBloc>().add(AppEvent.init(bgTaskIsRunning: false, translations: translations));
            }
          },
        );
      },
      child: Container(
        color: Colors.orange,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(10),
                child: Image.asset(
                  CustomAssets.appIcon,
                  width: 250,
                  height: 250,
                ),
              ),
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _authenticateViaFingerPrint(BackgroundTranslations translations) async {
    //this one is required, for the language change
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    final i18n = S.of(context);
    final localAuth = LocalAuthentication();
    try {
      final isAuthenticated = await localAuth.authenticate(
        biometricOnly: true,
        localizedReason: i18n.fingerprintRequired,
        androidAuthStrings: AndroidAuthMessages(
          biometricHint: i18n.fingerprintHint,
          biometricNotRecognized: i18n.fingerprintNotRecognized,
          biometricSuccess: i18n.fingerprintSuccess,
          cancelButton: i18n.cancel,
          signInTitle: i18n.signInTitle,
          biometricRequiredTitle: i18n.fingerprintRequired,
          goToSettingsButton: i18n.goToSettings,
          goToSettingsDescription: i18n.goToSettingDescription,
        ),
      );
      _handleAuthenticationResult(isAuthenticated, translations);
    } catch (e) {
      SystemNavigator.pop();
    }
  }

  Future<void> _authenticateViaPassword(BackgroundTranslations translations) async {
    var isAuthenticated = await showModalBottomSheet<bool?>(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: false,
      isScrollControlled: true,
      builder: (ctx) => const PasswordBottomSheet(promptForPassword: true),
    );

    isAuthenticated ??= false;

    _handleAuthenticationResult(isAuthenticated, translations);
  }

  void _handleAuthenticationResult(bool isAuthenticated, BackgroundTranslations translations) {
    if (!mounted) {
      return;
    }

    if (isAuthenticated) {
      context.read<AppBloc>().add(AppEvent.init(bgTaskIsRunning: false, translations: translations));
    } else {
      context.read<SplashScreenBloc>().add(const SplashScreenEvent.init());
    }
  }
}
