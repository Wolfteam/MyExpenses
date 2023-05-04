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
        create: (ctx) => Injection.estimatesBloc..add(EstimatesEvent.load()),
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
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return BlocBuilder<EstimatesBloc, EstimatesState>(
      builder: (ctx, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: state.map(
          loading: (_) => [],
          loaded: (s) => [
            ModalSheetSeparator(),
            Text(
              '${i18n.estimates} - ${_getSelectedTransactionText(i18n, s.selectedTransactionType)}',
              style: theme.textTheme.titleLarge,
            ),
            EstimatesToggleButtons(
              selectedButtons: _getSelectedButtons(s.selectedTransactionType),
            ),
            Text('${i18n.startDate}:'),
            TextButton(
              style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: textColor),
              onPressed: () => _changeDate(context, s.fromDate, s.currentLanguage, true),
              child: Align(alignment: Alignment.centerLeft, child: Text(s.fromDateString)),
            ),
            Text('${i18n.untilDate}:'),
            TextButton(
              style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: textColor),
              onPressed: () => _changeDate(context, s.untilDate, s.currentLanguage, false),
              child: Align(alignment: Alignment.centerLeft, child: Text(s.untilDateString)),
            ),
            Divider(color: theme.colorScheme.secondary),
            Text('${i18n.period}: ${s.fromDateString} - ${s.untilDateString}'),
            EstimatesSummary(
              selectedButtons: _getSelectedButtons(s.selectedTransactionType),
              income: s.incomeAmount,
              expenses: s.expenseAmount,
              total: s.totalAmount,
            ),
            ButtonBar(
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(i18n.close, style: TextStyle(color: theme.primaryColor)),
                ),
              ],
            ),
          ],
        ),
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
      if (selectedDate == null) {
        return;
      }
      if (isFromDate) {
        context.read<EstimatesBloc>().add(EstimatesEvent.fromDateChanged(newDate: selectedDate));
      } else {
        context.read<EstimatesBloc>().add(EstimatesEvent.untilDateChanged(newDate: selectedDate));
      }
      context.read<EstimatesBloc>().add(EstimatesEvent.calculate());
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
