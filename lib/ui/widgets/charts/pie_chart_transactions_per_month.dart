import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../../models/chart_transaction_item.dart';

class PieChartTransactionsPerMonths extends StatelessWidget {
  final pieIncomesChartData = [
    ChartTransactionItem(Colors.red, amount: 20, order: 0),
    ChartTransactionItem(Colors.yellow, amount: 10, order: 1),
    ChartTransactionItem(Colors.blue, amount: 15, order: 2),
    ChartTransactionItem(Colors.green, amount: 5, order: 3),
    ChartTransactionItem(Colors.purple, amount: 5, order: 4),
    ChartTransactionItem(Colors.pink, amount: 25, order: 5),
    ChartTransactionItem(Colors.orange, amount: 20, order: 6),
  ];

  final pieExpensesChartData = [
    ChartTransactionItem(Colors.red, amount: -20, order: 0),
    ChartTransactionItem(Colors.yellow, amount: -10, order: 1),
    ChartTransactionItem(Colors.blue, amount: -15, order: 2),
    ChartTransactionItem(Colors.green, amount: -5, order: 3),
    ChartTransactionItem(Colors.purple, amount: -5, order: 4),
    ChartTransactionItem(Colors.pink, amount: -25, order: 5),
    ChartTransactionItem(Colors.orange, amount: -20, order: 6),
  ];
  final bool onlyIncomes;

  PieChartTransactionsPerMonths(this.onlyIncomes);

  List<charts.Series<ChartTransactionItem, int>> _createSampleDataForPieChart(
      bool onlyIncomes) {
    var data = onlyIncomes ? pieIncomesChartData : pieExpensesChartData;
    return [
      new charts.Series<ChartTransactionItem, int>(
        id: onlyIncomes ? 'IncomesPieChart' : 'ExpensesPieChart',
        data: data,
        domainFn: (item, _) => item.order,
        //The values here must be positives and the sum of them must be equal to 100%
        measureFn: (item, _) => item.amount.abs(),
        colorFn: (item, _) => charts.ColorUtil.fromDartColor(item.color),
        labelAccessorFn: (row, _) => '${row.amount}',
      )
    ];
  }

  Widget _buildPieChart(List<charts.Series<ChartTransactionItem, int>> data) {
    return Container(
      height: 200,
      child: charts.PieChart(
        data,
        animate: true,
        defaultRenderer: new charts.ArcRendererConfig(
          arcRatio: 1,
          arcRendererDecorators: [
            charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.inside,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = _createSampleDataForPieChart(this.onlyIncomes);
    return _buildPieChart(data);
  }
}
