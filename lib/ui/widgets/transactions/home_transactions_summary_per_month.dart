import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../../bloc/currency/currency_bloc.dart';
import '../../../bloc/transactions/transactions_bloc.dart';
import '../../../generated/i18n.dart';
import '../../../models/transactions_summary_per_month.dart';
import '../custom_arc_renderer.dart';

class HomeTransactionSummaryPerMonth extends StatelessWidget {
  final String month;
  final double expenses;
  final double incomes;
  final double total;
  final List<TransactionsSummaryPerMonth> data;
  final DateTime currentDate;

  const HomeTransactionSummaryPerMonth({
    @required this.month,
    @required this.expenses,
    @required this.incomes,
    @required this.total,
    @required this.data,
    @required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(60),
        ),
      ),
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
              _buildSummary(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            month,
            style: Theme.of(context).textTheme.title,
          ),
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () => _changeCurrentDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      // color: Colors.brown,
      width: 150,
      height: 150,
      child: charts.PieChart(
        _createSampleData(),
        animate: true,
        defaultRenderer: CustomArcRendererConfig(
          arcRatio: 1,
          strokeWidthPx: 0,
          arcRendererDecorators: [
            charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.inside,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    final textStyle = theme.textTheme.subhead.copyWith(
      fontWeight: FontWeight.bold,
    );
    final expenseTextStyle = textStyle.copyWith(color: Colors.red);
    final incomeTextStyle = textStyle.copyWith(color: Colors.green);

    final currencyBloc = context.bloc<CurrencyBloc>();

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '${i18n.income}:',
                    style: textStyle,
                  ),
                  Text(
                    '${i18n.expense}:',
                    style: textStyle,
                  ),
                  Text(
                    '${i18n.total}:',
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    currencyBloc.format(incomes),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: incomeTextStyle,
                  ),
                  Text(
                    currencyBloc.format(expenses),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: expenseTextStyle,
                  ),
                  Text(
                    currencyBloc.format(total),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: total >= 0 ? incomeTextStyle : expenseTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<charts.Series<TransactionsSummaryPerMonth, int>> _createSampleData() {
    return [
      charts.Series<TransactionsSummaryPerMonth, int>(
        id: 'HomeTransactionsSummaryPerMonth',
        data: data,
        domainFn: (item, _) => item.order,
        //The values here must be positives and the sum of them must be equal to 100%
        measureFn: (item, _) => item.percentage,
        colorFn: (item, _) => charts.ColorUtil.fromDartColor(item.color),
        labelAccessorFn: (row, _) => '${row.percentage} %',
      )
    ];
  }

  Future _changeCurrentDate(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = await showMonthPicker(
      context: context,
      initialDate: currentDate,
      lastDate: DateTime(now.year + 1),
    );

    if (selectedDate == null) return;
    context
        .bloc<TransactionsBloc>()
        .add(GetTransactions(inThisDate: selectedDate));
  }
}
