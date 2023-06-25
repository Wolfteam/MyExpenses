import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';

class HomeTransactionSummaryPerMonth extends StatelessWidget {
  final String month;
  final double expenses;
  final double incomes;
  final double total;
  final List<TransactionsSummaryPerMonth> data;
  final DateTime currentDate;
  final Locale locale;

  const HomeTransactionSummaryPerMonth({
    required this.month,
    required this.expenses,
    required this.incomes,
    required this.total,
    required this.data,
    required this.currentDate,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildTitle(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildPieChart(context),
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => _changeCurrentDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 180,
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          startDegreeOffset: -90,
          sections: data
              .where((el) => el.percentage != 0)
              .map(
                (e) => PieChartSectionData(
                  color: e.color,
                  value: e.percentage,
                  title: '${e.percentage} %',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final textStyle = theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);
    final expenseTextStyle = textStyle.copyWith(color: Colors.red);
    final incomeTextStyle = textStyle.copyWith(color: Colors.green);

    final currencyBloc = context.watch<CurrencyBloc>();

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
                  Tooltip(
                    message: currencyBloc.format(incomes),
                    child: Text(
                      currencyBloc.format(incomes),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: incomeTextStyle,
                    ),
                  ),
                  Tooltip(
                    message: currencyBloc.format(expenses),
                    child: Text(
                      currencyBloc.format(expenses),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: expenseTextStyle,
                    ),
                  ),
                  Tooltip(
                    message: currencyBloc.format(total),
                    child: Text(
                      currencyBloc.format(total),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: total >= 0 ? incomeTextStyle : expenseTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _changeCurrentDate(BuildContext context) async {
    final darkTheme = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    await showMonthPicker(
      context: context,
      initialDate: currentDate,
      lastDate: DateTime(now.year + 1),
      locale: locale,
      unselectedMonthTextColor: darkTheme ? Colors.white : Colors.black,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      }
      context.read<TransactionsBloc>().add(TransactionsEvent.loadTransactions(inThisDate: selectedDate));
    });
  }
}
