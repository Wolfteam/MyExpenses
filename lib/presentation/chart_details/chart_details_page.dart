import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_grouped_transactions_card_container.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_transaction_card_container.dart';
import 'package:my_expenses/presentation/charts/widgets/pie_chart_transactions_per_month.dart';
import 'package:my_expenses/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:my_expenses/presentation/shared/transaction_popupmenu_filter.dart';

class ChartDetailsPage extends StatelessWidget {
  final bool onlyIncomes;
  final List<ChartTransactionItem> chartData;

  const ChartDetailsPage({
    required this.onlyIncomes,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.details),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: BlocBuilder<ChartDetailsBloc, ChartDetailsState>(
          builder: (ctx, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildPage(context, state),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildPage(BuildContext context, ChartDetailsState state) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final double aspectRatio = MediaQuery.of(context).orientation == Orientation.portrait ? 3 / 2 : 3 / 1;

    return [
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
      AspectRatio(aspectRatio: aspectRatio, child: PieChartTransactionsPerMonths(chartData, 30)),
      const Divider(),
      ..._buildTransactions(context, state),
    ];
  }

  List<Widget> _buildTransactions(BuildContext context, ChartDetailsState state) {
    final i18n = S.of(context);
    final theme = Theme.of(context);

    return [
      Padding(
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
                  selectedValue: state.filter,
                  onSelected: (filter) => _filterChanged(context, filter),
                ),
                SortDirectionPopupMenuFilter(
                  selectedSortDirection: state.sortDirection,
                  onSelected: (newValue) => _sortDirectionChanged(context, newValue),
                ),
              ],
            ),
          ],
        ),
      ),
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
      )
    ];
  }

  void _filterChanged(BuildContext context, TransactionFilterType newValue) =>
      context.read<ChartDetailsBloc>().add(ChartDetailsEvent.filterChanged(selectedFilter: newValue));

  void _sortDirectionChanged(BuildContext context, SortDirectionType newValue) =>
      context.read<ChartDetailsBloc>().add(ChartDetailsEvent.sortDirectionChanged(selectedDirection: newValue));
}
