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
        Text('${i18n.startDate}:'),
        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () => _changeDate(context, s.fromDate, s.currentLanguage, true),
          child: Align(alignment: Alignment.centerLeft, child: Text(s.fromDateString)),
        ),
        Text('${i18n.untilDate}:'),
        FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () => _changeDate(context, s.untilDate, s.currentLanguage, false),
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
                  const Icon(Icons.select_all, size: 16.0, color: Colors.blue),
                  const SizedBox(width: 4.0),
                  Text(i18n.all, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.blue))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(CustomIcons.money, size: 16.0, color: Colors.green),
                  const SizedBox(width: 4.0),
                  Text(i18n.incomes, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.green))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.money_off, size: 16.0, color: Colors.red),
                  const SizedBox(width: 4.0),
                  Text(i18n.expenses, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.red))
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

    final textStyle = theme.textTheme.subtitle2;
    final expenseTextStyle = textStyle.copyWith(color: Colors.red);
    final incomeTextStyle = textStyle.copyWith(color: Colors.green);

    final formattedIncomes = currencyBloc.format(income);
    final formattedExpenses = currencyBloc.format(expenses);
    final formattedTotal = currencyBloc.format(total);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 70,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (showIncomes)
                  Text(
                    '${i18n.incomes}:',
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: incomeTextStyle,
                  ),
                if (showExpenses)
                  Text(
                    '${i18n.expenses}:',
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: expenseTextStyle,
                  ),
                if (showTotal)
                  Text(
                    '${i18n.total}:',
                    textAlign: TextAlign.end,
                    style: total >= 0 ? incomeTextStyle : expenseTextStyle,
                  ),
              ],
            ),
          ),
          Flexible(
            flex: 30,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (showIncomes)
                  Tooltip(
                    message: formattedIncomes,
                    child: Text(
                      formattedIncomes,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: incomeTextStyle,
                    ),
                  ),
                if (showExpenses)
                  Tooltip(
                    message: formattedExpenses,
                    child: Text(
                      formattedExpenses,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: expenseTextStyle,
                    ),
                  ),
                if (showTotal)
                  Tooltip(
                    message: formattedTotal,
                    child: Text(
                      formattedTotal,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: total >= 0 ? incomeTextStyle : expenseTextStyle,
                    ),
                  ),
              ],
            ),
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

  Future<void> _changeDate(
    BuildContext context,
    DateTime initialDate,
    AppLanguageType language,
    bool isFromDate,
  ) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      locale: currentLocale(language),
      firstDate: DateTime(now.year - 1),
      initialDate: initialDate,
      lastDate: DateTime(now.year + 1),
    );

    if (selectedDate == null) {
      return;
    }
    if (isFromDate) {
      context.bloc<EstimatesBloc>().add(EstimatesEvent.fromDateChanged(newDate: selectedDate));
    } else {
      context.bloc<EstimatesBloc>().add(EstimatesEvent.untilDateChanged(newDate: selectedDate));
    }
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
