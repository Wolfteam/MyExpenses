import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/transaction_form/transaction_form_bloc.dart';
import '../../../models/transaction_item.dart' as trans_item;
import '../../pages/add_edit_transasctiton_page.dart';

class TransactionItem extends StatelessWidget {
  final trans_item.TransactionItem item;

  const TransactionItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amountWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          '${item.amount} \$',
          style: TextStyle(
            color: item.category.isAnIncome ? Colors.green : Colors.red,
          ),
        ),
        if (item.isChildTransaction)
          Container(
            margin: const EdgeInsets.only(left: 5),
            child: Icon(
              Icons.alarm,
              size: 20,
            ),
          ),
      ],
    );

    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      onTap: () async {
        final route = MaterialPageRoute(
          builder: (ctx) => AddEditTransactionPage(item: item),
        );

        await Navigator.of(context).push(route);
        context.bloc<TransactionFormBloc>().add(FormClosed());
      },
      child: ListTile(
        dense: true,
        leading: Icon(
          item.category.icon,
          color: item.category.iconColor,
        ),
        title: Text(item.description),
        trailing: amountWidget,
      ),
    );
  }
}
