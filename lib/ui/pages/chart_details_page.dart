import 'package:flutter/material.dart';

import '../../generated/i18n.dart';
import '../widgets/charts/pie_chart_transactions_per_month.dart';
import '../widgets/transactions/transaction_item.dart';

class ChartDetailsPage extends StatelessWidget {
  final bool onlyIncomes;

  const ChartDetailsPage({@required this.onlyIncomes});

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.addTransaction),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Text(
                onlyIncomes ? i18n.incomes : i18n.expenses,
                style: Theme.of(context).textTheme.title,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Text(
                onlyIncomes ? "2400 \$" : "-800 \$",
                style: Theme.of(context).textTheme.title.copyWith(
                      color: this.onlyIncomes ? Colors.green : Colors.red,
                    ),
              ),
            ),
            PieChartTransactionsPerMonths(true),
            const Divider(),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 40,
              itemBuilder: (ctx, index) {
                return const TransactionItem();
              },
            ),
          ],
        ),
      ),
    );
  }
}
