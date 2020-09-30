import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../../../bloc/sign_in_with_google/sign_in_with_google_bloc.dart';
import '../../../common/utils/bloc_utils.dart';
import '../../../common/utils/toast_utils.dart';
import '../../../generated/i18n.dart';
import '../loading.dart';

class SignInWithGoogleWebView extends StatefulWidget {
  const SignInWithGoogleWebView();

  @override
  _SignInWithGoogleWebViewState createState() => _SignInWithGoogleWebViewState();
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
      listener: _handleStateChanges,
      builder: (ctx, state) => _buildPage(ctx, state),
    );
  }

  @override
  void dispose() {
    _onUrlChanged.cancel();
    super.dispose();
  }

  void _handleStateChanges(BuildContext ctx, SignInWithGoogleState state) {
    if (state is InitializedState) {
      final i18n = I18n.of(ctx);

      if (state.flowCompleted) {
        BlocUtils.raiseAllCommonBlocEvents(ctx);
        Navigator.of(ctx).pop();
        _flutterWebviewPlugin.close();
      } else if (!state.isNetworkAvailable) {
        Navigator.of(ctx).pop();
        showWarningToast(i18n.networkIsNotAvailable);
      } else if (state.anErrorOccurred) {
        showErrorToast(i18n.unknownErrorOcurred);
      }
    }
  }

  Widget _buildPage(
    BuildContext context,
    SignInWithGoogleState state,
  ) {
    final i18n = I18n.of(context);

    if (state is InitializedState && !state.codeGranted && !state.flowCompleted) {
      final userAgent = FlutterUserAgent.webViewUserAgent.replaceAll(RegExp(r'wv'), '');
      return WebviewScaffold(
        url: state.authUrl,
        userAgent: userAgent,
        enableAppScheme: true,
        appCacheEnabled: false,
        clearCache: true,
        debuggingEnabled: true,
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(i18n.authenticate),
        ),
        withJavascript: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Loading();
  }
}
