import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../../models/chart_transaction_item.dart';

class PieChartTransactionsPerMonths extends StatelessWidget {
  final double chartHeight;
  final double arcRatio;
  final List<ChartTransactionItem> chartData;

  const PieChartTransactionsPerMonths(
    this.chartData, [
    this.chartHeight = 200,
    this.arcRatio = 1,
  ]);

  @override
  Widget build(BuildContext context) {
    final data = _createSampleDataForPieChart(context);
    return _buildPieChart(data);
  }

  List<charts.Series<ChartTransactionItem, int>> _createSampleDataForPieChart(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final onlyIncomes = chartData.any((t) => t.isAnIncome);
    final labelsStyle = charts.TextStyleSpec(
      color: charts.ColorUtil.fromDartColor(
        theme.brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
    );

    final dataToUse = chartData.isEmpty
        ? [
            ChartTransactionItem(
              onlyIncomes ? Colors.green : Colors.red,
              amount: 100,
              order: 1,
              dummyItem: true,
            )
          ]
        : chartData;

    return [
      charts.Series<ChartTransactionItem, int>(
        id: onlyIncomes ? 'IncomesPieChart' : 'ExpensesPieChart',
        data: dataToUse,
        domainFn: (item, _) => item.order,
        //The values here must be positives and the sum of them must be equal to 100%
        measureFn: (item, _) => item.amount.abs(),
        colorFn: (item, _) => charts.ColorUtil.fromDartColor(item.color),
        labelAccessorFn: (item, _) =>
            item.dummyItem ? '0 \$' : '${item.amount} \$',
        insideLabelStyleAccessorFn: (item, _) => labelsStyle,
        outsideLabelStyleAccessorFn: (item, _) => labelsStyle,
      )
    ];
  }

  Widget _buildPieChart(List<charts.Series<ChartTransactionItem, int>> data) {
    return Container(
      height: chartHeight,
      child: charts.PieChart(
        data,
        animate: true,
        defaultRenderer: charts.ArcRendererConfig(
          arcRatio: arcRatio,
          arcRendererDecorators: [
            charts.ArcLabelDecorator(
              showLeaderLines: true,
              labelPosition: charts.ArcLabelPosition.auto,
            )
          ],
        ),
      ),
    );
  }
}
