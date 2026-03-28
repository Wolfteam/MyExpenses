import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/charts/widgets/legend_dot.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class IncomeExpenseContent extends StatelessWidget with TransactionMixin {
  final List<TransactionActivityPerDate> points;

  const IncomeExpenseContent({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final incomeColor = getTransactionColor(isAnIncome: true);
    final expenseColor = getTransactionColor();

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: p.income, color: incomeColor, width: 8),
            BarChartRodData(toY: p.expense.abs(), color: expenseColor, width: 8),
          ],
        ),
      );
    }

    final maxY = points.fold<double>(10, (prev, p) {
      final maxVal = p.income > p.expense.abs() ? p.income : p.expense.abs();
      return maxVal > prev ? maxVal : prev;
    });

    return SingleChildScrollView(
      padding: Styles.edgeInsetAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.1,
                barGroups: barGroups,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: theme.dividerColor, strokeWidth: 0.3),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= points.length) {
                          return const SizedBox.shrink();
                        }
                        final label = points[idx].dateRangeString ?? '';
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(label, style: theme.textTheme.labelSmall),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LegendDot(color: incomeColor, label: i18n.income),
              const SizedBox(width: 16),
              LegendDot(color: expenseColor, label: i18n.expenses),
            ],
          ),
        ],
      ),
    );
  }
}
