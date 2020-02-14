import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import '../widgets/transactions/home_last_7_days_summary.dart';
import '../widgets/transactions/home_transactions_summary_per_month.dart';
import '../widgets/transactions/transactions_card_container.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final now = DateTime.now();
    context.bloc<TransactionsBloc>().add(GetTransactions(inThisDate: now));
    context
        .bloc<TransactionsLast7DaysBloc>()
        .add(LoadLast7DaysTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      floatingActionButton: FadeTransition(
        opacity: _hideFabAnimController,
        child: ScaleTransition(
          scale: _hideFabAnimController,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Icon(Icons.arrow_upward),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (ctx, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildPage(state),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  void _onScroll() {
    switch (_scrollController.position.userScrollDirection) {
      case ScrollDirection.idle:
        break;
      case ScrollDirection.forward:
        _hideFabAnimController.forward();
        break;
      case ScrollDirection.reverse:
        _hideFabAnimController.reverse();
        break;
    }
  }

  List<Widget> _buildPage(TransactionsState state) {
    if (state is TransactionsInitialState) {
      return [const CircularProgressIndicator()];
    }

    if (state is TransactionsLoadedState) {
      return [
        HomeTransactionSummaryPerMonth(
          expenses: state.expenseAmount,
          incomes: state.incomeAmount,
          total: state.balanceAmount,
          month: state.month,
          data: state.monthBalance,
        ),
        HomeLast7DaysSummary(
          incomes: state.incomeTransactionsPerWeek,
          expenses: state.expenseTransactionsPerWeek,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28, top: 15),
          child: Text(
            "Transactions",
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        _buildTransactionsCard(state),
      ];
    }

    return [];
  }

  Widget _buildTransactionsCard(TransactionsLoadedState state) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: state.transactionsPerMonth.length,
      itemBuilder: (context, index) => TransactionsCardContainer(
        model: state.transactionsPerMonth[index],
      ),
    );
  }
}
