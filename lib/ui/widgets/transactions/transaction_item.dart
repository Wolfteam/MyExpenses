import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../../bloc/currency/currency_bloc.dart';
import '../../../common/utils/date_utils.dart' as utils;
import '../../../models/transaction_item.dart' as trans_item;
import '../../pages/add_edit_transasctiton_page.dart';

class TransactionItem extends StatelessWidget {
  final trans_item.TransactionItem item;
  final bool showDate;

  const TransactionItem({
    Key? key,
    required this.item,
    this.showDate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyBloc = context.watch<CurrencyBloc>();
    final i18n = S.of(context);
    final dateToUse = item.isParentTransaction && item.nextRecurringDate != null ? item.nextRecurringDate : item.transactionDate;
    final dateString = utils.DateUtils.formatDateWithoutLocale(dateToUse, utils.DateUtils.monthDayAndYearFormat);
    final daysToNextRecurringDate = item.nextRecurringDate == null ? 0 : item.nextRecurringDate!.difference(DateTime.now()).inDays;

    final daysLeft = Text(daysToNextRecurringDate == 0 ? i18n.tomorrow : i18n.executesInXDays('$daysToNextRecurringDate'));

    final subtitle = item.isParentTransaction && item.nextRecurringDate != null
        ? Text(i18n.nextDateOn(dateString))
        : item.isParentTransaction
            ? Text(i18n.stopped)
            : showDate
                ? Text(i18n.dateOn(dateString))
                : null;

    final amountWidget = Row(
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
    );

    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      onTap: () => _goToDetails(context),
      child: ListTile(
        dense: true,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              item.category.icon,
              color: item.category.iconColor,
            ),
          ],
        ),
        title: Text(item.description),
        subtitle: !item.isParentTransaction || item.nextRecurringDate == null
            ? subtitle
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (subtitle != null) subtitle,
                  daysLeft,
                ],
              ),
        trailing: amountWidget,
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
