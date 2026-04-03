import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart' as models;
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/transaction/add_edit_transaction_page.dart';

class TransactionItem extends StatelessWidget {
  final models.TransactionItem item;
  final bool showDate;

  const TransactionItem({
    super.key,
    required this.item,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyBloc = context.watch<CurrencyBloc>();
    final i18n = S.of(context);
    final dateToUse = item.isParentTransaction && item.nextRecurringDate != null ? item.nextRecurringDate : item.transactionDate;
    final dateString = utils.DateUtils.formatDateWithoutLocale(dateToUse, utils.DateUtils.monthDayAndYearFormat);
    final daysToNextRecurringDate = item.nextRecurringDate == null ? 0 : item.nextRecurringDate!.difference(DateTime.now()).inDays;

    final daysLeft = Text(daysToNextRecurringDate == 0 ? i18n.tomorrow : i18n.executesInXDays('$daysToNextRecurringDate'));

    final pmName = item.paymentMethodName;

    Widget? buildSubtitle() {
      if (item.isParentTransaction) {
        final dateText = item.nextRecurringDate != null ? Text(i18n.nextDateOn(dateString)) : Text(i18n.stopped);
        if (item.nextRecurringDate == null) return dateText;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [dateText, daysLeft],
        );
      }

      final dateText = showDate ? Text(i18n.dateOn(dateString)) : null;
      final pmText = pmName != null
          ? Text(
              pmName,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            )
          : null;

      if (dateText != null && pmText != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [dateText, pmText],
        );
      }
      return dateText ?? pmText;
    }

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.comfortable,
      titleAlignment: ListTileTitleAlignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: () => _goToDetails(context),
      leading: Icon(
        item.category.icon,
        color: item.category.iconColor,
      ),
      title: Tooltip(
        message: item.description,
        child: Text(
          item.description,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: buildSubtitle(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            currencyBloc.format(item.amount),
            style: TextStyle(
              color: item.category.isAnIncome ? Colors.green : Colors.red,
            ),
          ),
          if (item.isChildTransaction)
            Container(
              margin: const EdgeInsets.only(left: 5),
              child: const Icon(Icons.alarm, size: 20),
            ),
        ],
      ),
    );
  }

  Future<void> _goToDetails(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final route = AddEditTransactionPage.editRoute(item, context);
    await Navigator.of(context).push(route);
    await route.completed;
    // context.read<TransactionFormBloc>().add(const TransactionFormEvent.close());
  }
}
