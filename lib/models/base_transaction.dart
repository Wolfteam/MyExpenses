import 'package:flutter/material.dart';
//TODO: REPLACE THIS CLASS WITH A MIXIN
class BaseTransaction {
  int amount;
  String description;
  DateTime createdAt;

  bool get isAnIncome {
    return amount >= 0;
  }

  Color get color {
    return isAnIncome ? Colors.green : Colors.red;
  }

  BaseTransaction({
    @required this.amount,
    this.description = 'Default',
  }) {
    createdAt = DateTime.now();
  }

  BaseTransaction.withDate({
    @required this.amount,
    @required this.createdAt,
    this.description = '',
  });
}
