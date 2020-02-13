import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:my_expenses/common/utils/date_utils.dart';

import '../../models/transactions_summary_per_day.dart';

class HomeLast7DaysSummary extends StatelessWidget {
  final List<TransactionsSummaryPerDay> data;

  const HomeLast7DaysSummary({this.data});

  List<charts.Series<TransactionsSummaryPerDay, String>> _createSampleData() {
    return [
      charts.Series<TransactionsSummaryPerDay, String>(
          id: 'HomeLast7DaysSummary',
          data: data,
          colorFn: (sale, __) => charts.ColorUtil.fromDartColor(sale.color),
          domainFn: (TransactionsSummaryPerDay sales, _) =>
              DateUtils.formatDate(sales.createdAt),
          measureFn: (TransactionsSummaryPerDay sales, _) => sales.amount,
          labelAccessorFn: (TransactionsSummaryPerDay sales, _) =>
              '${sales.amount}\$'),
    ];
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            "Last 7 days",
            style: Theme.of(context).textTheme.title,
          ),
        ),
        PopupMenuButton(
          padding: const EdgeInsets.all(0),
          itemBuilder: (context) => <PopupMenuItem<String>>[
            CheckedPopupMenuItem(
              checked: true,
              value: "Incomes",
              child: Text("Incomes"),
            ),
            CheckedPopupMenuItem(
              value: "Expenses",
              child: Text("Expenses"),
            )
          ],
        )
      ],
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 180,
      child: charts.BarChart(
        _createSampleData(),
        animate: true,
        vertical: true,
        barRendererDecorator: charts.BarLabelDecorator<String>(),
        domainAxis: charts.OrdinalAxisSpec(
          showAxisLine: false,
          renderSpec: charts.SmallTickRendererSpec(
              labelRotation: 45,
              axisLineStyle: charts.LineStyleSpec(
                  color: charts.ColorUtil.fromDartColor(Colors.brown),
                  thickness: 5),
              labelStyle: charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(Colors.red),
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          // bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(60),
          // topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTitle(context),
            _buildBarChart(),
          ],
        ),
      ),
    );
  }
}
