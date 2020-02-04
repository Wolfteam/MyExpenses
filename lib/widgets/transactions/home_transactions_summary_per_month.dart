import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../models/transactions_summary_per_month.dart';

class HomeTransactionSummaryPerMonth extends StatelessWidget {
  final data = [
    TransactionsSummaryPerMonth(0, 40),
    TransactionsSummaryPerMonth(1, -60),
  ];

  List<charts.Series<TransactionsSummaryPerMonth, int>> _createSampleData() {
    return [
      new charts.Series<TransactionsSummaryPerMonth, int>(
        id: 'HomeTransactionsSummaryPerMonth',
        data: data,
        domainFn: (item, _) => item.order,
        //The values here must be positives and the sum of them must be equal to 100%
        measureFn: (item, _) => item.amount.abs(),
        colorFn: (item, _) => charts.ColorUtil.fromDartColor(item.color),
        labelAccessorFn: (row, _) => '${row.amount}',
      )
    ];
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
      child: Text(
        "January",
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      // color: Colors.brown,
      width: 140,
      height: 140,
      child: charts.PieChart(
        _createSampleData(),
        animate: true,
        defaultRenderer: new charts.ArcRendererConfig(
          // arcWidth: 20,
          // minHoleWidthForCenterContent: 10,
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

  Widget _buildSummary() {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    final expenseTextStyle = textStyle.copyWith(color: Colors.red);
    final incomeTextStyle = textStyle.copyWith(color: Colors.green);

    return Expanded(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "Income:",
                      style: textStyle,
                    ),
                    Text(
                      "Expense:",
                      style: textStyle,
                    ),
                    Text(
                      "Total:",
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "\$ 240000",
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      style: incomeTextStyle,
                    ),
                    Text(
                      "\$ -800",
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      style: expenseTextStyle,
                    ),
                    Text(
                      "\$ 1600",
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      style: incomeTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          // bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(60),
          // topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildTitle(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildPieChart(),
                _buildSummary(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
