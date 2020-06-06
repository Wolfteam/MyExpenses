import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/chart_details/chart_details_bloc.dart';
import '../../common/enums/chart_details_filter_type.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../common/extensions/i18n_extensions.dart';
import '../../generated/i18n.dart';
import '../../models/chart_transaction_item.dart';
import '../widgets/charts/chart_grouped_transactions_card_container.dart';
import '../widgets/charts/chart_transaction_card_container.dart';
import '../widgets/charts/pie_chart_transactions_per_month.dart';

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

  PopupMenuButton _buildFilters(
    BuildContext context,
    ChartDetailsState state,
  ) {
    final i18n = I18n.of(context);
    final values = ChartDetailsFilterType.values.map((filter) {
      return CheckedPopupMenuItem<ChartDetailsFilterType>(
        checked: state.filter == filter,
        value: filter,
        child: Text(i18n.getChartDetailsFilterName(filter)),
      );
    }).toList();

    return PopupMenuButton<ChartDetailsFilterType>(
      padding: const EdgeInsets.all(0),
      initialValue: state.filter,
      icon: Icon(Icons.swap_horiz),
      onSelected: (filter) => _filterChanged(context, filter),
      itemBuilder: (context) => values,
    );
  }

  PopupMenuButton _buildSortDirection(
    BuildContext context,
    ChartDetailsState state,
  ) {
    final i18n = I18n.of(context);
    final values = SortDirectionType.values.map((direction) {
      return CheckedPopupMenuItem<SortDirectionType>(
        checked: state.sortDirection == direction,
        value: direction,
        child: Text(i18n.getSortDirectionName(direction)),
      );
    }).toList();
    return PopupMenuButton<SortDirectionType>(
      padding: const EdgeInsets.all(0),
      initialValue: state.sortDirection,
      icon: Icon(Icons.swap_vert),
      onSelected: (direction) => _sortDirectionChanged(context, direction),
      itemBuilder: (context) => values,
    );
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
                _buildFilters(context, state),
                _buildSortDirection(context, state),
              ],
            ),
          ],
        ),
      ),
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: state.filter != ChartDetailsFilterType.category
            ? state.transactions.length
            : state.groupedTransactionsByCategory.length,
        itemBuilder: (ctx, index) =>
            state.filter != ChartDetailsFilterType.category
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

  void _filterChanged(BuildContext context, ChartDetailsFilterType newValue) =>
      context.bloc<ChartDetailsBloc>().add(FilterChanged(newValue));

  void _sortDirectionChanged(
    BuildContext context,
    SortDirectionType newValue,
  ) =>
      context.bloc<ChartDetailsBloc>().add(SortDirectionChanged(newValue));
}
