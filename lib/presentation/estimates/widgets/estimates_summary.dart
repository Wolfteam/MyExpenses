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

    final String formattedIncomes = currencyBloc.format(income);
    final String formattedExpenses = currencyBloc.format(expenses);
    final String formattedTotal = currencyBloc.format(total);

    final String incomesText = '${i18n.incomes}: $formattedIncomes';
    final String expensesText = '${i18n.expenses}: $formattedExpenses';
    final String totalText = '${i18n.total}: $formattedTotal';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showIncomes)
          Text(
            incomesText,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: incomeTextStyle,
          ),
        if (showExpenses)
          Text(
            expensesText,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: expenseTextStyle,
          ),
        if (showTotal)
          Text(
            totalText,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: total == 0
                ? textStyle
                : total > 0
                    ? incomeTextStyle
                    : expenseTextStyle,
          ),
      ],
    );
  }
}
