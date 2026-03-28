import 'package:flutter/material.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget preview;
  final VoidCallback onTap;

  const ChartCard({
    super.key,
    required this.title,
    required this.icon,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: Styles.edgeInsetAll10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(height: 100, child: IgnorePointer(child: preview)),
            ],
          ),
        ),
      ),
    );
  }
}
