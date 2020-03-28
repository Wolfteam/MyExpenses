import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../bloc/chart_details/chart_details_bloc.dart';
import '../../bloc/charts/charts_bloc.dart';
import '../../generated/i18n.dart';
import '../../models/transactions_summary_per_date.dart';
import '../widgets/charts/pie_chart_transactions_per_month.dart';
import '../widgets/nothing_found.dart';
import 'chart_details_page.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage>
    with AutomaticKeepAliveClientMixin<ChartsPage> {
  bool _didChangeDependencies = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

//TODO: Once this is fixed, this should not be required anymore  https://github.com/flutter/flutter/issues/39872
    if (_didChangeDependencies) return;

    context.bloc<ChartsBloc>().add(LoadChart(DateTime.now()));
    _didChangeDependencies = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: BlocBuilder<ChartsBloc, ChartsState>(
        builder: (ctx, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildPage(context, state),
        ),
      ),
    );
  }

  List<Widget> _buildPage(BuildContext context, ChartsState state) {
    final i18n = I18n.of(context);

    if (state is LoadedState) {
      return [
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
            onPressed: () => _changeCurrentDate(state),
            icon: Icon(Icons.calendar_today),
            label: Text(state.currentDateString),
          ),
        ),
        _buildBarChart(context, state),
        if (state.transactions.isNotEmpty)
          _buildIncomesAndExpensesCharts(context, state)
        else
          NothingFound(msg: i18n.noRecurringTransactionsWereFound)
      ];
    }

    return [
      const Center(
        child: CircularProgressIndicator(),
      )
    ];
  }

  Widget _buildBarChart(
    BuildContext context,
    LoadedState state,
  ) {
    final theme = Theme.of(context);
    final lineColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 30),
      child: charts.BarChart(
        _createSampleDataForBarChart(context, state),
        animate: true,
        vertical: true,
        barRendererDecorator: charts.BarLabelDecorator<String>(),
        domainAxis: charts.OrdinalAxisSpec(
          showAxisLine: false,
          renderSpec: charts.SmallTickRendererSpec(
            labelRotation: 45,
            axisLineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(lineColor),
              thickness: 5,
            ),
            labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(lineColor),
              fontSize: 11,
            ),
          ),
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          showAxisLine: false,
          renderSpec: charts.GridlineRendererSpec(
            axisLineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(lineColor),
            ),
            labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(lineColor),
            ),
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(lineColor),
            ),
          ),
        ),
      ),
    );
  }

  List<charts.Series<TransactionsSummaryPerDate, String>>
      _createSampleDataForBarChart(
    BuildContext context,
    LoadedState state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelStyle = charts.TextStyleSpec(
      color: charts.ColorUtil.fromDartColor(
        isDark ? Colors.white : Colors.black,
      ),
    );
    return [
      charts.Series<TransactionsSummaryPerDate, String>(
        id: 'BarChartMonthSummary',
        data: state.transactionsPerDate,
        colorFn: (item, _) => item.amount == 0
            ? charts.MaterialPalette.white
            : item.isAnIncome
                ? charts.MaterialPalette.green.shadeDefault
                : charts.MaterialPalette.red.shadeDefault,
        domainFn: (item, _) => item.dateRangeString,
        measureFn: (item, _) => item.amount,
        insideLabelStyleAccessorFn: (item, index) => labelStyle,
        outsideLabelStyleAccessorFn: (item, index) => labelStyle,
        labelAccessorFn: (item, _) => '${item.amount}\$',
      ),
    ];
  }

  Widget _buildIncomesAndExpensesCharts(
    BuildContext context,
    LoadedState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildChart(context, state, true),
        ),
        Expanded(
          child: _buildChart(context, state, false),
        ),
      ],
    );
  }

  Widget _buildChart(
    BuildContext context,
    LoadedState state,
    bool incomes,
  ) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final titleStyle = theme.textTheme.subtitle;
    final textStyle = theme.textTheme.title;
    final dataToUse = incomes
        ? state.incomeChartTransactions
        : state.expenseChartTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FlatButton(
          padding: const EdgeInsets.all(0),
          onPressed: () => dataToUse.isNotEmpty
              ? _goToDetailsPage(context, state, incomes)
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Text(
                      incomes ? i18n.incomes : i18n.expenses,
                      style: titleStyle,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Text(
                      '${incomes ? state.totalIncomeAmount : state.totalExpenseAmount} \$',
                      style: textStyle.copyWith(
                        color: incomes ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
        PieChartTransactionsPerMonths(dataToUse),
      ],
    );
  }

  void _goToDetailsPage(
    BuildContext context,
    LoadedState state,
    bool onlyIncomes,
  ) {
    final transactions = state.transactions
        .where((t) => t.category.isAnIncome == onlyIncomes)
        .toList();

    context.bloc<ChartDetailsBloc>().add(Initialize(transactions));

    final route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => ChartDetailsPage(
        onlyIncomes: onlyIncomes,
        chartData: onlyIncomes
            ? state.incomeChartTransactions
            : state.expenseChartTransactions,
      ),
    );

    Navigator.of(context).push(route);
  }

  //TODO: CHANGE THE LOCALE HERE
  Future _changeCurrentDate(LoadedState state) async {
    final now = DateTime.now();
    final selectedDate = await showMonthPicker(
      context: context,
      initialDate: state.currentDate,
      // firstDate: state.currentDate,
      lastDate: DateTime(now.year + 1),
    );

    if (selectedDate == null) return;
    context.bloc<ChartsBloc>().add(LoadChart(selectedDate));
  }
}
