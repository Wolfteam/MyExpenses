import 'package:flutter/material.dart';

import '../../../generated/i18n.dart';

class NoTransactionsFound extends StatelessWidget {
  final bool recurringTransactions;

  const NoTransactionsFound({this.recurringTransactions = false});

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 30, right: 20, left: 20),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.info,
            color: theme.primaryColor,
            size: 60,
          ),
          Text(
            recurringTransactions
                ? i18n.noRecurringTransactionsWereFound
                : i18n.noTransactionsForThisPeriod,
            textAlign: TextAlign.center,
            style: theme.textTheme.title,
          ),
        ],
      ),
    );
  }
}
