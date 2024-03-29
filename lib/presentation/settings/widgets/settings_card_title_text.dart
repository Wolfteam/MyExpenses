import 'package:flutter/material.dart';

class SettingsCardTitleText extends StatelessWidget {
  final String text;
  final Icon icon;
  const SettingsCardTitleText({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        icon,
        Container(
          margin: const EdgeInsets.only(left: 5),
          child: Text(text, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}
