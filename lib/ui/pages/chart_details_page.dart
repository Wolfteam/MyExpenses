import 'package:flutter/material.dart';

import '../widgets/charts/pie_chart_transactions_per_month.dart';
import '../widgets/transactions/transaction_item.dart';

class ChartDetailsPage extends StatelessWidget {
  final bool onlyIncomes;

  ChartDetailsPage(this.onlyIncomes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add transaction"),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                this.onlyIncomes ? "Incomes" : "Expenses",
                style: Theme.of(context).textTheme.title,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                this.onlyIncomes ? "2400 \$" : "-800 \$",
                style: Theme.of(context).textTheme.title.copyWith(
                      color: this.onlyIncomes ? Colors.green : Colors.red,
                    ),
              ),
            ),
            PieChartTransactionsPerMonths(true),
            Divider(),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 40,
              itemBuilder: (ctx, index) {
                return TransactionItem();
              },
            ),
          ],
        ),
      ),
    );
  }
}
