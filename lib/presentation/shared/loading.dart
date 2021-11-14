import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Center(
            child: CircularProgressIndicator(),
          ),
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
