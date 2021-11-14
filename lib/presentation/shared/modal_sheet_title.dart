import 'package:flutter/material.dart';

class ModalSheetTitle extends StatelessWidget {
  final String title;
  final EdgeInsets padding;
  const ModalSheetTitle({
    Key? key,
    required this.title,
    this.padding = const EdgeInsets.only(bottom: 20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(title, style: Theme.of(context).textTheme.headline6),
    );
  }
}
