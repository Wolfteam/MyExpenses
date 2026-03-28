import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/charts/payment_method_chart_item.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class PaymentMethodChartContent extends StatelessWidget {
  final List<PaymentMethodChartItem> methods;

  const PaymentMethodChartContent({super.key, required this.methods});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Styles.edgeInsetAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: methods.map((item) {
                  final showLabel = item.percentage >= 5.0;
                  final color = item.iconColor ?? Colors.grey;
                  final luminance = color.computeLuminance();
                  final textColor = luminance > 0.4 ? Colors.black : Colors.white;
                  return PieChartSectionData(
                    color: color,
                    value: item.total,
                    title: showLabel ? '${item.percentage.toStringAsFixed(1)}%' : '',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...methods.map((item) => _PaymentMethodRow(item: item)),
        ],
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  final PaymentMethodChartItem item;

  const _PaymentMethodRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final currencyBloc = context.read<CurrencyBloc>();
    final color = item.iconColor ?? Colors.grey;
    final displayName = item.methodName.isEmpty ? i18n.noPaymentMethod : item.methodName;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (item.icon != null)
            Icon(item.icon, size: 14, color: color)
          else
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          if (item.icon != null) const SizedBox(width: 8),
          Expanded(
            child: Text(displayName, style: theme.textTheme.bodyMedium),
          ),
          Text(
            currencyBloc.format(item.total),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              '${item.percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
