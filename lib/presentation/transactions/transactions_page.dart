import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/sliver_loading.dart';
import 'package:my_expenses/presentation/shared/utils/i18n_utils.dart';
import 'package:my_expenses/presentation/transactions/widgets/home_last_7_days_summary.dart';
import 'package:my_expenses/presentation/transactions/widgets/home_transactions_summary_per_month.dart';
import 'package:my_expenses/presentation/transactions/widgets/transactions_card_container.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  late AnimationController _hideFabAnimController;
  bool _didChangeDependencies = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(vsync: this, duration: kThemeAnimationDuration, value: 0);
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

//TODO: Once this is fixed, this should not be required anymore  https://github.com/flutter/flutter/issues/39872
    if (_didChangeDependencies) return;
    final now = DateTime.now();
    context.read<TransactionsBloc>().add(TransactionsEvent.loadTransactions(inThisDate: now));

    _didChangeDependencies = true;
  }

//TODO: https://github.com/flutter/flutter/issues/55170
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: 1),
          ),
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

  Widget _buildTransSummaryPerMonth() {
    return BlocBuilder<TransactionsPerMonthBloc, TransactionsPerMonthState>(
      builder: (c, s) {
        return s.map(
          loading: (_) => const SliverLoading(),
          initial: (s) => SliverToBoxAdapter(
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
          loading: (_) => const SliverLoading(),
          initial: (s) => SliverToBoxAdapter(
            child: s.showLast7Days ? HomeLast7DaysSummary(selectedType: s.selectedType, incomes: s.incomes, expenses: s.expenses) : null,
          ),
        );
      },
    );
  }

  Widget _buildTransactionTypeSwitch() {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final i18n = S.of(context);
        return state.maybeMap(
          initial: (state) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    state.showParentTransactions ? i18n.recurringTransactions : i18n.transactions,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () {
                      if (!state.showParentTransactions) {
                        context.read<TransactionsBloc>().add(const TransactionsEvent.loadRecurringTransactions());
                      } else {
                        context.read<TransactionsBloc>().add(TransactionsEvent.loadTransactions(inThisDate: state.currentDate));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          orElse: () => const SliverLoading(),
        );
      },
    );
  }

  Widget _buildTransactions() {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final i18n = S.of(context);
        return state.maybeMap(
          initial: (state) {
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

            return SliverLoading(
              children: [
                NothingFound(
                  msg: state.showParentTransactions ? i18n.noRecurringTransactionsWereFound : i18n.noTransactionsForThisPeriod,
                )
              ],
            );
          },
          orElse: () => const SliverLoading(),
        );
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
}
