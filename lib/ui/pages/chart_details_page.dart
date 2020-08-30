import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/chart_details/chart_details_bloc.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../common/enums/transaction_filter_type.dart';
import '../../generated/i18n.dart';
import '../../models/chart_transaction_item.dart';
import '../widgets/charts/chart_grouped_transactions_card_container.dart';
import '../widgets/charts/chart_transaction_card_container.dart';
import '../widgets/charts/pie_chart_transactions_per_month.dart';
import '../widgets/sort_direction_popupmenu_filter.dart';
import '../widgets/transactions/transaction_popupmenu_filter.dart';

class ChartDetailsPage extends StatelessWidget {
  final bool onlyIncomes;
  final List<ChartTransactionItem> chartData;

  const ChartDetailsPage({
    @required this.onlyIncomes,
    @required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

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
    final i18n = I18n.of(context);
    final theme = Theme.of(context);

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
          style: theme.textTheme.headline6.copyWith(
            color: onlyIncomes ? Colors.green : Colors.red,
          ),
        ),
      ),
      PieChartTransactionsPerMonths(chartData, 300, 0.8),
      const Divider(),
      ..._buildTransactions(context, state),
    ];
  }

  List<Widget> _buildTransactions(
    BuildContext context,
    ChartDetailsState state,
  ) {
    final i18n = I18n.of(context);
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
                TransactionPoupMenuFilter(
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
        itemCount: state.filter != TransactionFilterType.category
            ? state.transactions.length
            : state.groupedTransactionsByCategory.length,
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
      context.bloc<ChartDetailsBloc>().add(FilterChanged(newValue));

  void _sortDirectionChanged(
    BuildContext context,
    SortDirectionType newValue,
  ) =>
      context.bloc<ChartDetailsBloc>().add(SortDirectionChanged(newValue));
}
