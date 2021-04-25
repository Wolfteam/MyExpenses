import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/bloc/currency/currency_bloc.dart';

import '../../../models/chart_transaction_item.dart';
// import '../custom_arc_renderer.dart';

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
    final theme = Theme.of(context);

    final onlyIncomes = chartData.any((t) => t.isAnIncome);

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

    //
    // return [
    //   charts.Series<ChartTransactionItem, int>(
    //     id: onlyIncomes ? 'IncomesPieChart' : 'ExpensesPieChart',
    //     data: dataToUse,
    //     domainFn: (item, _) => item.order,
    //     //The values here must be positives and the sum of them must be equal to 100%
    //     measureFn: (item, _) => item.value.abs(),
    //     colorFn: (item, _) => charts.ColorUtil.fromDartColor(item.categoryColor ?? item.transactionColor),
    //     labelAccessorFn: (item, _) => item.dummyItem ? currencyBloc.format(0) : currencyBloc.format(item.value),
    //     insideLabelStyleAccessorFn: (item, _) => labelsStyle,
    //     outsideLabelStyleAccessorFn: (item, _) => labelsStyle,
    //   )
    // ];
  }

// List<charts.Series<ChartTransactionItem, int>> _createSampleDataForPieChart(
//   BuildContext context,
// ) {
//   final theme = Theme.of(context);
//
//   final onlyIncomes = chartData.any((t) => t.isAnIncome);
//   final labelsStyle = charts.TextStyleSpec(
//     color: charts.ColorUtil.fromDartColor(
//       theme.brightness == Brightness.dark ? Colors.white : Colors.black,
//     ),
//   );
//
//   final currencyBloc = context.watch<CurrencyBloc>();
//
//   final dataToUse = chartData.isEmpty ? const [ChartTransactionItem(value: 100, order: 1, dummyItem: true)] : chartData;
//
//   return [
//     charts.Series<ChartTransactionItem, int>(
//       id: onlyIncomes ? 'IncomesPieChart' : 'ExpensesPieChart',
//       data: dataToUse,
//       domainFn: (item, _) => item.order,
//       //The values here must be positives and the sum of them must be equal to 100%
//       measureFn: (item, _) => item.value.abs(),
//       colorFn: (item, _) => charts.ColorUtil.fromDartColor(item.categoryColor ?? item.transactionColor),
//       labelAccessorFn: (item, _) => item.dummyItem ? currencyBloc.format(0) : currencyBloc.format(item.value),
//       insideLabelStyleAccessorFn: (item, _) => labelsStyle,
//       outsideLabelStyleAccessorFn: (item, _) => labelsStyle,
//     )
//   ];
// }

// Widget _buildPieChart(List<charts.Series<ChartTransactionItem, int>> data) {
//   return Container(
//     height: chartHeight,
//     transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
//     child: charts.PieChart(
//       data,
//       animate: true,
//       defaultRenderer: CustomArcRendererConfig(
//         arcRatio: arcRatio,
//         strokeWidthPx: 0.0,
//         arcRendererDecorators: [charts.ArcLabelDecorator()],
//       ),
//     ),
//   );
// }
}
