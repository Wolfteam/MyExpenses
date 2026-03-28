import 'package:flutter/material.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/charts/widgets/legend_dot.dart';
import 'package:my_expenses/presentation/charts/trend_chart/widgets/balance_trend_line_chart.dart';
import 'package:my_expenses/presentation/charts/trend_chart/widgets/monthly_breakdown_bar_chart.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class TrendChartContent extends StatelessWidget with TransactionMixin {
  final List<TransactionActivityPerDate> trendPoints;
  final List<TransactionActivityPerDate> monthlyPoints;

  const TrendChartContent({super.key, required this.trendPoints, required this.monthlyPoints});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final incomeColor = getTransactionColor(isAnIncome: true);
    final expenseColor = getTransactionColor();

    return SingleChildScrollView(
      padding: Styles.edgeInsetAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (trendPoints.isNotEmpty) ...[
            Text(i18n.balanceTrend, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BalanceTrendLineChart(points: trendPoints),
            ),
            const SizedBox(height: 24),
          ],
          if (monthlyPoints.isNotEmpty) ...[
            Text(i18n.monthlyBreakdown, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: MonthlyBreakdownBarChart(points: monthlyPoints),
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
        ],
      ),
    );
  }
}
