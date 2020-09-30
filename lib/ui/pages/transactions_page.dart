import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/transactions/transactions_bloc.dart';
import '../../bloc/transactions_last_7_days/transactions_last_7_days_bloc.dart';
import '../../bloc/transactions_per_month/transactions_per_month_bloc.dart';
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
    context.bloc<TransactionsBloc>().loadTransactions(now);

    _didChangeDependencies = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildTransSummaryPerMonth(),
          _buildLast7DaysSummary(),
          _buildTransactionTypeSwitch(),
          _buildTransactions(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  Widget _buildLoading() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [CircularProgressIndicator()],
      ),
    );
  }

  Widget _buildTransSummaryPerMonth() {
    return BlocBuilder<TransactionsPerMonthBloc, TransactionsPerMonthState>(
      builder: (c, s) {
        return s.map(
          initial: (_) => _buildLoading(),
          loaded: (s) => SliverToBoxAdapter(
            child: HomeTransactionSummaryPerMonth(
              expenses: s.expenses,
              incomes: s.incomes,
              total: s.total,
              month: s.month,
              data: s.transactions,
              currentDate: s.currentDate,
              locale: currentLocale(s.currentLanguage),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLast7DaysSummary() {
    return BlocBuilder<TransactionsLast7DaysBloc, TransactionsLast7DaysState>(
      builder: (context, state) {
        return state.map(
          initial: (_) => _buildLoading(),
          loaded: (s) => SliverToBoxAdapter(
            child: s.showLast7Days
                ? HomeLast7DaysSummary(selectedType: s.selectedType, incomes: s.incomes, expenses: s.expenses)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildTransactionTypeSwitch() {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final i18n = I18n.of(context);
        if (state is TransactionsLoadedState) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    state.showParentTransactions ? i18n.recurringTransactions : i18n.transactions,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () => _switchTransactionList(context, state),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildLoading();
      },
    );
  }

  Widget _buildTransactions() {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final i18n = I18n.of(context);
        if (state is TransactionsLoadedState) {
          if (state.transactionsPerMonth.isNotEmpty) {
            return SliverPadding(
              padding: const EdgeInsets.only(bottom: 25),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TransactionsCardContainer(model: state.transactionsPerMonth[index]),
                  ),
                  childCount: state.transactionsPerMonth.length,
                ),
              ),
            );
          }
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NothingFound(
                  msg: state.showParentTransactions
                      ? i18n.noRecurringTransactionsWereFound
                      : i18n.noTransactionsForThisPeriod,
                )
              ],
            ),
          );
        }

        return _buildLoading();
      },
    );
  }

  Widget _buildFab() {
    return FadeTransition(
      opacity: _hideFabAnimController,
      child: ScaleTransition(
        scale: _hideFabAnimController,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          mini: true,
          onPressed: () => _scrollController.goToTheTop(),
          child: const Icon(Icons.arrow_upward),
        ),
      ),
    );
  }

  void _switchTransactionList(
    BuildContext context,
    TransactionsLoadedState state,
  ) {
    if (!state.showParentTransactions) {
      context.bloc<TransactionsBloc>().loadRecurringTransactions();
    } else {
      context.bloc<TransactionsBloc>().loadTransactions(state.currentDate);
    }
  }
}
