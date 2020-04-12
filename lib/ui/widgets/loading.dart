import 'package:flutter/material.dart';

import '../../generated/i18n.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
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
