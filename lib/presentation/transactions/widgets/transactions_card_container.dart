import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart' as models;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/transactions/widgets/transaction_item.dart';

class TransactionsCardContainer extends StatelessWidget {
  final models.TransactionCardItems model;

  const TransactionsCardContainer({
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: Styles.edgeInsetVertical5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _DateAndAmountHeader(model: model),
          const Divider(height: 1),
          ...model.transactions.map((el) => TransactionItem(item: el)),
        ],
      ),
    );
  }
}

class CategoryGroupedTransactionsCardContainer extends StatelessWidget {
  final models.TransactionCardItems group;

  const CategoryGroupedTransactionsCardContainer({
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final S i18n = S.of(context);
    final currencyBloc = context.watch<CurrencyBloc>();
    return Card(
      margin: Styles.edgeInsetVertical5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Header(left: group.groupedBy, right: ''),
          const Divider(height: 1),
          ...group.transactions.map((el) => TransactionItem(item: el)),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Text(
              '${i18n.total}: ${currencyBloc.format(group.balance)}',
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateAndAmountHeader extends StatelessWidget {
  final models.TransactionCardItems model;

  const _DateAndAmountHeader({
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final currencyBloc = context.watch<CurrencyBloc>();
    final String expenses = '${i18n.expenses}: ${currencyBloc.format(model.expense)}';
    final String incomes = '${i18n.incomes}: ${currencyBloc.format(model.income)}';
    final String right = '$expenses  $incomes';
    return _Header(left: model.groupedBy, right: right);
  }
}

class _Header extends StatelessWidget {
  final String left;
  final String right;

  const _Header({
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 35,
            child: Tooltip(
              message: left,
              child: Text(
                left,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
          Flexible(
            flex: 65,
            child: Tooltip(
              message: right,
              child: Text(
                right,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
