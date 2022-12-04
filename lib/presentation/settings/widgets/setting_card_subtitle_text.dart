import 'package:flutter/material.dart';

class SettingsCardSubtitleText extends StatelessWidget {
  final String text;
  const SettingsCardSubtitleText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}
