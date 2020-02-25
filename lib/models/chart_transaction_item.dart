import 'package:flutter/material.dart';

import 'base_transaction.dart';

class ChartTransactionItem extends BaseTransaction {
  Color _color;
  final int order;
  final bool dummyItem;

  @override
  Color get color {
    return _color;
  }

  set color(Color c) {
    _color = c;
  }

  ChartTransactionItem(
    this._color, {
    @required int amount,
    @required this.order,
    this.dummyItem = false
  }) : super(amount: amount);
}
