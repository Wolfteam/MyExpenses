import 'package:flutter/material.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

const nothingSelected = -1;

class TransactionPopupMenuTypeFilter extends StatelessWidget {
  final TransactionType? selectedValue;
  final Function(int) onSelectedValue;
  final bool showNa;

  const TransactionPopupMenuTypeFilter({
    super.key,
    this.selectedValue,
    required this.onSelectedValue,
    this.showNa = false,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final income = CheckedPopupMenuItem<int>(
      checked: selectedValue == TransactionType.incomes,
      value: TransactionType.incomes.index,
      child: Text(i18n.incomes),
    );

    final expense = CheckedPopupMenuItem<int>(
      checked: selectedValue == TransactionType.expenses,
      value: TransactionType.expenses.index,
      child: Text(i18n.expenses),
    );

    if (!showNa) {
      assert(selectedValue != null, 'You need to provide a selected value if you are not showing the NA value');
    }

    return ClipRRect(
      borderRadius: Styles.popupMenuButtonRadius,
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<int>(
          padding: Styles.edgeInsetAll0,
          tooltip: i18n.transactionType,
          initialValue: selectedValue == null ? nothingSelected : selectedValue!.index,
          onSelected: onSelectedValue,
          itemBuilder: (context) => <PopupMenuEntry<int>>[
            if (showNa)
              CheckedPopupMenuItem<int>(
                checked: selectedValue == null,
                value: nothingSelected,
                child: Text(i18n.na),
              ),
            income,
            expense,
          ],
        ),
      ),
    );
  }
}
