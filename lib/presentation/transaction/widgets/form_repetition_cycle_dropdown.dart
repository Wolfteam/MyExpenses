import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';

const _repetitionCycles = [
  RepetitionCycleType.none,
  RepetitionCycleType.eachDay,
  RepetitionCycleType.eachWeek,
  RepetitionCycleType.biweekly,
  RepetitionCycleType.eachMonth,
];

class FormRepetitionCycleDropDown extends StatelessWidget {
  final bool isChildTransaction;
  final bool isParentTransaction;
  final RepetitionCycleType repetitionCycle;
  final LanguageModel language;
  final DateTime transactionDate;

  const FormRepetitionCycleDropDown({
    super.key,
    required this.isChildTransaction,
    required this.isParentTransaction,
    required this.repetitionCycle,
    required this.language,
    required this.transactionDate,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final cyclesToUse = isParentTransaction
        ? _repetitionCycles.where((c) => c != RepetitionCycleType.none).toList()
        : _repetitionCycles.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: !isChildTransaction,
          leading: const Icon(Icons.repeat),
          title: Text(i18n.recurring),
          subtitle: Text(i18n.translateRepetitionCycleType(repetitionCycle)),
          onTap: isChildTransaction ? null : () => _showPicker(context, cyclesToUse),
        ),
        if (!isChildTransaction && repetitionCycle != RepetitionCycleType.none)
          Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 8, right: 8),
            child: Text(
              i18n.recurringTransactionStartsOn(
                utils.DateUtils.formatAppDate(
                  transactionDate,
                  language,
                  utils.DateUtils.monthDayAndYearFormat,
                ),
                i18n.translateRepetitionCycleType(repetitionCycle).toLowerCase(),
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.primary),
            ),
          ),
      ],
    );
  }

  void _showPicker(BuildContext context, List<RepetitionCycleType> cycles) {
    final bloc = context.read<TransactionFormBloc>();
    final i18n = S.of(context);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final cycle in cycles)
              ListTile(
                title: Text(i18n.translateRepetitionCycleType(cycle)),
                selected: cycle == repetitionCycle,
                onTap: () {
                  bloc.add(TransactionFormEvent.repetitionCycleChanged(repetitionCycle: cycle));
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
