import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/chart_details/chart_details_page.dart';
import 'package:my_expenses/presentation/charts/widgets/pie_chart_transactions_per_month.dart';

class IncomeExpensePieChart extends StatelessWidget {
  final bool incomes;
  final List<TransactionItem> transactions;
  final double totalAmount;

  const IncomeExpensePieChart.income({
    Key? key,
    required this.transactions,
    required this.totalAmount,
  })  : incomes = true,
        super(key: key);

  const IncomeExpensePieChart.expense({
    Key? key,
    required this.transactions,
    required this.totalAmount,
  })  : incomes = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final titleStyle = theme.textTheme.subtitle2;
    final textStyle = theme.textTheme.headline6;
    final dataToUse = TransactionUtils.buildChartTransactionItems(transactions, onlyIncomes: incomes);

    final currencyBloc = context.read<CurrencyBloc>();
    final double aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 1.5;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => dataToUse.isNotEmpty ? _goToDetailsPage(context, incomes) : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Text(incomes ? i18n.incomes : i18n.expenses, style: titleStyle),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Text(
                        currencyBloc.format(totalAmount),
                        overflow: TextOverflow.ellipsis,
                        style: textStyle!.copyWith(color: incomes ? Colors.green : Colors.red),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
          AspectRatio(aspectRatio: aspectRatio, child: PieChartTransactionsPerMonths(dataToUse)),
        ],
      ),
    );
  }

  void _goToDetailsPage(BuildContext context, bool onlyIncomes) {
    final filteredTransactions = transactions.where((t) => t.category.isAnIncome == onlyIncomes).toList();
    final route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => ChartDetailsPage(onlyIncomes: onlyIncomes, transactions: filteredTransactions),
    );

    Navigator.of(context).push(route);
  }
}
