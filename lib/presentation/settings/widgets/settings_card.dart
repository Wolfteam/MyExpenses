import 'package:flutter/material.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class SettingsCard extends StatelessWidget {
  final Widget child;

  const SettingsCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: Styles.cardSettingsShape,
      margin: Styles.edgeInsetAll10,
      elevation: Styles.cardElevation,
      child: Container(margin: Styles.edgeInsetAll10, padding: Styles.edgeInsetAll5, child: child),
    );
  }
}
