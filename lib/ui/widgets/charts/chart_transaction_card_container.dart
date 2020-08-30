import 'package:flutter/material.dart';

import '../../../common/styles.dart';
import '../../../common/utils/date_utils.dart';
import '../../../generated/i18n.dart';
import '../../../models/transaction_item.dart';
import '../transactions/transaction_item.dart' as trans_item;

class ChartTransactionCardContainer extends StatelessWidget {
  final TransactionItem item;
  final double transactionsTotalAmount;

  double get percentage => item.amount * 100 / transactionsTotalAmount;

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
            padding: const EdgeInsets.only(
              top: 8,
              left: 16,
              right: 16,
              bottom: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(dateString, textAlign: TextAlign.start, style: Styles.textStyleGrey12),
                Text('$percentageString %', style: Styles.textStyleGrey12),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          trans_item.TransactionItem(item: item),
        ],
      ),
    );
  }
}
