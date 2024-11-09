import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/extensions/iterable_extensions.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class HomeLast7DaysSummary extends StatelessWidget {
  final List<TransactionsSummaryPerDay> incomes;
  final List<TransactionsSummaryPerDay> expenses;

  const HomeLast7DaysSummary({
    required this.incomes,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          i18n.last7Days,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(
          height: 250,
          child: _BarChart(
            incomes: incomes,
            expenses: expenses,
          ),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget with TransactionMixin {
  final List<TransactionsSummaryPerDay> incomes;
  final List<TransactionsSummaryPerDay> expenses;

  _BarChart({
    required this.incomes,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final currencyBloc = context.read<CurrencyBloc>();
    final Color incomesColor = getTransactionColor(isAnIncome: true);
    final Color expensesColor = getTransactionColor();
    final (TextStyle tooltipTextStyle, BoxDecoration tooltipBoxDecoration, EdgeInsets tooltipPadding) = Styles.getTooltipStyling(context);
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (spot) => tooltipBoxDecoration.color!,
            tooltipPadding: tooltipPadding,
            tooltipMargin: 0,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final double incomeAmount = rod.rodStackItems.firstWhere((el) => el.color == incomesColor).toY;
              final double expensesAmount = rod.rodStackItems.firstWhere((el) => el.color == expensesColor).toY;
              return BarTooltipItem(
                '',
                tooltipTextStyle,
                children: [
                  TextSpan(
                    text: '${currencyBloc.format(incomeAmount)}\n',
                    style: tooltipTextStyle.copyWith(color: incomesColor),
                  ),
                  TextSpan(
                    text: currencyBloc.format(expensesAmount),
                    style: tooltipTextStyle.copyWith(color: expensesColor),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                angle: math.pi / 6,
                child: Text(
                  utils.DateUtils.formatDateWithoutLocale(incomes[value.toInt()].date),
                  style: const TextStyle(
                    fontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) {
                  return Container();
                }
                const style = TextStyle(fontSize: 10);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 20,
                  child: Text(
                    meta.formattedValue,
                    style: style,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          checkToShowHorizontalLine: (value) => value % 10 == 0,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(DateTime.daysPerWeek, (i) => i).mapIndex(
          (e, i) {
            final TransactionsSummaryPerDay income = incomes[i];
            final TransactionsSummaryPerDay expense = expenses[i];
            final double max = math.max(income.totalDayAmount, expense.totalDayAmount);
            final incomeItem = BarChartRodStackItem(0, income.totalDayAmount.abs(), incomesColor);
            final expenseItem = BarChartRodStackItem(0, expense.totalDayAmount.abs(), expensesColor);
            final List<BarChartRodStackItem> items = [];
            if (income.totalDayAmount.abs() > expense.totalDayAmount.abs()) {
              items.addAll([incomeItem, expenseItem]);
            } else {
              items.addAll([expenseItem, incomeItem]);
            }
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: math.max(income.totalDayAmount.abs(), expense.totalDayAmount.abs()),
                  width: 30,
                  borderRadius: BorderRadius.zero,
                  rodStackItems: items,
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}
