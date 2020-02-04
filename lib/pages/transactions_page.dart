import 'package:flutter/material.dart';

import '../widgets/transactions/home_transactions_summary_per_month.dart';
import '../widgets/transactions/home_last_7_days_summary.dart';
import '../widgets/transactions/transactions_card_container.dart';

class TransactionsPage extends StatelessWidget {
  final _scrollController = ScrollController();

/*
  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        _isScrollToTheTopVisible == true) {
      setState(() {
        _isScrollToTheTopVisible = false;
      });
    } else {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          _isScrollToTheTopVisible == false) {
        setState(() {
          _isScrollToTheTopVisible = true;
        });
      }
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: Icon(Icons.arrow_upward),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              HomeTransactionSummaryPerMonth(),
              HomeLast7DaysSummary(),
              Padding(
                padding: EdgeInsets.only(left: 28, top: 15),
                child: Text(
                  "Transactions",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: 10,
                itemBuilder: (context, _) => TransactionsCardContainer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
