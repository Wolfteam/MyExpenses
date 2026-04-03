import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/presentation/charts/widgets/empty_chart_preview.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';

class IncomeExpenseMiniPreview extends StatelessWidget with TransactionMixin {
  const IncomeExpenseMiniPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartsBloc, ChartsState>(
      builder: (context, state) {
        if (state is! ChartsStateLoaded || state.monthlyPoints.isEmpty) {
          return const EmptyChartPreview(icon: Icons.bar_chart);
        }
        final points = state.monthlyPoints.length > 6
            ? state.monthlyPoints.sublist(state.monthlyPoints.length - 6)
            : state.monthlyPoints;
        final incomeColor = getTransactionColor(isAnIncome: true);
        final expenseColor = getTransactionColor();
        double maxY = 10;
        final barGroups = <BarChartGroupData>[];
        for (int i = 0; i < points.length; i++) {
          final p = points[i];
          final expAbs = p.expense.abs();
          if (p.income > maxY) maxY = p.income;
          if (expAbs > maxY) maxY = expAbs;
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: p.income, color: incomeColor, width: 5),
                BarChartRodData(toY: expAbs, color: expenseColor, width: 5),
              ],
            ),
          );
        }
        return BarChart(
          BarChartData(
            maxY: maxY * 1.1,
            barGroups: barGroups,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              rightTitles: AxisTitles(),
              topTitles: AxisTitles(),
              leftTitles: AxisTitles(),
              bottomTitles: AxisTitles(),
            ),
          ),
        );
      },
    );
  }
}
