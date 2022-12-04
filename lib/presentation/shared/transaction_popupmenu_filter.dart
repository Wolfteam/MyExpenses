import 'package:flutter/material.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class TransactionPopupMenuFilter extends StatelessWidget {
  // final TransactionFilterType initialValue;
  final TransactionFilterType selectedValue;
  final Function(TransactionFilterType) onSelected;
  final List<TransactionFilterType>? exclude;

  const TransactionPopupMenuFilter({
    super.key,
    required this.selectedValue,
    required this.onSelected,
    this.exclude,
  });

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

    return ClipRRect(
      borderRadius: Styles.popupMenuButtonRadius,
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<TransactionFilterType>(
          padding: EdgeInsets.zero,
          initialValue: selectedValue,
          icon: const Icon(Icons.filter_list),
          onSelected: onSelected,
          itemBuilder: (context) => values,
          tooltip: i18n.sortType,
        ),
      ),
    );
  }
}
