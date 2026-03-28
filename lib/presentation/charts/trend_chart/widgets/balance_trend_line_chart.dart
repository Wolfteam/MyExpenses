import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/domain/models/models.dart';

class BalanceTrendLineChart extends StatelessWidget {
  final List<TransactionActivityPerDate> points;

  const BalanceTrendLineChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    final spots = <FlSpot>[];
    double yMin = 0;
    double yMax = 10;
    for (int i = 0; i < points.length; i++) {
      final balance = points[i].balance;
      spots.add(FlSpot(i.toDouble(), balance));
      if (balance < yMin) yMin = balance;
      if (balance > yMax) yMax = balance;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: theme.dividerColor, strokeWidth: 0.3),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
                final label = points[idx].dateRangeString ?? '';
                return SideTitleWidget(
                  meta: meta,
                  child: Text(label, style: theme.textTheme.labelSmall),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              maxIncluded: false,
              minIncluded: false,
              getTitlesWidget: (value, meta) {
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
        ),
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: yMin,
        maxY: yMax,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: accentColor,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: accentColor.withValues(alpha: 0.2),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
