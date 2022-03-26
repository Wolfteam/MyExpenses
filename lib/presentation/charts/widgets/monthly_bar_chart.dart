import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/extensions/iterable_extensions.dart';
import 'package:my_expenses/domain/models/models.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<TransactionsSummaryPerDate> transactionsPerDate;

  const MonthlyBarChart({Key? key, required this.transactionsPerDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final textStyle = TextStyle(color: lineColor, fontWeight: FontWeight.bold, fontSize: 10);
    final currencyBloc = context.read<CurrencyBloc>();
    final maxWastedValue = transactionsPerDate.isEmpty ? 0 : transactionsPerDate.map((e) => e.totalAmount.abs()).max();
    final double maxValue = maxWastedValue == 0 ? 10 : maxWastedValue + 0.3 * maxWastedValue;
    final aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 3 / 2 : 2 / 1;
    final interval = maxValue / 4;
    final double reservedSize = maxValue.toStringAsFixed(2).length * 5;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: maxValue,
            minY: -maxValue,
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  currencyBloc.format(rod.y),
                  TextStyle(color: lineColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                getTextStyles: (ctx, value) => textStyle.copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                rotateAngle: 25,
                getTitles: (double value) {
                  final date = transactionsPerDate.elementAt(value.toInt() - 1);
                  return date.dateRangeString;
                },
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTextStyles: (ctx, value) => textStyle,
                reservedSize: reservedSize,
                interval: interval,
              ),
              rightTitles: SideTitles(showTitles: false),
              topTitles: SideTitles(showTitles: false),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: interval,
              checkToShowHorizontalLine: (value) => true,
              getDrawingHorizontalLine: (value) {
                if (value == 0) {
                  return FlLine(color: lineColor, strokeWidth: 2);
                }
                return FlLine(color: lineColor, strokeWidth: 0.8);
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: transactionsPerDate
                .mapIndex(
                  (e, i) => BarChartGroupData(
                    x: i + 1,
                    showingTooltipIndicators: [0],
                    barRods: [
                      BarChartRodData(
                        y: e.totalAmount,
                        width: 50,
                        borderRadius: BorderRadius.zero,
                        rodStackItems: [BarChartRodStackItem(0, e.totalAmount, e.color)],
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
