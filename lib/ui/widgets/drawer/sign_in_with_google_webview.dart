import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../../../bloc/drawer/drawer_bloc.dart';
import '../../../bloc/sign_in_with_google/sign_in_with_google_bloc.dart';
import '../../../common/utils/toast_utils.dart';
import '../../../generated/i18n.dart';

class SignInWithGoogleWebView extends StatefulWidget {
  const SignInWithGoogleWebView();

  @override
  _SignInWithGoogleWebViewState createState() =>
      _SignInWithGoogleWebViewState();
}

class _SignInWithGoogleWebViewState extends State<SignInWithGoogleWebView> {
  final _flutterWebviewPlugin = FlutterWebviewPlugin();
  StreamSubscription<String> _onUrlChanged;

  @override
  void initState() {
    super.initState();
    _flutterWebviewPlugin.close();
    _onUrlChanged = _flutterWebviewPlugin.onUrlChanged.listen((url) {
      if (mounted) {
        context.bloc<SignInWithGoogleBloc>().add(UrlChanged(url));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.bloc<SignInWithGoogleBloc>().add(Initialize());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInWithGoogleBloc, SignInWithGoogleState>(
      listener: (ctx, state) {
        final i18n = I18n.of(ctx);
        if (state is InitializedState) {
          if (state.flowCompleted) {
            ctx.bloc<DrawerBloc>().add(const UserSignedIn());
            Navigator.of(ctx).pop();
            _flutterWebviewPlugin.close();
          } else if (!state.isNetworkAvailable) {
            Navigator.of(ctx).pop();
            showWarningToast(i18n.networkIsNotAvailable);
          }
        }
      },
      builder: (ctx, state) => _buildPage(ctx, state),
    );
  }

  @override
  void dispose() {
    _onUrlChanged.cancel();
    super.dispose();
  }

  Widget _buildPage(
    BuildContext context,
    SignInWithGoogleState state,
  ) {
    final i18n = I18n.of(context);

    const indicator = Center(
      child: CircularProgressIndicator(),
    );

    if (state is InitializedState &&
        !state.codeGranted &&
        !state.flowCompleted) {
      final userAgent =
          FlutterUserAgent.webViewUserAgent.replaceAll(RegExp(r'wv'), '');
      return WebviewScaffold(
        url: state.authUrl,
        userAgent: userAgent,
        enableAppScheme: true,
        appCacheEnabled: false,
        clearCache: true,
        ignoreSSLErrors: true,
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(i18n.authenticate),
        ),
        withJavascript: true,
        withLocalStorage: true,
        initialChild: indicator,
      );
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          indicator,
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: Text(
              '${i18n.loading}...',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
