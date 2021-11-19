import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_user_agentx/flutter_user_agent.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/shared/loading.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';

class SignInWithGoogleWebView extends StatefulWidget {
  const SignInWithGoogleWebView();

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (ctx) => BlocProvider<SignInWithGoogleBloc>(
        create: (ctx) => Injection.signInWithGoogleBloc..add(const SignInWithGoogleEvent.init()),
        child: const SignInWithGoogleWebView(),
      ),
    );
  }

  @override
  _SignInWithGoogleWebViewState createState() => _SignInWithGoogleWebViewState();
}

class _SignInWithGoogleWebViewState extends State<SignInWithGoogleWebView> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<SignInWithGoogleBloc, SignInWithGoogleState>(
      listener: _handleStateChanges,
      builder: (ctx, state) => state.maybeMap(
        initial: (state) {
          if (!state.codeGranted && !state.flowCompleted) {
            return Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    leading: const BackButton(),
                    title: Text(s.authenticate),
                  ),
                  body: InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse(state.authUrl)),
                    initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                      ),
                      crossPlatform: InAppWebViewOptions(
                        // preferredContentMode: device == DeviceScreenType.mobile ? UserPreferredContentMode.MOBILE : UserPreferredContentMode.RECOMMENDED,
                        //This may fail on weird devices (chinese ones ?)...
                        userAgent: FlutterUserAgent.webViewUserAgent!.replaceAll(RegExp('wv'), ''),
                        transparentBackground: true,
                      ),
                    ),
                    onLoadStop: (controller, url) async {
                      if (mounted && url != null) {
                        context.read<SignInWithGoogleBloc>().add(SignInWithGoogleEvent.urlChanged(url: url.toString()));
                      }
                      setState(() {
                        _loading = false;
                      });
                    },
                  ),
                ),
                if (_loading) Loading(),
              ],
            );
          }
          return Loading();
        },
        orElse: () => Loading(),
      ),
    );
  }

  void _handleStateChanges(BuildContext ctx, SignInWithGoogleState state) {
    final i18n = S.of(ctx);
    state.maybeMap(
      initial: (state) {
        if (state.flowCompleted) {
          BlocUtils.raiseAllCommonBlocEvents(ctx);
          Navigator.of(ctx).pop();
        } else if (!state.isNetworkAvailable) {
          ToastUtils.showWarningToast(ctx, i18n.networkIsNotAvailable);
          Navigator.of(ctx).pop();
        } else if (state.anErrorOccurred) {
          ToastUtils.showErrorToast(ctx, i18n.unknownErrorOcurred);
        }
      },
      orElse: () {},
    );
  }
}