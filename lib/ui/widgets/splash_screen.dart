import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';

import '../../bloc/app/app_bloc.dart';
import '../../common/presentation/custom_assets.dart';
import '../../generated/i18n.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      context.bloc<AppBloc>().add(const AuthenticateUser());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (ctx, state) async {
        if (state is AuthenticationState && state.askForFingerPrint) {
          //this one is required, for the language change
          await Future.delayed(const Duration(seconds: 1));

          final i18n = I18n.of(ctx);
          final localAuth = LocalAuthentication();
          final didAuthenticate = await localAuth.authenticateWithBiometrics(
            localizedReason: '',
            stickyAuth: true,
            androidAuthStrings: AndroidAuthMessages(
              fingerprintHint: i18n.authenticationFingerprintHint,
              fingerprintNotRecognized:
                  i18n.authenticationFingerprintNotRecognized,
              fingerprintSuccess: i18n.authenticationFingerprintSuccess,
              cancelButton: i18n.cancel,
              signInTitle: i18n.authenticationSignInTitle,
              fingerprintRequiredTitle: i18n.authenticationFingerprintRequired,
              goToSettingsButton: i18n.authenticationGoToSettings,
              goToSettingsDescription:
                  i18n.authenticationGoToSettingDescription,
            ),
          );

          if (didAuthenticate) {
            ctx.bloc<AppBloc>().add(const InitializeApp());
          } else {
            ctx.bloc<AppBloc>().add(const AuthenticateUser());
          }
        } else if (state is! AppInitializedState) {
          ctx.bloc<AppBloc>().add(const InitializeApp());
        }
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
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
