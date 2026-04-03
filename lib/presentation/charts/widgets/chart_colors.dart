import 'package:flutter/material.dart';
import 'package:my_expenses/domain/enums/enums.dart';

class ChartColors {
  ChartColors._();

  static Color defaultColor = Colors.grey;

  static IconData defaultCategoryIcon = Icons.label;

  static IconData defaultPaymentMethodIcon(PaymentMethodType? type) {
    return switch (type) {
      PaymentMethodType.cash => Icons.money,
      PaymentMethodType.creditCard => Icons.credit_card,
      PaymentMethodType.debitCard => Icons.credit_card,
      PaymentMethodType.mobileWallet => Icons.phone_android,
      PaymentMethodType.bankTransfer => Icons.account_balance,
      PaymentMethodType.other => Icons.payment,
      null => Icons.payment,
    };
  }
}
