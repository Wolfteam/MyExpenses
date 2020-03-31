import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/currency/currency_bloc.dart';
import '../../../bloc/transactions_last_7_days/transactions_last_7_days_bloc.dart';
import '../../../common/enums/transaction_type.dart';
import '../../../common/utils/date_utils.dart';
import '../../../generated/i18n.dart';
import '../../../models/transactions_summary_per_day.dart';

class HomeLast7DaysSummary extends StatelessWidget {
  final List<TransactionsSummaryPerDay> incomes;
  final List<TransactionsSummaryPerDay> expenses;

  const HomeLast7DaysSummary({
    @required this.incomes,
    @required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(60),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child:
            BlocBuilder<TransactionsLast7DaysBloc, TransactionsLast7DaysState>(
          builder: (ctx, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildPage(state, ctx),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPage(
    TransactionsLast7DaysState state,
    BuildContext context,
  ) {
    bool incomesIsChecked;
    if (state is TransactionsLast7DaysInitialState) {
      incomesIsChecked = true;
    }

    if (state is Last7DaysTransactionTypeChangedState) {
      incomesIsChecked = state.selectedType == TransactionType.incomes;
    }

    return [
      _buildTitle(incomesIsChecked, context),
      _buildBarChart(incomesIsChecked, context),
    ];
  }

  List<charts.Series<TransactionsSummaryPerDay, String>> _createSampleData(
    List<TransactionsSummaryPerDay> data,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelStyle = charts.TextStyleSpec(
      fontSize: 10,
      lineHeight: 1.0,
      color: charts.ColorUtil.fromDartColor(
        isDark ? Colors.white : Colors.black,
      ),
    );

    final currencyBloc = context.bloc<CurrencyBloc>();

    return [
      charts.Series<TransactionsSummaryPerDay, String>(
        id: 'HomeLast7DaysSummary',
        data: data,
        colorFn: (item, __) => charts.ColorUtil.fromDartColor(item.color),
        domainFn: (item, _) => DateUtils.formatDateWithoutLocale(
          item.date,
          DateUtils.dayAndMonthFormat,
        ),
        measureFn: (item, _) => item.totalDayAmount,
        insideLabelStyleAccessorFn: (item, index) => labelStyle,
        outsideLabelStyleAccessorFn: (item, index) => labelStyle,
        labelAccessorFn: (item, _) => currencyBloc.format(
          item.totalDayAmount,
          showSymbol: false,
        ),
      ),
    ];
  }

  Widget _buildTitle(bool incomesIsChecked, BuildContext context) {
    final i18n = I18n.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            i18n.last7Days,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        PopupMenuButton(
          padding: const EdgeInsets.all(0),
          initialValue: incomesIsChecked
              ? TransactionType.incomes
              : TransactionType.expenses,
          onSelected: (TransactionType newValue) {
            context
                .bloc<TransactionsLast7DaysBloc>()
                .add(Last7DaysTransactionTypeChanged(selectedType: newValue));
          },
          itemBuilder: (context) => <PopupMenuItem<TransactionType>>[
            CheckedPopupMenuItem<TransactionType>(
              checked: incomesIsChecked,
              value: TransactionType.incomes,
              child: Text(i18n.incomes),
            ),
            CheckedPopupMenuItem<TransactionType>(
              checked: !incomesIsChecked,
              value: TransactionType.expenses,
              child: Text(i18n.expenses),
            )
          ],
        )
      ],
    );
  }

  Widget _buildBarChart(
    bool incomesIsChecked,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final lineColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Container(
      height: 180,
      child: charts.BarChart(
        _createSampleData(incomesIsChecked ? incomes : expenses, context),
        animate: true,
        vertical: true,
        barRendererDecorator: charts.BarLabelDecorator<String>(),
        domainAxis: charts.OrdinalAxisSpec(
          showAxisLine: false,
          renderSpec: charts.SmallTickRendererSpec(
            labelRotation: 45,
            axisLineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(
                Colors.white,
              ),
              thickness: 5,
            ),
            labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(
                incomesIsChecked ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          showAxisLine: false,
          renderSpec: charts.GridlineRendererSpec(
            axisLineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(lineColor),
            ),
            labelStyle: charts.TextStyleSpec(
              color: charts.ColorUtil.fromDartColor(lineColor),
            ),
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(lineColor),
            ),
          ),
        ),
      ),
    );
  }
}
