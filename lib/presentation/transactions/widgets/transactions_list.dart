import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/sliver_loading.dart';
import 'package:my_expenses/presentation/transactions/widgets/transactions_card_container.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList();

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  bool _showRecurringTransactions = false;

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) => state.maybeMap(
        loaded: (state) {
          final transactions = _showRecurringTransactions ? state.recurringTransactions : state.transactions;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => index == 0
                  ? _Switch(
                      showRecurringTransactions: _showRecurringTransactions,
                      onTap: () => setState(() {
                        _showRecurringTransactions = !_showRecurringTransactions;
                      }),
                    )
                  : transactions.isEmpty
                      ? NothingFound(msg: _showRecurringTransactions ? i18n.noRecurringTransactionsWereFound : i18n.noTransactionsForThisPeriod)
                      : TransactionsCardContainer(model: transactions[index - 1]),
              childCount: transactions.length + 1,
            ),
          );
        },
        orElse: () => const SliverLoading(),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool showRecurringTransactions;
  final GestureTapCallback onTap;

  const _Switch({
    required this.showRecurringTransactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          showRecurringTransactions ? i18n.recurringTransactions : i18n.transactions,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          onPressed: onTap,
        ),
      ],
    );
  }
}
