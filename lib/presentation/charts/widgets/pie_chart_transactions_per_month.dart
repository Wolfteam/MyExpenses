import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart';

class PieChartTransactionsPerMonths extends StatelessWidget {
  final double arcRatio;
  final List<ChartTransactionItem> chartData;

  const PieChartTransactionsPerMonths(
    this.chartData, [
    this.arcRatio = 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: arcRatio,
        startDegreeOffset: -90,
        sections: _buildData(context),
      ),
    );
  }

  double _getFontSizeToUse(double total, double amount) {
    const double maxFontSize = 15;
    final percentage = amount * 100 / total;
    final newSize = (percentage * maxFontSize / 100) + maxFontSize * 0.7;
    return newSize > maxFontSize ? maxFontSize : newSize;
  }

  List<PieChartSectionData> _buildData(BuildContext context) {
    final currencyBloc = context.watch<CurrencyBloc>();

    final dataToUse = chartData.isEmpty ? const [ChartTransactionItem(value: 100, order: 1, dummyItem: true)] : chartData;
    final double total = dataToUse.map((e) => e.value).sum();

    return dataToUse
        .map(
          (e) => PieChartSectionData(
            color: e.categoryColor ?? e.transactionColor,
            value: e.value,
            title: e.dummyItem ? currencyBloc.format(0) : currencyBloc.format(e.value),
            radius: 90,
            titleStyle: TextStyle(
              fontSize: _getFontSizeToUse(total.abs(), e.value.abs()),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
        .toList();
  }
}
