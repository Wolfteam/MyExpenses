import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/charts/widgets/income_expense_pie_chart.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/i18n_utils.dart';

class MonthlyBarChart extends StatelessWidget with TransactionMixin {
  final DateTime currentMonthDate;
  final String currentMonthDateString;
  final int currentYear;
  final AppLanguageType language;
  final double totalIncomeAmount;
  final double totalExpenseAmount;
  final List<TransactionItem> transactions;
  final List<TransactionsSummaryPerDate> transactionsPerMonth;

  const MonthlyBarChart({
    required this.currentMonthDate,
    required this.currentMonthDateString,
    required this.currentYear,
    required this.language,
    required this.totalIncomeAmount,
    required this.totalExpenseAmount,
    required this.transactions,
    required this.transactionsPerMonth,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final currencyBloc = context.read<CurrencyBloc>();
    final (TextStyle tooltipTextStyle, BoxDecoration tooltipBoxDecoration, EdgeInsets tooltipPadding) = Styles.getTooltipStyling(context);

    final double monthlyBalance = TransactionUtils.getTotalAmounts(transactionsPerMonth.map((e) => e.totalAmount));
    final List<FlSpot> totalSpots = [];
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];
    double yMaxValue = 10;
    double yMinValue = -10;

    for (int i = 0; i < transactionsPerMonth.length; i++) {
      final double x = i.toDouble();
      final transaction = transactionsPerMonth[i];
      totalSpots.add(FlSpot(x, transaction.totalAmount));
      incomeSpots.add(FlSpot(x, transaction.incomeAmount));
      expenseSpots.add(FlSpot(x, transaction.expenseAmount));

      if (yMaxValue < transaction.incomeAmount) {
        yMaxValue = transaction.incomeAmount;
      }

      if (yMinValue > transaction.expenseAmount) {
        yMinValue = transaction.expenseAmount;
      }
    }

    final dotData = FlDotData(
      getDotPainter: (x, y, z, w) => FlDotCirclePainter(
        color: Colors.white,
        strokeColor: Colors.black,
        strokeWidth: 1,
      ),
    );
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    final List<Color> totalColors = [
      accentColor.withOpacity(0.5),
      accentColor,
    ];
    final Color incomeColor = getTransactionColor(isAnIncome: true);
    final Color expenseColor = getTransactionColor();
    final List<Color> incomeColors = [
      incomeColor.withOpacity(0.5),
      incomeColor,
    ];
    final List<Color> expenseColors = [
      expenseColor.withOpacity(0.5),
      expenseColor,
    ];

    final colorSpotMap = <List<Color>, List<FlSpot>>{
      totalColors: totalSpots,
      incomeColors: incomeSpots,
      expenseColors: expenseSpots,
    };

    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (transactions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: IncomeExpensePieChart.income(
                    transactions: transactions,
                    totalAmount: totalIncomeAmount,
                  ),
                ),
                Expanded(
                  child: IncomeExpensePieChart.expense(
                    transactions: transactions,
                    totalAmount: totalExpenseAmount,
                  ),
                ),
              ],
            ),
          )
        else
          NothingFound(msg: i18n.noRecurringTransactionsWereFound),
      ],
    );
  }

  Future<void> _changeCurrentMonthDate(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = await showMonthPicker(
      context: context,
      initialDate: currentMonthDate,
      lastDate: DateTime(now.year + 1),
      monthPickerDialogSettings: Styles.getMonthPickerDialogSettings(currentLocale(language), context),
    );

    if (selectedDate == null) {
      return;
    }

    if (context.mounted) {
      context.read<ChartsBloc>().add(ChartsEvent.loadChart(selectedMonthDate: selectedDate, selectedYear: currentYear));
    }
  }
}
