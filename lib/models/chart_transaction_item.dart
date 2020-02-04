import 'package:flutter/material.dart';
import 'package:my_expenses/models/base_transaction.dart';

class ChartTransactionItem extends BaseTransaction {
  Color _color;
  int order;

  @override
  Color get color {
    return _color;
  }

  set color(Color c) {
    this._color = c;
  }

  ChartTransactionItem(
    this._color, {
    @required int amount,
    @required this.order,
  }) : super(amount: amount);
}
