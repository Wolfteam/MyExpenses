import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/common_dropdown_button.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/utils/enum_utils.dart';

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

    //This is to avoid loosing the isParentTransaction property and
    //to avoid a potential bug
    final repetitionCyclesToUse = isParentTransaction ? _repetitionCycles.where((c) => c.index != RepetitionCycleType.none.index) : _repetitionCycles;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.repeat, size: 30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: CommonDropdownButton<RepetitionCycleType>(
                    values: EnumUtils.getTranslatedAndSortedEnum<RepetitionCycleType>(
                      repetitionCyclesToUse,
                      (value, _) => i18n.translateRepetitionCycleType(value),
                    ),
                    currentValue: repetitionCycle,
                    hint: i18n.translateRepetitionCycleType(repetitionCycle),
                    onChanged: (v, _) => !isChildTransaction ? _repetitionCycleChanged(v, context) : null,
                  ),
                ),
              ),
            ],
          ),
          if (!isChildTransaction && repetitionCycle != RepetitionCycleType.none)
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 8, right: 8),
              child: Text(
                i18n.recurringTransactionStartsOn(
                  utils.DateUtils.formatAppDate(transactionDate, language, utils.DateUtils.monthDayAndYearFormat),
                  i18n.translateRepetitionCycleType(repetitionCycle).toLowerCase(),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.caption!.copyWith(color: theme.primaryColorDark),
              ),
            ),
        ],
      ),
    );
  }

  void _repetitionCycleChanged(RepetitionCycleType newValue, BuildContext context) =>
      context.read<TransactionFormBloc>().add(TransactionFormEvent.repetitionCycleChanged(repetitionCycle: newValue));
}
