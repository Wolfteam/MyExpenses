import 'package:flutter/material.dart';

import '../../models/transaction_item.dart' as Item;

class TransactionItem extends StatelessWidget {
  final Item.TransactionItem item;

  TransactionItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 5, right: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            item.category.icon,
            color: item.category.iconColor,
          ),
          SizedBox(width: 10),
          Text(item.description),
          Spacer(),
          Text(
            "${item.amount} \$",
            style: TextStyle(
              color: item.category.isAnIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
