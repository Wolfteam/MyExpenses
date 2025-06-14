import 'package:flutter/material.dart';
import 'package:my_expenses/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/transactions/widgets/home_welcome.dart';
import 'package:my_expenses/presentation/transactions/widgets/transactions_activity_chart.dart';
import 'package:my_expenses/presentation/transactions/widgets/transactions_list.dart';
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
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        Padding(
          padding: Styles.edgeInsetAll16,
          child:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? CustomScrollView(
                    controller: _scrollController,
                    slivers: [_buildHomeWelcome(), _buildTransSummaryPerMonth(), _buildHomeActivity(), _buildTransactions()],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(flex: 55, child: CustomScrollView(slivers: [_buildHomeWelcome(), _buildTransSummaryPerMonth(), _buildHomeActivity()])),
                      Expanded(flex: 45, child: CustomScrollView(controller: _scrollController, slivers: [_buildTransactions()])),
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
                child: FloatingActionButton(mini: true, onPressed: () => _scrollController.goToTheTop(), child: const Icon(Icons.arrow_upward)),
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
    return const SliverToBoxAdapter(child: HomeWelcome());
  }

  Widget _buildTransSummaryPerMonth() {
    return const SliverToBoxAdapter(child: TransactionSummaryPerMonth());
  }

  Widget _buildTransactions() {
    return const TransactionsList();
  }

  Widget _buildHomeActivity() {
    return const SliverToBoxAdapter(child: TransactionsActivityChart());
  }
}
