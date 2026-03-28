import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class RestartWarning extends StatelessWidget {
  const RestartWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Padding(
      padding: Styles.edgeInsetHorizontal16,
      child: Row(
      children: [
        Icon(Icons.info_outline, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            i18n.changesApplyOnNextLaunch,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
      ),
    );
  }
}
