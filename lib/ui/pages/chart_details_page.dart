import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/chart_details/chart_details_bloc.dart';
import '../../common/enums/chart_details_filter_type.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../common/utils/date_utils.dart';
import '../../common/utils/transaction_utils.dart';
import '../../common/extensions/i18n_extensions.dart';
import '../../generated/i18n.dart';
import '../../models/chart_transaction_item.dart';
import '../../models/transaction_item.dart';
import '../widgets/charts/pie_chart_transactions_per_month.dart';
import '../widgets/transactions/transaction_item.dart' as trans_item;

class ChartDetailsPage extends StatelessWidget {
  final bool onlyIncomes;
  // final List<TransactionItem> transactions;
  final List<ChartTransactionItem> chartData;

  const ChartDetailsPage({
    @required this.onlyIncomes,
    // @required this.transactions,
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
          style: theme.textTheme.title,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 20),
        child: Text(
          '${state.transactionsTotalAmount} \$',
          style: theme.textTheme.title.copyWith(
            color: onlyIncomes ? Colors.green : Colors.red,
          ),
        ),
      ),
      PieChartTransactionsPerMonths(chartData, 300, 0.7),
      const Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              i18n.transactions,
              style: theme.textTheme.title,
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
        itemCount: state.transactions.length,
        itemBuilder: (ctx, index) =>
            _buildTransactionItem(context, state, state.transactions[index]),
      ),
    ];
  }

  Widget _buildTransactionItem(
    BuildContext context,
    ChartDetailsState state,
    TransactionItem item,
  ) {
    final i18n = I18n.of(context);
    final formattedDate = DateUtils.formatDateWithoutLocale(
      item.transactionDate,
      DateUtils.monthDayAndYearFormat,
    );
    final dateString = '${i18n.date}: $formattedDate';
    final percentageString =
        (item.amount.round() * 100 / state.transactionsTotalAmount)
            .toStringAsFixed(2);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  dateString,
                  textAlign: TextAlign.start,
                ),
                Text('$percentageString %'),
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
          trans_item.TransactionItem(item: item),
        ],
      ),
    );
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

  void _filterChanged(BuildContext context, ChartDetailsFilterType newValue) =>
      context.bloc<ChartDetailsBloc>().add(FilterChanged(newValue));

  void _sortDirectionChanged(
    BuildContext context,
    SortDirectionType newValue,
  ) =>
      context.bloc<ChartDetailsBloc>().add(SortDirectionChanged(newValue));
}
