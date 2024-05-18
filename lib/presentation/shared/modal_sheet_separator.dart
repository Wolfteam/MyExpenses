import 'package:flutter/material.dart';

class ModalSheetSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: FractionallySizedBox(
          widthFactor: 0.3,
          child: SizedBox(
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
