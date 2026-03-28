import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/estimates/estimate_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/reports/reports_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/sliver_loading.dart';
import 'package:my_expenses/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/transaction_popupmenu_filter.dart';
import 'package:my_expenses/presentation/transactions/widgets/transactions_card_container.dart';

enum _SummaryAction { reports, estimates }

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
      builder: (context, state) {
        switch (state) {
          case TransactionsStateLoadingState():
            return const SliverLoading();
          case TransactionsStateLoadedState():
            final List<TransactionCardItems> transactions =
                _showRecurringTransactions
                    ? state.recurringTransactions
                    : state.groupingType == TransactionFilterType.category
                    ? state.groupedTransactionsByCategory
                    : state.groupingType == TransactionFilterType.paymentMethod
                    ? state.groupedTransactionsByPaymentMethod
                    : state.transactions;
            return SliverPadding(
              padding: Styles.edgeInsetVertical10,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == 0) {
                    return _Switch(
                      showRecurringTransactions: _showRecurringTransactions,
                      groupingType: state.groupingType,
                      sortDirectionType: state.sortDirectionType,
                      onTap:
                          () => setState(() {
                            _showRecurringTransactions = !_showRecurringTransactions;
                          }),
                    );
                  }

                  if (transactions.isEmpty) {
                    return NothingFound(
                      msg: _showRecurringTransactions ? i18n.noRecurringTransactionsWereFound : i18n.noTransactionsForThisPeriod,
                    );
                  }

                  final TransactionCardItems group = transactions[index - 1];
                  return (state.groupingType == TransactionFilterType.category ||
                          state.groupingType == TransactionFilterType.paymentMethod)
                      ? CategoryGroupedTransactionsCardContainer(group: group)
                      : TransactionsCardContainer(model: group);
                }, childCount: transactions.length + 1),
              ),
            );
        }
      },
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
        IconButton(icon: const Icon(Icons.swap_horiz), onPressed: onTap),
        if (!showRecurringTransactions)
          TransactionPopupMenuFilter(
            selectedValue: groupingType,
            exclude: const [TransactionFilterType.amount, TransactionFilterType.description],
            onSelected: (newValue) => context.read<TransactionsBloc>().add(TransactionsEvent.groupingTypeChanged(type: newValue)),
          ),
        if (!showRecurringTransactions)
          SortDirectionPopupMenuFilter(
            selectedSortDirection: sortDirectionType,
            onSelected:
                (newValue) => context.read<TransactionsBloc>().add(TransactionsEvent.sortDirectionTypeChanged(type: newValue)),
          ),
        if (!showRecurringTransactions)
          ClipRRect(
            borderRadius: Styles.popupMenuButtonRadius,
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton<_SummaryAction>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert),
                onSelected: (action) => _onActionSelected(context, action),
                tooltip: i18n.moreOptions,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _SummaryAction.reports,
                    child: Row(children: [const Icon(Icons.insert_drive_file), const SizedBox(width: 8), Text(i18n.reports)]),
                  ),
                  PopupMenuItem(
                    value: _SummaryAction.estimates,
                    child: Row(children: [const Icon(Icons.attach_money), const SizedBox(width: 8), Text(i18n.estimates)]),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _onActionSelected(BuildContext context, _SummaryAction action) {
    switch (action) {
      case _SummaryAction.reports:
        showModalBottomSheet(
          shape: Styles.modalBottomSheetShape,
          isScrollControlled: true,
          context: context,
          builder: (_) => ReportsBottomSheetDialog(),
        );
      case _SummaryAction.estimates:
        showModalBottomSheet(
          shape: Styles.modalBottomSheetShape,
          isScrollControlled: true,
          context: context,
          builder: (_) => EstimateBottomSheetDialog(),
        );
    }
  }
}
