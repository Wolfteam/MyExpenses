import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class ChartsSummaryCards extends StatelessWidget {
  const ChartsSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartsBloc, ChartsState>(
      builder: (context, state) {
        if (state is! ChartsStateLoaded) return const SizedBox.shrink();
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _SummaryCard.income(amount: state.totalIncome)),
                const SizedBox(width: 8),
                Expanded(child: _SummaryCard.expense(amount: state.totalExpense)),
              ],
            ),
            const SizedBox(height: 8),
            _SummaryCard.balance(amount: state.balance),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget with TransactionMixin {
  final double amount;
  final bool? isIncome;

  const _SummaryCard({required this.amount, this.isIncome});
  const _SummaryCard.income({required this.amount}) : isIncome = true;
  const _SummaryCard.expense({required this.amount}) : isIncome = false;
  const _SummaryCard.balance({required this.amount}) : isIncome = null;

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final currencyBloc = context.read<CurrencyBloc>();

    final Color color = isIncome == null
        ? theme.colorScheme.primaryContainer
        : getTransactionColor(isAnIncome: isIncome!);

    final String label = isIncome == null
        ? i18n.balance
        : isIncome!
        ? i18n.income
        : i18n.expenses;

    final IconData icon = isIncome == null
        ? Icons.account_balance_wallet
        : isIncome!
        ? Icons.arrow_circle_up
        : Icons.arrow_circle_down;

    return Card(
      color: color,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyBloc.format(amount),
                    style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(label, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
