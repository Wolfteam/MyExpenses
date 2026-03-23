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
    final showError = !widget.isChildTransaction &&
        !widget.isTransactionDateValid &&
        widget.repetitionCycle != RepetitionCycleType.none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: !widget.isChildTransaction,
          leading: const Icon(Icons.calendar_today),
          title: Text(i18n.date),
          subtitle: Text(widget.transactionDateString),
          onTap: widget.isChildTransaction ? null : () => _transactionDateClicked(context),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
            child: Text(
              i18n.recurringDateMustStartFromTomorrow,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.primary),
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

    if (!mounted || !context.mounted) {
      return;
    }
    context.read<TransactionFormBloc>().add(TransactionFormEvent.transactionDateChanged(transactionDate: selectedDate));
  }
}
