import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../bloc/chart_details/chart_details_bloc.dart';
import '../../bloc/charts/charts_bloc.dart';
import '../../bloc/currency/currency_bloc.dart';
import '../../common/extensions/iterable_extensions.dart';
import '../../common/utils/i18n_utils.dart';
import '../widgets/charts/pie_chart_transactions_per_month.dart';
import '../widgets/nothing_found.dart';
import 'chart_details_page.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> with AutomaticKeepAliveClientMixin<ChartsPage> {
  bool _didChangeDependencies = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

//TODO: Once this is fixed, this should not be required anymore  https://github.com/flutter/flutter/issues/39872
    if (_didChangeDependencies) return;

    context.read<ChartsBloc>().add(ChartsEvent.loadChart(from: DateTime.now()));
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
    final i18n = S.of(context);

    return state.map(
      loaded: (state) => [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            '${i18n.incomes} & ${i18n.expenses}',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FlatButton.icon(
            onPressed: () => _changeCurrentDate(state),
            icon: const Icon(Icons.calendar_today),
            label: Text(state.currentDateString),
          ),
        ),
        _buildBarChart(context, state),
        if (state.transactions.isNotEmpty)
          _buildIncomesAndExpensesCharts(context, state)
        else
          NothingFound(msg: i18n.noRecurringTransactionsWereFound)
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, ChartsState state) {
    final theme = Theme.of(context);
    final lineColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final textStyle = TextStyle(color: lineColor, fontSize: 10);
    final currencyBloc = context.read<CurrencyBloc>();
    final maxWastedValue = state.transactionsPerDate.isEmpty ? 0 : state.transactionsPerDate.map((e) => e.totalAmount.abs()).max();
    final double maxValue = maxWastedValue == 0 ? 10 : maxWastedValue + 0.3 * maxWastedValue;
    final aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 3 / 2 : 2 / 1;
    final interval = maxValue / 4;
    final double reservedSize = maxValue.toStringAsFixed(2).length * 7;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: maxValue,
            minY: -maxValue,
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent,
                tooltipPadding: const EdgeInsets.all(0),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  currencyBloc.format(rod.y),
                  TextStyle(color: lineColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => textStyle,
                rotateAngle: 30,
                getTitles: (double value) {
                  final date = state.transactionsPerDate.elementAt(value.toInt() - 1);
                  return date.dateRangeString;
                },
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => textStyle,
                reservedSize: reservedSize,
                getTitles: (double value) => currencyBloc.format(value, showSymbol: false),
                interval: interval,
              ),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: interval,
              checkToShowHorizontalLine: (value) => true,
              getDrawingHorizontalLine: (value) {
                if (value == 0) {
                  return FlLine(color: lineColor, strokeWidth: 2);
                }
                return FlLine(color: lineColor, strokeWidth: 0.8);
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: _buildData(state),
          ),
        ),
      ),
    );

    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 30),
      // child: charts.BarChart(
      //   _createSampleDataForBarChart(state),
      //   animate: true,
      //   barRendererDecorator: charts.BarLabelDecorator<String>(),
      //   domainAxis: charts.OrdinalAxisSpec(
      //     showAxisLine: false,
      //     renderSpec: charts.SmallTickRendererSpec(
      //       labelRotation: 45,
      //       axisLineStyle: charts.LineStyleSpec(
      //         color: charts.ColorUtil.fromDartColor(lineColor),
      //         thickness: 5,
      //       ),
      //       labelStyle: charts.TextStyleSpec(
      //         color: charts.ColorUtil.fromDartColor(lineColor),
      //         fontSize: 11,
      //       ),
      //     ),
      //   ),
      //   primaryMeasureAxis: charts.NumericAxisSpec(
      //     showAxisLine: false,
      //     renderSpec: charts.GridlineRendererSpec(
      //       axisLineStyle: charts.LineStyleSpec(
      //         color: charts.ColorUtil.fromDartColor(lineColor),
      //       ),
      //       labelStyle: charts.TextStyleSpec(
      //         color: charts.ColorUtil.fromDartColor(lineColor),
      //       ),
      //       lineStyle: charts.LineStyleSpec(
      //         color: charts.ColorUtil.fromDartColor(lineColor),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  List<BarChartGroupData> _buildData(ChartsState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // final labelStyle = charts.TextStyleSpec(
    //   color: charts.ColorUtil.fromDartColor(
    //     isDark ? Colors.white : Colors.black,
    //   ),
    // );

    final currency = context.read<CurrencyBloc>();

    return state.transactionsPerDate
        .mapIndex(
          (e, i) => BarChartGroupData(
            x: i + 1,
            showingTooltipIndicators: [0],
            barRods: [
              BarChartRodData(
                y: e.totalAmount,
                width: 50,
                borderRadius: const BorderRadius.all(Radius.zero),
                rodStackItems: [
                  BarChartRodStackItem(0, e.totalAmount, e.color),
                ],
              ),
            ],
          ),
        )
        .toList();

    // return [
    //   charts.Series<TransactionsSummaryPerDate, String>(
    //     id: 'BarChartMonthSummary',
    //     data: state.transactionsPerDate,
    //     colorFn: (item, _) => item.totalAmount == 0
    //         ? charts.MaterialPalette.white
    //         : item.isAnIncome
    //             ? charts.MaterialPalette.green.shadeDefault
    //             : charts.MaterialPalette.red.shadeDefault,
    //     domainFn: (item, _) => item.dateRangeString,
    //     measureFn: (item, _) => item.totalAmount,
    //     insideLabelStyleAccessorFn: (item, index) => labelStyle,
    //     outsideLabelStyleAccessorFn: (item, index) => labelStyle,
    //     labelAccessorFn: (item, _) => currency.format(
    //       item.totalAmount,
    //       showSymbol: false,
    //     ),
    //   ),
    // ];
  }

  // List<charts.Series<TransactionsSummaryPerDate, String>> _createSampleDataForBarChart(
  //   LoadedState state,
  // ) {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;
  //
  //   final labelStyle = charts.TextStyleSpec(
  //     color: charts.ColorUtil.fromDartColor(
  //       isDark ? Colors.white : Colors.black,
  //     ),
  //   );
  //
  //   final currency = context.read<CurrencyBloc>();
  //
  //   return [
  //     charts.Series<TransactionsSummaryPerDate, String>(
  //       id: 'BarChartMonthSummary',
  //       data: state.transactionsPerDate,
  //       colorFn: (item, _) => item.totalAmount == 0
  //           ? charts.MaterialPalette.white
  //           : item.isAnIncome
  //               ? charts.MaterialPalette.green.shadeDefault
  //               : charts.MaterialPalette.red.shadeDefault,
  //       domainFn: (item, _) => item.dateRangeString,
  //       measureFn: (item, _) => item.totalAmount,
  //       insideLabelStyleAccessorFn: (item, index) => labelStyle,
  //       outsideLabelStyleAccessorFn: (item, index) => labelStyle,
  //       labelAccessorFn: (item, _) => currency.format(
  //         item.totalAmount,
  //         showSymbol: false,
  //       ),
  //     ),
  //   ];
  // }

  Widget _buildIncomesAndExpensesCharts(BuildContext context, ChartsState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(child: _buildChart(state, true)),
        Expanded(child: _buildChart(state, false)),
      ],
    );
  }

  Widget _buildChart(ChartsState state, bool incomes) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final titleStyle = theme.textTheme.subtitle2;
    final textStyle = theme.textTheme.headline6;
    final dataToUse = incomes ? ChartsState.incomeChartTransactions(state.transactions) : ChartsState.expenseChartTransactions(state.transactions);

    final currencyBloc = context.read<CurrencyBloc>();
    final double aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 3 / 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FlatButton(
          padding: const EdgeInsets.all(0),
          onPressed: () => dataToUse.isNotEmpty ? _goToDetailsPage(context, state, incomes) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Text(incomes ? i18n.incomes : i18n.expenses, style: titleStyle),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Text(
                      currencyBloc.format(incomes ? state.totalIncomeAmount : state.totalExpenseAmount),
                      overflow: TextOverflow.ellipsis,
                      style: textStyle!.copyWith(color: incomes ? Colors.green : Colors.red),
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
        AspectRatio(aspectRatio: aspectRatio, child: PieChartTransactionsPerMonths(dataToUse)),
      ],
    );
  }

  void _goToDetailsPage(BuildContext context, ChartsState state, bool onlyIncomes) {
    final transactions = state.transactions.where((t) => t.category.isAnIncome == onlyIncomes).toList();

    context.read<ChartDetailsBloc>().add(ChartDetailsEvent.initialize(transactions: transactions));

    final route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => ChartDetailsPage(
        onlyIncomes: onlyIncomes,
        chartData: onlyIncomes ? ChartsState.incomeChartTransactions(state.transactions) : ChartsState.expenseChartTransactions(state.transactions),
      ),
    );

    Navigator.of(context).push(route);
  }

  Future<void> _changeCurrentDate(ChartsState state) async {
    final now = DateTime.now();
    final selectedDate = await showMonthPicker(
        context: context,
        initialDate: state.currentDate,
        // firstDate: state.currentDate,
        lastDate: DateTime(now.year + 1),
        locale: currentLocale(state.language));

    if (selectedDate == null) {
      return;
    }
    context.read<ChartsBloc>().add(ChartsEvent.loadChart(from: selectedDate));
  }
}
