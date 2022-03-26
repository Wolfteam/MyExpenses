import 'package:darq/darq.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/models/transaction_item.dart';
import 'package:my_expenses/models/transactions_summary_per_date.dart';
import 'package:my_expenses/ui/widgets/nothing_found.dart';
import 'package:my_expenses/ui/widgets/year_picker.dart';

import '../../bloc/chart_details/chart_details_bloc.dart';
import '../../bloc/charts/charts_bloc.dart';
import '../../bloc/currency/currency_bloc.dart';
import '../../common/extensions/iterable_extensions.dart';
import '../../common/utils/i18n_utils.dart';
import '../widgets/charts/pie_chart_transactions_per_month.dart';
import 'chart_details_page.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> with AutomaticKeepAliveClientMixin<ChartsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: BlocBuilder<ChartsBloc, ChartsState>(
        builder: (ctx, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: state.map(
            loaded: (state) => [
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  '${i18n.incomes} & ${i18n.expenses}',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 10),
                child: Text(
                  i18n.yearly,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(primary: textColor),
                  onPressed: () => _changeCurrentYear(state),
                  icon: const Icon(Icons.calendar_today),
                  label: Text('${state.currentYear}'),
                ),
              ),
              _YearlyChart(year: state.currentYear, transactions: state.transactionsPerYear),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 10),
                child: Text(
                  i18n.monthly,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(primary: textColor),
                  onPressed: () => _changeCurrentMonthDate(state),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(state.currentMonthDateString),
                ),
              ),
              _MonthlyBarChart(transactionsPerDate: state.transactionsPerMonth),
              if (state.transactions.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: _PieChart.income(
                        transactions: state.transactions,
                        totalAmount: state.totalIncomeAmount,
                      ),
                    ),
                    Expanded(
                      child: _PieChart.expense(
                        transactions: state.transactions,
                        totalAmount: state.totalExpenseAmount,
                      ),
                    )
                  ],
                )
              else
                NothingFound(msg: i18n.noRecurringTransactionsWereFound)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeCurrentMonthDate(ChartsState state) async {
    final now = DateTime.now();
    final selectedDate = await showMonthPicker(
      context: context,
      initialDate: state.currentMonthDate,
      // firstDate: state.currentDate,
      lastDate: DateTime(now.year + 1),
      locale: currentLocale(state.language),
    );

    if (selectedDate == null) {
      return;
    }

    if (mounted) {
      context.read<ChartsBloc>().add(ChartsEvent.loadChart(selectedMonthDate: selectedDate, selectedYear: state.currentYear));
    }
  }

  Future<void> _changeCurrentYear(ChartsState state) async {
    //TODO: THE DATES IN GENERAL SHOULD START FROM THE FIRST TRANSACTION DATE
    final now = DateTime.now();
    final selectedDate = await showYearlyPicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      selectedDate: DateTime(state.currentYear),
    );

    if (selectedDate == null) {
      return;
    }

    if (mounted) {
      context.read<ChartsBloc>().add(ChartsEvent.loadChart(selectedMonthDate: state.currentMonthDate, selectedYear: selectedDate.year));
    }
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final List<TransactionsSummaryPerDate> transactionsPerDate;

  const _MonthlyBarChart({Key? key, required this.transactionsPerDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final textStyle = TextStyle(color: lineColor, fontWeight: FontWeight.bold, fontSize: 10);
    final currencyBloc = context.read<CurrencyBloc>();
    final maxWastedValue = transactionsPerDate.isEmpty ? 0 : transactionsPerDate.map((e) => e.totalAmount.abs()).max();
    final double maxValue = maxWastedValue == 0 ? 10 : maxWastedValue + 0.3 * maxWastedValue;
    final aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 3 / 2 : 2 / 1;
    final interval = maxValue / 4;
    final double reservedSize = maxValue.toStringAsFixed(2).length * 5;

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
                tooltipPadding: EdgeInsets.zero,
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
                getTextStyles: (ctx, value) => textStyle.copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                rotateAngle: 25,
                getTitles: (double value) {
                  final date = transactionsPerDate.elementAt(value.toInt() - 1);
                  return date.dateRangeString;
                },
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTextStyles: (ctx, value) => textStyle,
                reservedSize: reservedSize,
                interval: interval,
              ),
              rightTitles: SideTitles(showTitles: false),
              topTitles: SideTitles(showTitles: false),
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
            barGroups: transactionsPerDate
                .mapIndex(
                  (e, i) => BarChartGroupData(
                    x: i + 1,
                    showingTooltipIndicators: [0],
                    barRods: [
                      BarChartRodData(
                        y: e.totalAmount,
                        width: 50,
                        borderRadius: BorderRadius.zero,
                        rodStackItems: [BarChartRodStackItem(0, e.totalAmount, e.color)],
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  final bool incomes;
  final List<TransactionItem> transactions;
  final double totalAmount;

  const _PieChart({
    Key? key,
    required this.incomes,
    required this.transactions,
    required this.totalAmount,
  }) : super(key: key);

  const _PieChart.income({
    Key? key,
    required this.transactions,
    required this.totalAmount,
  })  : incomes = true,
        super(key: key);

  const _PieChart.expense({
    Key? key,
    required this.transactions,
    required this.totalAmount,
  })  : incomes = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final titleStyle = theme.textTheme.subtitle2;
    final textStyle = theme.textTheme.headline6;
    final dataToUse = incomes ? ChartsState.incomeChartTransactions(transactions) : ChartsState.expenseChartTransactions(transactions);

    final currencyBloc = context.read<CurrencyBloc>();
    final double aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 1.5;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => dataToUse.isNotEmpty ? _goToDetailsPage(context, incomes) : null,
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
                        currencyBloc.format(totalAmount),
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
      ),
    );
  }

  void _goToDetailsPage(BuildContext context, bool onlyIncomes) {
    final filteredTransactions = transactions.where((t) => t.category.isAnIncome == onlyIncomes).toList();

    context.read<ChartDetailsBloc>().add(ChartDetailsEvent.initialize(transactions: filteredTransactions));

    final route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => ChartDetailsPage(
        onlyIncomes: onlyIncomes,
        chartData: onlyIncomes ? ChartsState.incomeChartTransactions(transactions) : ChartsState.expenseChartTransactions(transactions),
      ),
    );

    Navigator.of(context).push(route);
  }
}

class _YearlyChart extends StatelessWidget {
  final int year;
  final List<TransactionsSummaryPerYear> transactions;

  const _YearlyChart({Key? key, required this.year, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CurrencyBloc>();
    final accentColor = Theme.of(context).colorScheme.secondary;
    final gradientColors = [
      accentColor.withOpacity(0.5),
      accentColor,
    ];
    final double aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 1.5 : 2;
    final gridColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    final spots = transactions.map((e) => FlSpot(e.month - 1, e.totalAmount)).toList();

    final double maxValue = transactions.isEmpty ? 0 : transactions.map((e) => e.totalAmount.abs()).max();
    final double yMaxValue = maxValue == 0 ? 10 : maxValue + 0.3 * maxValue;
    final double yInterval = yMaxValue / 5;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 0.5),
              getDrawingVerticalLine: (value) => FlLine(color: gridColor, strokeWidth: 0.5),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: SideTitles(showTitles: false),
              topTitles: SideTitles(showTitles: false),
              bottomTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTextStyles: (context, value) => const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                rotateAngle: 30,
                getTitles: (value) => DateFormat('MMM').format(DateTime(year, (value + 1).toInt())),
              ),
              leftTitles: SideTitles(
                showTitles: true,
                interval: yInterval,
                getTextStyles: (context, value) => TextStyle(
                  color: gridColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                reservedSize: 40,
                margin: 12,
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: gridColor, width: 0.5)),
            minX: 0,
            maxX: 11,
            minY: -yMaxValue,
            maxY: yMaxValue,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (value) => value
                    .map((e) => LineTooltipItem(bloc.format(e.y), TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: gridColor)))
                    .toList(),
                tooltipBgColor: accentColor,
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                colors: gradientColors,
                barWidth: 3,
                isStrokeCapRound: true,
                shadow: Shadow(color: accentColor),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (x, y, z, w) => FlDotCirclePainter(color: Colors.white, strokeColor: Colors.black),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
