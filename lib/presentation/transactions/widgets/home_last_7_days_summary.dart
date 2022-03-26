import 'dart:math' as math;

import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/iterable_extensions.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/transaction_popupmenu_type_filter.dart';

class HomeLast7DaysSummary extends StatelessWidget {
  final TransactionType selectedType;
  final List<TransactionsSummaryPerDay> incomes;
  final List<TransactionsSummaryPerDay> expenses;

  const HomeLast7DaysSummary({
    required this.selectedType,
    required this.incomes,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final incomesIsChecked = selectedType == TransactionType.incomes;
    final aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 3 / 2 : 2 / 1;

    return Card(
      elevation: Styles.cardElevation,
      margin: Styles.edgeInsetAll10,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(60))),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTitle(incomesIsChecked, context),
            AspectRatio(aspectRatio: aspectRatio, child: _buildBarChart(incomesIsChecked, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(bool incomesIsChecked, BuildContext context) {
    final i18n = S.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            i18n.last7Days,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        TransactionPopupMenuTypeFilter(
          selectedValue: selectedType,
          onSelectedValue: (newValue) => _onSelectedTypeChanged(context, TransactionType.values[newValue]),
        ),
      ],
    );
  }

  Widget _buildBarChart(bool incomesIsChecked, BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final finalData = incomesIsChecked ? incomes : expenses;
    final maxWastedValue = finalData.isEmpty ? 0 : finalData.map((e) => e.totalDayAmount.abs()).max();
    final double maxValue = maxWastedValue == 0 ? 10 : maxWastedValue + 5;
    final textStyle = TextStyle(color: lineColor, fontSize: 10);
    final currencyBloc = context.read<CurrencyBloc>();
    final interval = maxValue / 4;
    final double reservedSize = maxValue.toStringAsFixed(2).length * 7;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: incomesIsChecked ? maxValue : 0,
          minY: incomesIsChecked ? -0 : -maxValue,
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 0,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                currencyBloc.format(rod.toY),
                TextStyle(color: lineColor, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Transform.rotate(
                  angle: math.pi / 6,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      utils.DateUtils.formatDateWithoutLocale(finalData.elementAt(value.toInt() - 1).date),
                      style: TextStyle(color: incomesIsChecked ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: reservedSize,
                getTitlesWidget: (value, meta) => Text(currencyBloc.format(value, showSymbol: false), style: textStyle),
                interval: interval,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            checkToShowHorizontalLine: (value) => true,
            getDrawingHorizontalLine: (value) {
              final zeroLine = FlLine(color: lineColor, strokeWidth: 2);
              final otherLine = FlLine(color: lineColor, strokeWidth: 0.8);
              if (incomesIsChecked) {
                return value <= 0 ? zeroLine : otherLine;
              }

              return value >= 0 ? zeroLine : otherLine;
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: finalData
              .mapIndex(
                (e, i) => BarChartGroupData(
                  x: i + 1,
                  showingTooltipIndicators: [0],
                  barRods: [
                    BarChartRodData(
                      toY: e.totalDayAmount,
                      width: 30,
                      borderRadius: BorderRadius.zero,
                      rodStackItems: [
                        BarChartRodStackItem(0, e.totalDayAmount, e.color),
                      ],
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _onSelectedTypeChanged(BuildContext context, TransactionType newValue) =>
      context.read<TransactionsLast7DaysBloc>().add(TransactionsLast7DaysEvent.typeChanged(selectedType: newValue));
}
