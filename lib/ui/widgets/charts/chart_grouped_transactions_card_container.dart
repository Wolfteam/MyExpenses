import 'package:flutter/material.dart';

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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  grouped.category.name,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '$percentageString %',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
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
              '${i18n.total}: ${grouped.total} \$',
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
