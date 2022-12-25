import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_grouped_transactions_card_container.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_transaction_card_container.dart';
import 'package:my_expenses/presentation/charts/widgets/pie_chart_transactions_per_month.dart';
import 'package:my_expenses/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:my_expenses/presentation/shared/transaction_popupmenu_filter.dart';

class ChartDetailsPage extends StatelessWidget {
  final bool onlyIncomes;
  final List<TransactionItem> transactions;

  const ChartDetailsPage({
    required this.onlyIncomes,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final chartData = TransactionUtils.buildChartTransactionItems(transactions, onlyIncomes: onlyIncomes);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.details)),
      body: BlocProvider<ChartDetailsBloc>(
        create: (ctx) => ChartDetailsBloc()..add(ChartDetailsEvent.initialize(transactions: transactions)),
        child: isPortrait
            ? SingleChildScrollView(
                padding: const EdgeInsets.only(top: 10),
                child: _PortraitLayout(onlyIncomes: onlyIncomes, chartData: chartData),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _LandscapeLayout(onlyIncomes: onlyIncomes, chartData: chartData),
              ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final bool onlyIncomes;
  final List<ChartTransactionItem> chartData;

  const _Body({
    required this.onlyIncomes,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? _PortraitLayout(onlyIncomes: onlyIncomes, chartData: chartData)
        : _LandscapeLayout(onlyIncomes: onlyIncomes, chartData: chartData);
  }
}

class _PortraitLayout extends StatelessWidget {
  final bool onlyIncomes;
  final List<ChartTransactionItem> chartData;

  const _PortraitLayout({
    required this.onlyIncomes,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<ChartDetailsBloc, ChartDetailsState>(
      builder: (ctx, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: Text(
              onlyIncomes ? i18n.incomes : i18n.expenses,
              style: theme.textTheme.headline6,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: Text(
              '${state.transactionsTotalAmount} \$',
              style: theme.textTheme.headline6!.copyWith(color: onlyIncomes ? Colors.green : Colors.red),
            ),
          ),
          AspectRatio(aspectRatio: 3 / 2, child: PieChartTransactionsPerMonths(chartData, 45)),
          const Divider(),
          _FilterRow(filterType: state.filter, sortDirectionType: state.sortDirection),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: state.filter != TransactionFilterType.category ? state.transactions.length : state.groupedTransactionsByCategory.length,
            itemBuilder: (ctx, index) => state.filter != TransactionFilterType.category
                ? ChartTransactionCardContainer(
                    state.transactions[index],
                    state.transactionsTotalAmount,
                  )
                : ChartGroupedTransactionsCardContainer(
                    grouped: state.groupedTransactionsByCategory[index],
                    transactionsTotalAmount: state.transactionsTotalAmount,
                  ),
          ),
        ],
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final bool onlyIncomes;
  final List<ChartTransactionItem> chartData;

  const _LandscapeLayout({
    required this.onlyIncomes,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<ChartDetailsBloc, ChartDetailsState>(
      builder: (ctx, state) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text(
                    onlyIncomes ? i18n.incomes : i18n.expenses,
                    style: theme.textTheme.headline6,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text(
                    '${state.transactionsTotalAmount} \$',
                    style: theme.textTheme.headline6!.copyWith(color: onlyIncomes ? Colors.green : Colors.red),
                  ),
                ),
                Expanded(child: PieChartTransactionsPerMonths(chartData, 30)),
              ],
            ),
          ),
          Expanded(
            flex: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FilterRow(filterType: state.filter, sortDirectionType: state.sortDirection),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        state.filter != TransactionFilterType.category ? state.transactions.length : state.groupedTransactionsByCategory.length,
                    itemBuilder: (ctx, index) => state.filter != TransactionFilterType.category
                        ? ChartTransactionCardContainer(
                            state.transactions[index],
                            state.transactionsTotalAmount,
                          )
                        : ChartGroupedTransactionsCardContainer(
                            grouped: state.groupedTransactionsByCategory[index],
                            transactionsTotalAmount: state.transactionsTotalAmount,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final TransactionFilterType filterType;
  final SortDirectionType sortDirectionType;

  const _FilterRow({
    required this.filterType,
    required this.sortDirectionType,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            i18n.transactions,
            style: theme.textTheme.headline6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TransactionPopupMenuFilter(
                selectedValue: filterType,
                onSelected: (filter) => _filterChanged(context, filter),
              ),
              SortDirectionPopupMenuFilter(
                selectedSortDirection: sortDirectionType,
                onSelected: (newValue) => _sortDirectionChanged(context, newValue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _filterChanged(BuildContext context, TransactionFilterType newValue) =>
      context.read<ChartDetailsBloc>().add(ChartDetailsEvent.filterChanged(selectedFilter: newValue));

  void _sortDirectionChanged(BuildContext context, SortDirectionType newValue) =>
      context.read<ChartDetailsBloc>().add(ChartDetailsEvent.sortDirectionChanged(selectedDirection: newValue));
}
