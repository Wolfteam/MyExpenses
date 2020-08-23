import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/currency/currency_bloc.dart';
import '../../../common/styles.dart';
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
      margin: const EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          _buildHeader(context),
          const Divider(color: Colors.grey, height: 1),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
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
    final currencyBloc = context.bloc<CurrencyBloc>();

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 35,
            child: Text(model.dateString, overflow: TextOverflow.ellipsis, style: Styles.textStyleGrey12),
          ),
          Flexible(
            flex: 65,
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Styles.textStyleGrey12,
                children: <TextSpan>[
                  TextSpan(text: '${i18n.expenses}: ${currencyBloc.format(model.dayExpenses)}'),
                  const TextSpan(text: '  '),
                  TextSpan(text: '${i18n.incomes}: ${currencyBloc.format(model.dayIncomes)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
