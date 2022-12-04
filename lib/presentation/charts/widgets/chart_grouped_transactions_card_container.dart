import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart' as models;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/transactions/widgets/transaction_item.dart';

class ChartGroupedTransactionsCardContainer extends StatelessWidget {
  final models.ChartGroupedTransactionsByCategory grouped;
  final double transactionsTotalAmount;

  double get percentage => grouped.total * 100 / transactionsTotalAmount;

  const ChartGroupedTransactionsCardContainer({
    super.key,
    required this.grouped,
    required this.transactionsTotalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final percentageString = percentage.toStringAsFixed(2);

    final currencyBloc = context.read<CurrencyBloc>();

    return Card(
      shape: Styles.transactionCardShape,
      margin: Styles.edgeInsetAll10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 16,
              right: 16,
              bottom: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(grouped.category.name, textAlign: TextAlign.start, style: Styles.textStyleGrey12),
                Text('$percentageString %', style: Styles.textStyleGrey12),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: grouped.transactions.length,
            itemBuilder: (ctx, index) => TransactionItem(item: grouped.transactions[index], showDate: true),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 10,
            ),
            child: Text(
              '${i18n.total}: ${currencyBloc.format(grouped.total)}',
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
