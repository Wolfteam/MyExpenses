import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../../common/enums/transaction_filter_type.dart';
import '../../../common/extensions/i18n_extensions.dart';

class TransactionPopupMenuFilter extends StatelessWidget {
  // final TransactionFilterType initialValue;
  final TransactionFilterType selectedValue;
  final Function(TransactionFilterType) onSelected;
  final List<TransactionFilterType>? exclude;

  const TransactionPopupMenuFilter({
    Key? key,
    required this.selectedValue,
    required this.onSelected,
    this.exclude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final transValues =
        exclude != null && exclude!.isNotEmpty ? TransactionFilterType.values.where((el) => !exclude!.contains(el)) : TransactionFilterType.values;
    final values = transValues
        .map(
          (filter) => CheckedPopupMenuItem<TransactionFilterType>(
            checked: selectedValue == filter,
            value: filter,
            child: Text(i18n.getTransactionFilterTypeName(filter)),
          ),
        )
        .toList();

    return PopupMenuButton<TransactionFilterType>(
      padding: EdgeInsets.zero,
      initialValue: selectedValue,
      icon: const Icon(Icons.filter_list),
      onSelected: onSelected,
      itemBuilder: (context) => values,
      tooltip: i18n.sortType,
    );
  }
}
