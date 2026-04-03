import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';

class SpendingItemRow extends StatelessWidget {
  final String displayName;
  final IconData icon;
  final Color iconColor;
  final double total;
  final double percentage;

  const SpendingItemRow({
    required this.displayName,
    required this.icon,
    required this.iconColor,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyBloc = context.read<CurrencyBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          Expanded(
            child: Text(displayName, style: theme.textTheme.bodyMedium),
          ),
          Text(
            currencyBloc.format(total),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
