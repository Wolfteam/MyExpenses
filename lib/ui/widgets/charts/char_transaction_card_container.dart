import 'package:flutter/material.dart';

import '../../../common/utils/date_utils.dart';
import '../../../generated/i18n.dart';
import '../../../models/transaction_item.dart';
import '../transactions/transaction_item.dart' as trans_item;

class ChartTransactionCardContainer extends StatelessWidget {
  final TransactionItem item;
  final int transactionsTotalAmount;

  const ChartTransactionCardContainer(
    this.item,
    this.transactionsTotalAmount,
  );

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    final formattedDate = DateUtils.formatDateWithoutLocale(
      item.transactionDate,
      DateUtils.monthDayAndYearFormat,
    );
    final dateString = '${i18n.date}: $formattedDate';
    final percentageString =
        (item.amount.round() * 100 / transactionsTotalAmount)
            .toStringAsFixed(2);

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
                  dateString,
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
          trans_item.TransactionItem(item: item),
        ],
      ),
    );
  }
}
