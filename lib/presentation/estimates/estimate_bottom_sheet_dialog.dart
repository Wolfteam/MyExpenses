import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/estimates/widgets/estimates_summary.dart';
import 'package:my_expenses/presentation/estimates/widgets/estimates_toggle_buttons.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_separator.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/i18n_utils.dart';

class EstimateBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider<EstimatesBloc>(
        create: (ctx) => Injection.estimatesBloc..add(const EstimatesEvent.load()),
        child: Container(
          margin: Styles.modalBottomSheetContainerMargin,
          padding: Styles.modalBottomSheetContainerPadding,
          child: const _Body(),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    return BlocBuilder<EstimatesBloc, EstimatesState>(
      builder:
          (ctx, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: switch (state) {
              EstimatesStateEstimatesLoadingState() => [],
              EstimatesStateEstimatesInitialState() => [
                ModalSheetSeparator(),
                Text(
                  '${i18n.estimates} - ${_getSelectedTransactionText(i18n, state.selectedTransactionType)}',
                  style: theme.textTheme.titleLarge,
                ),
                EstimatesToggleButtons(selectedButtons: _getSelectedButtons(state.selectedTransactionType)),
                Text('${i18n.startDate}:'),
                TextButton(
                  style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  onPressed: () => _changeDate(context, state.fromDate, state.currentLanguage, true),
                  child: Align(alignment: Alignment.centerLeft, child: Text(state.fromDateString)),
                ),
                Text('${i18n.untilDate}:'),
                TextButton(
                  style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  onPressed: () => _changeDate(context, state.untilDate, state.currentLanguage, false),
                  child: Align(alignment: Alignment.centerLeft, child: Text(state.untilDateString)),
                ),
                Divider(color: theme.colorScheme.secondary),
                Text('${i18n.period}: ${state.fromDateString} - ${state.untilDateString}'),
                EstimatesSummary(
                  selectedButtons: _getSelectedButtons(state.selectedTransactionType),
                  income: state.incomeAmount,
                  expenses: state.expenseAmount,
                  total: state.totalAmount,
                ),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: Text(i18n.close))],
                ),
              ],
            },
          ),
    );
  }

  Future<void> _changeDate(BuildContext context, DateTime initialDate, AppLanguageType language, bool isFromDate) async {
    final now = DateTime.now();
    await showDatePicker(
      context: context,
      locale: currentLocale(language),
      firstDate: DateTime(now.year - 1),
      initialDate: initialDate,
      lastDate: DateTime(now.year + 1),
    ).then((selectedDate) {
      if (selectedDate == null || !context.mounted) {
        return;
      }
      if (isFromDate) {
        context.read<EstimatesBloc>().add(EstimatesEvent.fromDateChanged(newDate: selectedDate));
      } else {
        context.read<EstimatesBloc>().add(EstimatesEvent.untilDateChanged(newDate: selectedDate));
      }
      context.read<EstimatesBloc>().add(const EstimatesEvent.calculate());
    });
  }

  List<bool> _getSelectedButtons(int selectedTransactionType) {
    final selectedButtons = <bool>[];
    if (selectedTransactionType == 0) {
      selectedButtons.addAll([true, false, false]);
    } else if (selectedTransactionType == 1) {
      selectedButtons.addAll([false, true, false]);
    } else {
      selectedButtons.addAll([false, false, true]);
    }

    return selectedButtons;
  }

  String _getSelectedTransactionText(S i18n, int value) {
    if (value == 0) return i18n.all;
    if (value == 1) return i18n.incomes;
    return i18n.expenses;
  }
}
