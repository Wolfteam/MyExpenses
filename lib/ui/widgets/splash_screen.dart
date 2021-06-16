import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../bloc/app/app_bloc.dart';
import '../../bloc/splash_screen/splash_screen_bloc.dart';
import '../../common/presentation/custom_assets.dart';
import 'settings/password_bottom_sheet.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashScreenBloc, SplashScreenState>(
      listener: (ctx, state) async {
        await state.map(
          initial: (state) async {
            if (state.askForFingerPrint) {
              await _authenticateViaFingerPrint(ctx);
            } else if (state.askForPassword) {
              await _authenticateViaPassword(ctx);
            } else {
              ctx.read<AppBloc>().add(const AppEvent.init(bgTaskIsRunning: false));
            }
          },
        );
      },
      builder: (ctx, state) => Container(
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

  Future<void> _authenticateViaFingerPrint(BuildContext context) async {
    //this one is required, for the language change
    await Future.delayed(const Duration(seconds: 1));

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
      _handleAuthenticationResult(context, isAuthenticated);
    } catch (e) {
      SystemNavigator.pop();
    }
  }

  Future<void> _authenticateViaPassword(BuildContext context) async {
    var isAuthenticated = await showModalBottomSheet<bool?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(35),
          topLeft: Radius.circular(35),
        ),
      ),
      isDismissible: false,
      isScrollControlled: true,
      builder: (ctx) => const PasswordBottomSheet(promptForPassword: true),
    );

    isAuthenticated ??= false;

    _handleAuthenticationResult(context, isAuthenticated);
  }

  void _handleAuthenticationResult(BuildContext context, bool isAuthenticated) {
    if (isAuthenticated) {
      context.read<AppBloc>().add(const AppEvent.init(bgTaskIsRunning: false));
    } else {
      context.read<SplashScreenBloc>().add(const SplashScreenEvent.init());
    }
  }
}
