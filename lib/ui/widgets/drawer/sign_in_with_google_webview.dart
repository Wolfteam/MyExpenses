import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_agentx/flutter_user_agent.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../../bloc/sign_in_with_google/sign_in_with_google_bloc.dart';
import '../../../common/utils/bloc_utils.dart';
import '../../../common/utils/toast_utils.dart';
import '../loading.dart';

class SignInWithGoogleWebView extends StatefulWidget {
  const SignInWithGoogleWebView();

  @override
  _SignInWithGoogleWebViewState createState() => _SignInWithGoogleWebViewState();
}

class _SignInWithGoogleWebViewState extends State<SignInWithGoogleWebView> {
  final _flutterWebviewPlugin = FlutterWebviewPlugin();
  late StreamSubscription<String> _onUrlChanged;

  @override
  void initState() {
    super.initState();
    _flutterWebviewPlugin.close();
    _onUrlChanged = _flutterWebviewPlugin.onUrlChanged.listen((url) {
      if (mounted) {
        context.read<SignInWithGoogleBloc>().add(SignInWithGoogleEvent.urlChanged(url: url));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<SignInWithGoogleBloc>().add(const SignInWithGoogleEvent.init());
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
    final i18n = S.of(ctx);
    state.maybeMap(
      initial: (state) {
        if (state.flowCompleted) {
          BlocUtils.raiseAllCommonBlocEvents(ctx);
          Navigator.of(ctx).pop();
          _flutterWebviewPlugin.close();
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

  Widget _buildPage(BuildContext context, SignInWithGoogleState state) {
    final i18n = S.of(context);
    return state.maybeMap(
      initial: (state) {
        if (!state.codeGranted && !state.flowCompleted) {
          final userAgent = FlutterUserAgent.webViewUserAgent!.replaceAll(RegExp(r'wv'), '');
          return WebviewScaffold(
            url: state.authUrl,
            userAgent: userAgent,
            clearCache: true,
            debuggingEnabled: true,
            appBar: AppBar(
              leading: const BackButton(),
              title: Text(i18n.authenticate),
            ),
            initialChild: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Loading();
      },
      orElse: () => Loading(),
    );
  }
}
