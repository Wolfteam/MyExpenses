import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/currency/currency_bloc.dart';
import '../../../bloc/estimates/estimates_bloc.dart';
import '../../../common/enums/app_language_type.dart';
import '../../../common/presentation/custom_icons.dart';
import '../../../common/utils/i18n_utils.dart';
import '../../../generated/i18n.dart';
import '../modal_sheet_separator.dart';

class EstimateBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: BlocBuilder<EstimatesBloc, EstimatesState>(
          builder: (ctx, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[..._buildPage(ctx, state)],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPage(BuildContext context, EstimatesState state) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    return state.map(
      loading: (_) => [],
      loaded: (s) => [
        ModalSheetSeparator(),
        Text(
          '${i18n.estimates} - ${_getSelectedTransactionText(i18n, s.selectedTransactionType)}',
          style: theme.textTheme.headline6,
        ),
        _buildToggleButtons(context, s.selectedTransactionType),
        Text('${i18n.untilDate}:'),
        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () => _changeCurrentDate(context, s.fromDate, s.untilDate, s.currentLanguage),
          child: Align(alignment: Alignment.centerLeft, child: Text(s.untilDateString)),
        ),
        Divider(color: theme.accentColor),
        Text('${i18n.period}: ${s.fromDateString} - ${s.untilDateString}'),
        _buildSummary(context, s.selectedTransactionType, s.incomeAmount, s.expenseAmount, s.totalAmount),
        _buildBottomButtonBar(context),
      ],
    );
  }

  Widget _buildToggleButtons(BuildContext context, int selectedTransactionType) {
    final i18n = I18n.of(context);
    final selectedButtons = _getSelectedButtons(selectedTransactionType);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (ctx, constraints) => Center(
          child: ToggleButtons(
            constraints: BoxConstraints.expand(width: (constraints.minWidth - 20) / 3, height: 36),
            onPressed: (int index) => _transactionTypeChanged(context, index),
            isSelected: selectedButtons,
            borderRadius: BorderRadius.circular(5),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.select_all, size: 16.0, color: Colors.blue),
                  const SizedBox(width: 4.0),
                  Text(i18n.all, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.blue))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(CustomIcons.money, size: 16.0, color: Colors.green),
                  const SizedBox(width: 4.0),
                  Text(i18n.incomes, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.green))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.money_off, size: 16.0, color: Colors.red),
                  const SizedBox(width: 4.0),
                  Text(i18n.expenses, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    int selectedTransactionType,
    double income,
    double expenses,
    double total,
  ) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    final currencyBloc = context.bloc<CurrencyBloc>();
    final selectedButtons = _getSelectedButtons(selectedTransactionType);
    final showTotal = selectedButtons.first;
    final showIncomes = showTotal || selectedButtons[1];
    final showExpenses = showTotal || selectedButtons[2];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (showIncomes)
            Text(
              '${i18n.incomes}: ${currencyBloc.format(income)}',
              textAlign: TextAlign.end,
              style: theme.textTheme.subtitle2.copyWith(color: Colors.green),
            ),
          if (showExpenses)
            Text(
              '${i18n.expenses}: ${currencyBloc.format(expenses)}',
              textAlign: TextAlign.end,
              style: theme.textTheme.subtitle2.copyWith(color: Colors.red),
            ),
          if (showTotal)
            Text(
              '${i18n.total}: ${currencyBloc.format(total)}',
              textAlign: TextAlign.end,
              style: theme.textTheme.subtitle2.copyWith(color: Colors.green),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtonBar(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    return ButtonBar(
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
      children: <Widget>[
        OutlineButton(
          onPressed: () => Navigator.pop(context),
          child: Text(i18n.close, style: TextStyle(color: theme.primaryColor)),
        ),
      ],
    );
  }

  Future<void> _changeCurrentDate(
    BuildContext context,
    DateTime initialDate,
    DateTime untilDate,
    AppLanguageType language,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: untilDate,
      firstDate: DateTime.now(),
      locale: currentLocale(language),
      lastDate: DateTime(initialDate.year + 1, initialDate.month, initialDate.day),
    );

    if (selectedDate == null) {
      return;
    }
    context.bloc<EstimatesBloc>().add(EstimatesEvent.untilDateChanged(newDate: selectedDate));
    context.bloc<EstimatesBloc>().add(EstimatesEvent.calculate());
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

  String _getSelectedTransactionText(I18n i18n, int value) {
    if (value == 0) return i18n.all;
    if (value == 1) return i18n.incomes;
    return i18n.expenses;
  }

  void _transactionTypeChanged(BuildContext context, int newValue) =>
      context.bloc<EstimatesBloc>().add(EstimatesEvent.transactionTypeChanged(newValue: newValue));
}
