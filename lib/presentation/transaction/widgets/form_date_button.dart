import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/transaction_form/transaction_form_bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/utils/i18n_utils.dart';

class FormDateButton extends StatefulWidget {
  final bool isChildTransaction;
  final RepetitionCycleType repetitionCycle;

  final DateTime transactionDate;
  final String transactionDateString;
  final bool isTransactionDateValid;

  final AppLanguageType language;
  final DateTime firstDate;
  final DateTime lastDate;

  const FormDateButton({
    super.key,
    required this.isChildTransaction,
    required this.repetitionCycle,
    required this.transactionDate,
    required this.transactionDateString,
    required this.isTransactionDateValid,
    required this.language,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<FormDateButton> createState() => _FormDateButtonState();
}

class _FormDateButtonState extends State<FormDateButton> {
  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.calendar_today, size: 30),
            Expanded(
              child: TextButton(
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(textColor)),
                onPressed: !widget.isChildTransaction ? () => _transactionDateClicked(context) : null,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.transactionDateString),
                ),
              ),
            ),
          ],
        ),
        if (!widget.isChildTransaction && !widget.isTransactionDateValid && widget.repetitionCycle != RepetitionCycleType.none)
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Text(
              i18n.recurringDateMustStartFromTomorrow,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall!.copyWith(color: theme.primaryColorDark),
            ),
          ),
      ],
    );
  }

  Future<void> _transactionDateClicked(BuildContext context) async {
    DateTime? selectedDate;
    if (widget.repetitionCycle != RepetitionCycleType.biweekly) {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: widget.transactionDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        locale: currentLocale(widget.language),
      );
    } else {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: widget.transactionDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        locale: currentLocale(widget.language),
        selectableDayPredicate: (date) {
          if (date.isAtSameMomentAs(widget.transactionDate) || date.day == DateTime.monday) {
            return true;
          }

          final biweeklyDate = utils.DateUtils.getNextBiweeklyDate(date.subtract(const Duration(days: 1)));

          return biweeklyDate.day == date.day;
        },
      );
    }

    if (selectedDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }
    context.read<TransactionFormBloc>().add(TransactionFormEvent.transactionDateChanged(transactionDate: selectedDate));
  }
}
