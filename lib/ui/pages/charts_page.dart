import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:my_expenses/generated/i18n.dart';

import '../../models/transactions_summary_per_date.dart';
import '../widgets/charts/pie_chart_transactions_per_month.dart';
import 'chart_details_page.dart';

class ChartsPage extends StatelessWidget {
  final barChartData = [
    TransactionsSummaryPerDate(
      10,
      DateTime.now().add(Duration(days: -1)),
      DateTime.now().add(Duration(days: 5)),
    ),
    TransactionsSummaryPerDate(
      -15,
      DateTime.now().add(Duration(days: 6)),
      DateTime.now().add(Duration(days: 11)),
    ),
    TransactionsSummaryPerDate(
      30,
      DateTime.now().add(Duration(days: 12)),
      DateTime.now().add(Duration(days: 17)),
    ),
    TransactionsSummaryPerDate(
      400,
      DateTime.now().add(Duration(days: 18)),
      DateTime.now().add(Duration(days: 23)),
    ),
    TransactionsSummaryPerDate(
      -100,
      DateTime.now().add(Duration(days: 19)),
      DateTime.now().add(Duration(days: 24)),
    ),
    TransactionsSummaryPerDate(
      50,
      DateTime.now().add(Duration(days: 25)),
      DateTime.now().add(Duration(days: 30)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(
          top: 10,
          right: 10,
          left: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                '${i18n.incomes} & ${i18n.expenses}',
                style: Theme.of(context).textTheme.title,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FlatButton.icon(
                onPressed: () {},
                icon: Icon(Icons.calendar_today),
                label: Text("January 2020"),
              ),
            ),
            _buildBarChart(context),
            _buildIncomesAndExpensesCharts(context),
          ],
        ),
      ),
    );
  }

  List<charts.Series<TransactionsSummaryPerDate, String>>
      _createSampleDataForBarChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelStyle = charts.TextStyleSpec(
      color: charts.ColorUtil.fromDartColor(
        isDark ? Colors.white : Colors.black,
      ),
    );
    return [
      charts.Series<TransactionsSummaryPerDate, String>(
        id: 'BarChartMonthSummary',
        data: barChartData,
        colorFn: (sales, _) => sales.isAnIncome
            ? charts.MaterialPalette.green.shadeDefault
            : charts.MaterialPalette.red.shadeDefault,
        domainFn: (sales, _) => sales.dateRange,
        measureFn: (sales, _) => sales.amount,
        insideLabelStyleAccessorFn: (item, index) => labelStyle,
        outsideLabelStyleAccessorFn: (item, index) => labelStyle,
        labelAccessorFn: (sales, _) => '${sales.amount}\$',
      ),
    ];
  }

  Widget _buildBarChart(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 30),
      child: charts.BarChart(
        _createSampleDataForBarChart(context),
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
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomesAndExpensesCharts(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    final titleStyle = theme.textTheme.subtitle;
    final textStyle = theme.textTheme.title;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: Text(
                  i18n.incomes,
                  style: titleStyle,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: Text(
                  "2400 \$",
                  style: textStyle.copyWith(color: Colors.green),
                ),
              ),
              PieChartTransactionsPerMonths(true),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: OutlineButton.icon(
                  onPressed: () {
                    _goToDetailsPage(context, true);
                  },
                  icon: Icon(Icons.chevron_right),
                  label: Text(i18n.details),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: Text(
                  i18n.expenses,
                  style: titleStyle,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: Text(
                  "-800 \$",
                  style: textStyle.copyWith(color: Colors.red),
                ),
              ),
              PieChartTransactionsPerMonths(false),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: OutlineButton.icon(
                  onPressed: () {
                    _goToDetailsPage(context, false);
                  },
                  icon: Icon(Icons.chevron_right),
                  label: Text(i18n.details),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _goToDetailsPage(BuildContext context, bool onlyIncomes) {
    final route = MaterialPageRoute(
      builder: (ctx) => ChartDetailsPage(onlyIncomes: onlyIncomes),
    );

    Navigator.of(context).push(route);
  }
}
