import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/presentation/charts/widgets/empty_chart_preview.dart';

class TrendMiniPreview extends StatelessWidget {
  const TrendMiniPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartsBloc, ChartsState>(
      builder: (context, state) {
        if (state is! ChartsStateLoaded || state.monthlyPoints.length < 2) {
          return const EmptyChartPreview(icon: Icons.show_chart);
        }
        final points = state.monthlyPoints.length > 8
            ? state.monthlyPoints.sublist(state.monthlyPoints.length - 8)
            : state.monthlyPoints;
        final spots = <FlSpot>[];
        double yMin = 0;
        double yMax = 10;
        for (int i = 0; i < points.length; i++) {
          final balance = points[i].balance;
          spots.add(FlSpot(i.toDouble(), balance));
          if (balance < yMin) yMin = balance;
          if (balance > yMax) yMax = balance;
        }
        final accentColor = Theme.of(context).colorScheme.secondary;
        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              rightTitles: AxisTitles(),
              topTitles: AxisTitles(),
              leftTitles: AxisTitles(),
              bottomTitles: AxisTitles(),
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
                barWidth: 2,
                belowBarData: BarAreaData(
                  show: true,
                  color: accentColor.withValues(alpha: 0.2),
                ),
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        );
      },
    );
  }
}
