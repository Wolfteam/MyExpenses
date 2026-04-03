import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';

class MonthlyBreakdownBarChart extends StatelessWidget with TransactionMixin {
  final List<TransactionActivityPerDate> points;

  const MonthlyBreakdownBarChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incomeColor = getTransactionColor(isAnIncome: true);
    final expenseColor = getTransactionColor();

    final barGroups = <BarChartGroupData>[];
    double maxY = 10;
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final expAbs = p.expense.abs();
      if (p.income > maxY) maxY = p.income;
      if (expAbs > maxY) maxY = expAbs;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: p.income, color: incomeColor, width: 8),
            BarChartRodData(toY: expAbs, color: expenseColor, width: 8),
          ],
        ),
      );
    }

    return BarChart(
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    meta.formattedValue,
                    style: theme.textTheme.labelSmall,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                );
              },
            ),
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
    );
  }
}
