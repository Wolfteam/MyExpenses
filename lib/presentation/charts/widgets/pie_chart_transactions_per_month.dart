import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/extensions/iterable_extensions.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

class PieChartTransactionsPerMonths extends StatefulWidget {
  final double arcRatio;
  final List<ChartTransactionItem> chartData;

  const PieChartTransactionsPerMonths(
    this.chartData, [
    this.arcRatio = 0,
  ]);

  @override
  State<PieChartTransactionsPerMonths> createState() => _PieChartTransactionsPerMonthsState();
}

class _PieChartTransactionsPerMonthsState extends State<PieChartTransactionsPerMonths> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final dataToUse = widget.chartData.isEmpty ? const [ChartTransactionItem(value: 100, order: 1, dummyItem: true)] : widget.chartData;
    return PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: widget.arcRatio,
        startDegreeOffset: -90,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sections: _buildData(context, dataToUse),
      ),
    );
  }

  double _getFontSizeToUse(double total, double amount) {
    const double maxFontSize = 15;
    final percentage = amount * 100 / total;
    final newSize = (percentage * maxFontSize / 100) + maxFontSize * 0.7;
    return newSize > maxFontSize ? maxFontSize : newSize;
  }

  List<PieChartSectionData> _buildData(BuildContext context, List<ChartTransactionItem> dataToUse) {
    final currencyBloc = context.watch<CurrencyBloc>();
    final double total = dataToUse.map((e) => e.value).sum();
    return dataToUse.mapIndex(
      (e, i) {
        final percentage = TransactionUtils.roundDouble(e.value * 100 / total);
        final shouldBeHidden = percentage > 25;
        final touched = i == _touchedIndex;
        final title = e.dummyItem ? currencyBloc.format(0) : currencyBloc.format(e.value);
        return PieChartSectionData(
          color: e.categoryColor ?? e.transactionColor,
          value: e.value,
          showTitle: shouldBeHidden || touched,
          title: touched ? '$title ($percentage %)' : title,
          radius: touched && dataToUse.length > 1 ? 120 : 90,
          titleStyle: TextStyle(
            fontSize: _getFontSizeToUse(total.abs(), e.value.abs()),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            backgroundColor: touched ? Colors.black : null,
          ),
        );
      },
    ).toList();
  }
}
