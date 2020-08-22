import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/currency/currency_bloc.dart';
import '../../../generated/i18n.dart';
import '../../../models/chart_grouped_transactions_by_category.dart';
import '../transactions/transaction_item.dart' as trans_item;

class ChartGroupedTransactionsCardContainer extends StatelessWidget {
  final ChartGroupedTransactionsByCategory grouped;
  final double transactionsTotalAmount;

  double get percentage => grouped.total * 100 / transactionsTotalAmount;

  const ChartGroupedTransactionsCardContainer({
    Key key,
    this.grouped,
    this.transactionsTotalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    final percentageString = percentage.toStringAsFixed(2);

    final currencyBloc = context.bloc<CurrencyBloc>();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(10),
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
                Text(
                  grouped.category.name,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '$percentageString %',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: grouped.transactions.length,
            itemBuilder: (ctx, index) => trans_item.TransactionItem(
              item: grouped.transactions[index],
              showDate: true,
            ),
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
