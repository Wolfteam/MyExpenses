import 'package:flutter/material.dart';
import 'package:my_expenses/domain/models/models.dart' as models;
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/transactions/widgets/transaction_item.dart';

class TransactionItemCardContainer extends StatelessWidget {
  final models.TransactionItem item;

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
          TransactionItem(item: item),
        ],
      ),
    );
  }
}
