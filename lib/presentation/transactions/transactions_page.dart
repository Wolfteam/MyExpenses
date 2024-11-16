import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/sliver_loading.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/transactions/widgets/home_welcome.dart';
import 'package:my_expenses/presentation/transactions/widgets/transactions_activity_chart.dart';
import 'package:my_expenses/presentation/transactions/widgets/transactions_card_container.dart';
import 'package:my_expenses/presentation/transactions/widgets/transactions_summary_per_month.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  late AnimationController _hideFabAnimController;

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
    final now = DateTime.now();
    context.read<TransactionsBloc>().add(TransactionsEvent.loadTransactions(inThisDate: now));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        Padding(
          padding: Styles.edgeInsetAll16,
          child: MediaQuery.of(context).orientation == Orientation.portrait
              ? CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildHomeWelcome(),
                    _buildTransSummaryPerMonth(),
                    _buildHomeActivity(),
                    _buildTransactionTypeSwitch(),
                    _buildTransactions(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 55,
                      child: CustomScrollView(
                        slivers: [
                          _buildHomeWelcome(),
                          _buildTransSummaryPerMonth(),
                          _buildHomeActivity(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 45,
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          _buildTransactionTypeSwitch(),
                          _buildTransactions(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: Styles.edgeInsetAll16,
            child: FadeTransition(
              opacity: _hideFabAnimController,
              child: ScaleTransition(
                scale: _hideFabAnimController,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () => _scrollController.goToTheTop(),
                  child: const Icon(Icons.arrow_upward),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  Widget _buildHomeWelcome() {
    return const SliverToBoxAdapter(
      child: HomeWelcome(),
    );
  }

  Widget _buildTransSummaryPerMonth() {
    return const SliverToBoxAdapter(child: TransactionSummaryPerMonth());
  }

  Widget _buildTransactionTypeSwitch() {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final i18n = S.of(context);
        return state.maybeMap(
          initial: (state) => SliverToBoxAdapter(
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
                    (ctx, index) => TransactionsCardContainer(model: state.transactionsPerMonth[index]),
                    childCount: state.transactionsPerMonth.length,
                  ),
                ),
              );
            }

            return SliverLoading(
              children: [
                NothingFound(
                  msg: state.showParentTransactions ? i18n.noRecurringTransactionsWereFound : i18n.noTransactionsForThisPeriod,
                ),
              ],
            );
          },
          orElse: () => const SliverLoading(),
        );
      },
    );
  }

  Widget _buildHomeActivity() {
    return const SliverToBoxAdapter(
      child: TransactionsActivityChart(),
    );
  }
}
