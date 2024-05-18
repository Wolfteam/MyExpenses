import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;

  final String? cancelText;
  final String? okText;
  final VoidCallback onOk;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onOk,
    this.cancelText,
    this.okText,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText ?? s.cancel),
        ),
        FilledButton(
          onPressed: () {
            onOk();
            Navigator.pop(context);
          },
          child: Text(okText ?? s.ok),
        ),
      ],
    );
  }
}
