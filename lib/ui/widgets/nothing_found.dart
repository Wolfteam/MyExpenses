import 'package:flutter/material.dart';

class NothingFound extends StatelessWidget {
  final String msg;
  final EdgeInsets padding;

  const NothingFound({
    @required this.msg,
    this.padding = const EdgeInsets.only(bottom: 30, right: 20, left: 20),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          children: <Widget>[
            Icon(
              Icons.info,
              color: theme.primaryColor,
              size: 60,
            ),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: theme.textTheme.title,
            ),
          ],
        ),
      ),
    );
  }
}
