import 'package:flutter/material.dart';

import '../../../generated/i18n.dart';
import '../../../models/transaction_card_items.dart';
import '../../widgets/transactions/transaction_item.dart' as transaction;

class TransactionsCardContainer extends StatelessWidget {
  final TransactionCardItems model;

  const TransactionsCardContainer({
    Key key,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          _buildHeader(context),
          Divider(
            color: Colors.grey,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: model.transactions.length,
            itemBuilder: (context, index) {
              return transaction.TransactionItem(
                item: model.transactions[index],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final i18n = I18n.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            model.dateString,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          RichText(
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '${i18n.expenses}: ${model.dayExpenses}',
                ),
                const TextSpan(text: '  '),
                TextSpan(
                  text: '${i18n.incomes}: ${model.dayIncomes}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
