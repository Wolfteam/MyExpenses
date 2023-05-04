import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';

class EstimatesSummary extends StatelessWidget {
  final List<bool> selectedButtons;
  final double income;
  final double expenses;
  final double total;

  const EstimatesSummary({
    super.key,
    required this.selectedButtons,
    required this.income,
    required this.expenses,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final currencyBloc = context.read<CurrencyBloc>();
    final showTotal = selectedButtons.first;
    final showIncomes = showTotal || selectedButtons[1];
    final showExpenses = showTotal || selectedButtons[2];

    final textStyle = theme.textTheme.titleSmall!;
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
}
