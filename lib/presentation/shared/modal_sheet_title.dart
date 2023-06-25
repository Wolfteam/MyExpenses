import 'package:flutter/material.dart';

class ModalSheetTitle extends StatelessWidget {
  final String title;
  final EdgeInsets padding;
  const ModalSheetTitle({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(bottom: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
