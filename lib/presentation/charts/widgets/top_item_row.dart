import 'package:flutter/material.dart';

class TopItemRow extends StatelessWidget {
  final String displayName;
  final IconData icon;
  final Color iconColor;
  final double percentage;

  const TopItemRow({
    required this.displayName,
    required this.icon,
    required this.iconColor,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          Expanded(
            child: Text(
              displayName,
              style: theme.textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
