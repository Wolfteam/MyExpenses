import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart' as models;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/transactions/widgets/transaction_item.dart';

class TransactionsCardContainer extends StatelessWidget {
  final models.TransactionCardItems model;

  const TransactionsCardContainer({
    super.key,
    required this.model,
  });

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
            itemBuilder: (context, index) => TransactionItem(item: model.transactions[index]),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final i18n = S.of(context);
    final currencyBloc = context.watch<CurrencyBloc>();
    final expenses = '${i18n.expenses}: ${currencyBloc.format(model.dayExpenses)}';
    final incomes = '${i18n.incomes}: ${currencyBloc.format(model.dayIncomes)}';

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 35,
            child: Tooltip(
              message: model.dateString,
              child: Text(model.dateString, overflow: TextOverflow.ellipsis, style: Styles.textStyleGrey12),
            ),
          ),
          Flexible(
            flex: 65,
            child: Tooltip(
              message: '$expenses  $incomes',
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: Styles.textStyleGrey12,
                  children: <TextSpan>[
                    TextSpan(text: expenses),
                    const TextSpan(text: '  '),
                    TextSpan(text: incomes),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
