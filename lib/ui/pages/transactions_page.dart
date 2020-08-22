import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/transactions/transactions_bloc.dart';
import '../../common/extensions/scroll_controller_extensions.dart';
import '../../common/utils/i18n_utils.dart';
import '../../generated/i18n.dart';
import '../widgets/nothing_found.dart';
import '../widgets/transactions/home_last_7_days_summary.dart';
import '../widgets/transactions/home_transactions_summary_per_month.dart';
import '../widgets/transactions/transactions_card_container.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;
  bool _didChangeDependencies = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

//TODO: Once this is fixed, this should not be required anymore  https://github.com/flutter/flutter/issues/39872
    if (_didChangeDependencies) return;
    final now = DateTime.now();
    context.bloc<TransactionsBloc>().add(GetTransactions(inThisDate: now));

    _didChangeDependencies = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      floatingActionButton: FadeTransition(
        opacity: _hideFabAnimController,
        child: ScaleTransition(
          scale: _hideFabAnimController,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
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
                mainAxisAlignment:
                    state is TransactionsInitialState ? MainAxisAlignment.center : MainAxisAlignment.start,
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

  List<Widget> _buildPage(TransactionsState state) {
    if (state is TransactionsInitialState) {
      return [
        const Center(
          child: CircularProgressIndicator(),
        )
      ];
    }

    if (state is TransactionsLoadedState) {
      final i18n = I18n.of(context);
      return [
        HomeTransactionSummaryPerMonth(
          expenses: state.expenseAmount,
          incomes: state.incomeAmount,
          total: state.balanceAmount,
          month: state.month,
          data: state.monthBalance,
          currentDate: state.currentDate,
          locale: currentLocale(state.language),
        ),
        if (state.showLast7Days)
          HomeLast7DaysSummary(
            incomes: state.incomeTransactionsPerWeek,
            expenses: state.expenseTransactionsPerWeek,
          ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                state.showParentTransactions ? i18n.recurringTransactions : i18n.transactions,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headline6,
              ),
              IconButton(
                icon: Icon(Icons.swap_horiz),
                onPressed: () => _switchTransactionList(context, state),
              ),
            ],
          ),
        ),
        _buildTransactionsCard(state, i18n),
      ];
    }

    return [];
  }

  Widget _buildTransactionsCard(
    TransactionsLoadedState state,
    I18n i18n,
  ) {
    if (state.transactionsPerMonth.isNotEmpty) {
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

    return NothingFound(
      msg: state.showParentTransactions ? i18n.noRecurringTransactionsWereFound : i18n.noTransactionsForThisPeriod,
    );
  }

  void _switchTransactionList(
    BuildContext context,
    TransactionsLoadedState state,
  ) {
    if (!state.showParentTransactions) {
      context.bloc<TransactionsBloc>().add(const GetAllParentTransactions());
    } else {
      context.bloc<TransactionsBloc>().add(GetTransactions(inThisDate: state.currentDate));
    }
  }
}
