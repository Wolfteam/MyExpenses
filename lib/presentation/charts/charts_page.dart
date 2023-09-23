import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/charts/widgets/income_expense_pie_chart.dart';
import 'package:my_expenses/presentation/charts/widgets/monthly_bar_chart.dart';
import 'package:my_expenses/presentation/charts/widgets/yearly_chart.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/i18n_utils.dart';
import 'package:my_expenses/presentation/shared/year_picker.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

//TODO: MAYBE IMPROVE THIS BLOC AND THE DETAILS ONE
class _ChartsPageState extends State<ChartsPage> with AutomaticKeepAliveClientMixin<ChartsPage>, TransactionMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return SingleChildScrollView(
      padding: Styles.edgeInsetAll10,
      //without this it crashes on windows...
      controller: ScrollController(),
      child: BlocBuilder<ChartsBloc, ChartsState>(
        builder: (ctx, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: state.map(
            loaded: (state) {
              final totalYearlyBalance = TransactionUtils.getTotalAmounts(state.transactionsPerYear.map((e) => e.totalAmount));
              final totalYearlyColor = getTransactionColor(isAnIncome: totalYearlyBalance >= 0);

              final monthlyBalance = TransactionUtils.getTotalAmounts(state.transactionsPerMonth.map((e) => e.totalAmount));
              final monthlyBalanceColor = getTransactionColor(isAnIncome: monthlyBalance >= 0);

              return [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    '${i18n.incomes} & ${i18n.expenses}',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, top: 10),
                  child: Text(
                    i18n.yearly,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: textColor),
                    onPressed: () => _changeCurrentYear(state),
                    icon: const Icon(Icons.calendar_today),
                    label: Text('${state.currentYear}'),
                  ),
                ),
                YearlyChart(year: state.currentYear, transactions: state.transactionsPerYear),
                _ChartBottomBalance(
                  amount: totalYearlyBalance,
                  textColor: totalYearlyColor,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, top: 10),
                  child: Text(
                    i18n.monthly,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (state.transactionsPerMonth.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: textColor),
                      onPressed: () => _changeCurrentMonthDate(state),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(state.currentMonthDateString),
                    ),
                  ),
                if (state.transactionsPerMonth.isNotEmpty)
                  MonthlyBarChart(
                    transactionsPerDate: state.transactionsPerMonth,
                  ),
                if (state.transactionsPerMonth.isNotEmpty)
                  _ChartBottomBalance(
                    amount: monthlyBalance,
                    textColor: monthlyBalanceColor,
                  ),
                if (state.transactions.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: IncomeExpensePieChart.income(
                          transactions: state.transactions,
                          totalAmount: state.totalIncomeAmount,
                        ),
                      ),
                      Expanded(
                        child: IncomeExpensePieChart.expense(
                          transactions: state.transactions,
                          totalAmount: state.totalExpenseAmount,
                        ),
                      ),
                    ],
                  )
                else
                  NothingFound(msg: i18n.noRecurringTransactionsWereFound),
              ];
            },
          ),
        ),
      ),
    );
  }

  Future<void> _changeCurrentMonthDate(ChartsState state) async {
    final darkTheme = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final selectedDate = await showMonthPicker(
      context: context,
      initialDate: state.currentMonthDate,
      // firstDate: state.currentDate,
      lastDate: DateTime(now.year + 1),
      locale: currentLocale(state.language),
      unselectedMonthTextColor: darkTheme ? Colors.white : Colors.black,
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

class _ChartBottomBalance extends StatelessWidget {
  final double amount;
  final Color textColor;

  const _ChartBottomBalance({
    required this.amount,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final currencyBloc = context.read<CurrencyBloc>();
    final formattedAmount = currencyBloc.format(amount);
    return Tooltip(
      message: i18n.balanceX(formattedAmount),
      child: Text(
        i18n.balanceX(formattedAmount),
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium!.copyWith(color: textColor),
      ),
    );
  }
}
