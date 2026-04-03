import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/domain/models/charts/payment_method_chart_item.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_colors.dart';
import 'package:my_expenses/presentation/charts/widgets/spending_item_row.dart';
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
    final i18n = S.of(context);
    final icon = item.icon ?? ChartColors.defaultPaymentMethodIcon(item.type);
    final color = item.iconColor ?? ChartColors.defaultColor;
    final displayName = item.methodName.isEmpty ? i18n.noPaymentMethod : item.methodName;
    return SpendingItemRow(
      displayName: displayName,
      icon: icon,
      iconColor: color,
      total: item.total,
      percentage: item.percentage,
    );
  }
}
