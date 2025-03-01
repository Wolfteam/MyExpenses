import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/sliver_loading.dart';
import 'package:my_expenses/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/transaction_popupmenu_filter.dart';
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
          final List<TransactionCardItems> transactions = _showRecurringTransactions
              ? state.recurringTransactions
              : state.groupingType == TransactionFilterType.category
                  ? state.groupedTransactionsByCategory
                  : state.transactions;
          return SliverPadding(
            padding: Styles.edgeInsetVertical10,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    return _Switch(
                      showRecurringTransactions: _showRecurringTransactions,
                      groupingType: state.groupingType,
                      sortDirectionType: state.sortDirectionType,
                      onTap: () => setState(() {
                        _showRecurringTransactions = !_showRecurringTransactions;
                      }),
                    );
                  }

                  if (transactions.isEmpty) {
                    return NothingFound(msg: _showRecurringTransactions ? i18n.noRecurringTransactionsWereFound : i18n.noTransactionsForThisPeriod);
                  }

                  final TransactionCardItems group = transactions[index - 1];
                  return state.groupingType != TransactionFilterType.category ? TransactionsCardContainer(model: group) : CategoryGroupedTransactionsCardContainer(group: group);
                },
                childCount: transactions.length + 1,
              ),
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
  final TransactionFilterType groupingType;
  final SortDirectionType sortDirectionType;
  final GestureTapCallback onTap;

  const _Switch({
    required this.showRecurringTransactions,
    required this.groupingType,
    required this.sortDirectionType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Text(
            showRecurringTransactions ? i18n.recurringTransactions : i18n.transactions,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          onPressed: onTap,
        ),
        if (!showRecurringTransactions)
          TransactionPopupMenuFilter(
            selectedValue: groupingType,
            exclude: const [TransactionFilterType.amount, TransactionFilterType.description],
            onSelected: (newValue) => context.read<TransactionsBloc>().add(TransactionsEvent.groupingTypeChanged(type: newValue)),
          ),
        if (!showRecurringTransactions)
          SortDirectionPopupMenuFilter(
            selectedSortDirection: sortDirectionType,
            onSelected: (newValue) => context.read<TransactionsBloc>().add(TransactionsEvent.sortDirectionTypeChanged(type: newValue)),
          ),
      ],
    );
  }
}
