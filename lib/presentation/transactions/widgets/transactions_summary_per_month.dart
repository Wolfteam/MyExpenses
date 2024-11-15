import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class TransactionSummaryPerMonth extends StatelessWidget with TransactionMixin {
  final String month;
  final double expenses;
  final double incomes;
  final double total;
  final List<TransactionsSummaryPerMonth> data;
  final DateTime currentDate;
  final Locale locale;

  const TransactionSummaryPerMonth({
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
    final double incomePercentage = data.firstWhere((el) => el.isAnIncome).percentage;
    final double expensesPercentage = data.firstWhere((el) => !el.isAnIncome).percentage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              month,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () => _changeCurrentDate(context),
            ),
          ],
        ),
        Padding(
          padding: Styles.edgeInsetHorizontal10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 45,
                child: _SummaryCard.incomes(
                  amount: incomes,
                  percentage: incomePercentage,
                ),
              ),
              const Spacer(flex: 10),
              Expanded(
                flex: 45,
                child: _SummaryCard.expenses(
                  amount: expenses,
                  percentage: expensesPercentage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _changeCurrentDate(BuildContext context) async {
    final now = DateTime.now();
    await showMonthPicker(
      context: context,
      initialDate: currentDate,
      lastDate: DateTime(now.year + 1),
      monthPickerDialogSettings: Styles.getMonthPickerDialogSettings(locale, context),
    ).then((selectedDate) {
      if (selectedDate == null || !context.mounted) {
        return;
      }
      context.read<TransactionsBloc>().add(TransactionsEvent.loadTransactions(inThisDate: selectedDate));
      context.read<TransactionsActivityBloc>().add(TransactionsActivityEvent.dateChanged(date: selectedDate));
    });
  }
}

class _SummaryCard extends StatelessWidget with TransactionMixin {
  final double amount;
  final double percentage;
  final bool isForIncomes;

  const _SummaryCard({
    required this.amount,
    required this.percentage,
    required this.isForIncomes,
  });

  const _SummaryCard.incomes({
    required this.amount,
    required this.percentage,
  }) : isForIncomes = true;

  const _SummaryCard.expenses({
    required this.amount,
    required this.percentage,
  }) : isForIncomes = false;

  @override
  Widget build(BuildContext context) {
    final currencyBloc = context.watch<CurrencyBloc>();
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final textStyle = theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);

    return Card(
      color: getTransactionColor(isAnIncome: isForIncomes),
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(isForIncomes == true ? Icons.arrow_circle_up : Icons.arrow_circle_down),
            const SizedBox(height: 20),
            Tooltip(
              message: currencyBloc.format(amount),
              child: Text(
                currencyBloc.format(amount),
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
            Text(
              isForIncomes ? i18n.income : i18n.expenses,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$percentage %',
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
