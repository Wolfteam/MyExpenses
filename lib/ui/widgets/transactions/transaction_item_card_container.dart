import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../../common/styles.dart';
import '../../../common/utils/date_utils.dart' as utils;
import '../../../models/transaction_item.dart';
import '../transactions/transaction_item.dart' as trans_item;

class TransactionItemCardContainer extends StatelessWidget {
  final TransactionItem item;
  const TransactionItemCardContainer({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final formattedDate = utils.DateUtils.formatDateWithoutLocale(item.transactionDate, utils.DateUtils.monthDayAndYearFormat);
    final dateString = '${i18n.date}: $formattedDate';

    return Card(
      shape: Styles.transactionCardShape,
      margin: Styles.edgeInsetAll10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(dateString, textAlign: TextAlign.start, style: Styles.textStyleGrey12),
                // Text(
                //   '$percentageString %',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey,
                //   ),
                // ),
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
