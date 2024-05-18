import 'dart:math' as math;

import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart';

class YearlyChart extends StatelessWidget {
  final int year;
  final List<TransactionsSummaryPerYear> transactions;

  const YearlyChart({super.key, required this.year, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CurrencyBloc>();
    final accentColor = Theme.of(context).colorScheme.secondary;
    final gradientColors = [
      accentColor.withOpacity(0.5),
      accentColor,
    ];
    final double aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 1.5 : 2;
    final gridColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    final spots = transactions.map((e) => FlSpot(e.month - 1, e.totalAmount)).toList();

    final double maxValue = transactions.isEmpty ? 0 : transactions.map((e) => e.totalAmount.abs()).max();
    final double yMaxValue = maxValue == 0 ? 10 : maxValue + 0.3 * maxValue;
    final double yInterval = yMaxValue / 5;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 0.5),
              getDrawingVerticalLine: (value) => FlLine(color: gridColor, strokeWidth: 0.5),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) => Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Transform.rotate(
                      angle: math.pi / 6,
                      child: Text(
                        DateFormat('MMM').format(DateTime(year, (value + 1).toInt())),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) => Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Text(
                      meta.formattedValue,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: gridColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  reservedSize: 40,
                ),
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: gridColor, width: 0.5)),
            minX: 0,
            maxX: 11,
            minY: -yMaxValue,
            maxY: yMaxValue,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (value) => value
                    .map((e) => LineTooltipItem(bloc.format(e.y), TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: gridColor)))
                    .toList(),
                getTooltipColor: (_) => accentColor,
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                gradient: LinearGradient(colors: gradientColors),
                barWidth: 3,
                isStrokeCapRound: true,
                shadow: Shadow(color: accentColor),
                dotData: FlDotData(
                  getDotPainter: (x, y, z, w) => FlDotCirclePainter(color: Colors.white, strokeColor: Colors.black),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(colors: gradientColors.map((color) => color.withOpacity(0.3)).toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
