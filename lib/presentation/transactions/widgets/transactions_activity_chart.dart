import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/iterable_extensions.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class TransactionsActivityChart extends StatelessWidget with TransactionMixin {
  const TransactionsActivityChart();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CurrencyBloc>();
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold);
    final expenseTextStyle = textStyle.copyWith(color: getTransactionColor());
    final incomeTextStyle = textStyle.copyWith(color: getTransactionColor(isAnIncome: true));
    return BlocBuilder<TransactionsActivityBloc, TransactionsActivityState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(selected: state.type),
          Text(
            i18n.balance,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            bloc.format(state.balance),
            style: state.balance == 0
                ? textStyle
                : state.balance > 0
                    ? incomeTextStyle
                    : expenseTextStyle,
            textAlign: TextAlign.center,
          ),
          _Chart(
            dateRangeType: state.type,
            selectedActivityTypes: state.selectedActivityTypes,
            transactions: state.transactions,
          ),
          _ChartLegend(
            selectedActivityTypes: state.selectedActivityTypes,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TransactionActivityDateRangeType selected;

  const _Header({
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final S i18n = S.of(context);
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            i18n.activity,
            style: theme.textTheme.titleLarge,
          ),
          ToggleButtons(
            onPressed: (index) {
              final dateRangeType = TransactionActivityDateRangeType.values[index];
              context.read<TransactionsActivityBloc>().add(TransactionsActivityEvent.dateRangeChanged(type: dateRangeType));
            },
            constraints: const BoxConstraints(minWidth: 50, minHeight: 36.0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            borderRadius: BorderRadius.circular(5),
            isSelected: TransactionActivityDateRangeType.values.map((el) => el == selected).toList(),
            textStyle: theme.textTheme.labelSmall,
            children: [
              Padding(
                padding: Styles.edgeInsetHorizontal5,
                child: Text(i18n.last7Days),
              ),
              Padding(
                padding: Styles.edgeInsetHorizontal5,
                child: Text(i18n.monthly),
              ),
              Padding(
                padding: Styles.edgeInsetHorizontal5,
                child: Text(i18n.yearly),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget with TransactionMixin {
  final TransactionActivityDateRangeType dateRangeType;
  final List<TransactionActivityType> selectedActivityTypes;
  final List<TransactionActivityPerDate> transactions;

  const _Chart({
    required this.dateRangeType,
    required this.selectedActivityTypes,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CurrencyBloc>();
    final theme = Theme.of(context);
    final (TextStyle tooltipTextStyle, BoxDecoration tooltipBoxDecoration, EdgeInsets tooltipPadding) = Styles.getTooltipStyling(context);
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    final List<Color> balanceColors = [
      accentColor.withOpacity(0.5),
      accentColor,
    ];
    final Color incomeColor = getTransactionColor(isAnIncome: true);
    final Color expenseColor = getTransactionColor();
    final List<Color> incomeColors = [
      incomeColor.withOpacity(0.5),
      incomeColor,
    ];
    final List<Color> expenseColors = [
      expenseColor.withOpacity(0.5),
      expenseColor,
    ];

    final List<FlSpot> headerSpots = [];
    final List<FlSpot> balanceSpots = [];
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];
    double yMaxValue = 10;
    double yMinValue = -10;
    for (int i = 0; i < transactions.length; i++) {
      final TransactionActivityPerDate transaction = transactions[i];
      final double x = i.toDouble();
      headerSpots.add(FlSpot(x, 0));
      balanceSpots.add(FlSpot(x, transaction.balance));
      incomeSpots.add(FlSpot(x, transaction.income));
      expenseSpots.add(FlSpot(x, transaction.expense));

      if (yMaxValue < transaction.income && selectedActivityTypes.isNotEmpty) {
        yMaxValue = transaction.income;
      }

      if (yMinValue > transaction.expense && selectedActivityTypes.isNotEmpty) {
        yMinValue = transaction.expense;
      }
    }

    final bool hasData = transactions.any((trans) => trans.balance != 0);
    final colorSpotMap = <List<Color>, List<FlSpot>>{};

    if (selectedActivityTypes.isNotEmpty) {
      colorSpotMap.putIfAbsent([], () => headerSpots);
    }

    if (selectedActivityTypes.contains(TransactionActivityType.balance)) {
      colorSpotMap.putIfAbsent(balanceColors, () => balanceSpots);
    }

    if (selectedActivityTypes.contains(TransactionActivityType.incomes)) {
      colorSpotMap.putIfAbsent(incomeColors, () => incomeSpots);
    }

    if (selectedActivityTypes.contains(TransactionActivityType.expenses)) {
      colorSpotMap.putIfAbsent(expenseColors, () => expenseSpots);
    }

    final dotData = FlDotData(
      getDotPainter: (x, y, z, w) => FlDotCirclePainter(
        color: Colors.white,
        strokeColor: Colors.black,
        strokeWidth: 2,
        radius: 5,
      ),
      checkToShowDot: (spot, barData) => barData.color != Colors.transparent,
      show: hasData,
    );

    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 15, bottom: 15, right: 20),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: false,
            checkToShowHorizontalLine: (_) => true,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Colors.grey,
              strokeWidth: 0.01,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                maxIncluded: false,
                minIncluded: false,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  axisSide: meta.axisSide,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  child: Tooltip(
                    message: bloc.format(value),
                    child: Text(
                      meta.formattedValue,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: transactions.length - 1,
          minY: yMinValue,
          maxY: yMaxValue,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => tooltipBoxDecoration.color!,
              tooltipPadding: tooltipPadding,
              tooltipMargin: 0,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (values) => _getToolTipItems(bloc, tooltipTextStyle, values, incomeColors, expenseColors, balanceColors),
            ),
          ),
          lineBarsData: colorSpotMap.entries
              .map(
                (kvp) => LineChartBarData(
                  spots: kvp.value,
                  shadow: kvp.key.isEmpty ? const Shadow(color: Colors.transparent) : Shadow(color: kvp.key.first),
                  dotData: dotData,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: kvp.key.isEmpty ? Colors.transparent : null,
                  gradient: kvp.key.isEmpty ? null : LinearGradient(colors: kvp.key),
                  barWidth: 3.5,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  List<LineTooltipItem?> _getToolTipItems(
    CurrencyBloc bloc,
    TextStyle tooltipTextStyle,
    List<LineBarSpot> values,
    List<Color> incomeColors,
    List<Color> expenseColors,
    List<Color> totalColors,
  ) {
    final Map<int, LineTooltipItem> tooltipItems = {};
    for (final LineBarSpot spot in values) {
      final Color? color = spot.bar.gradient?.colors.first ?? spot.bar.color;
      final TextStyle style = tooltipTextStyle.copyWith(color: color, fontWeight: FontWeight.bold);
      LineTooltipItem toolTipItem = LineTooltipItem(bloc.format(spot.y), style);
      if (color == Colors.transparent) {
        final int i = spot.spotIndex;
        final String? header = switch (dateRangeType) {
          TransactionActivityDateRangeType.last7days => transactions[i].dateRangeString,
          TransactionActivityDateRangeType.monthly => transactions[i].dateRangeString,
          TransactionActivityDateRangeType.yearly => toBeginningOfSentenceCase(DateFormat('MMMM').format(DateTime(2024, spot.spotIndex + 1))),
        };

        toolTipItem = LineTooltipItem(header!, tooltipTextStyle.copyWith(fontWeight: FontWeight.bold));
      }
      final int index = incomeColors.contains(color)
          ? 1
          : expenseColors.contains(color)
              ? 2
              : totalColors.contains(color)
                  ? 3
                  : 0;
      tooltipItems.putIfAbsent(index, () => toolTipItem);
    }

    return tooltipItems.entries.sorted((a, b) => a.key.compareTo(b.key)).map((kvp) => kvp.value).toList();
  }
}

class _ChartLegend extends StatelessWidget with TransactionMixin {
  final List<TransactionActivityType> selectedActivityTypes;

  const _ChartLegend({
    required this.selectedActivityTypes,
  });

  @override
  Widget build(BuildContext context) {
    final S i18n = S.of(context);
    final ThemeData theme = Theme.of(context);

    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: TransactionActivityType.values
          .mapIndex(
            (type, i) => _ChartLegendIndicator(
              selected: selectedActivityTypes.contains(type),
              text: i == 0
                  ? i18n.balance
                  : i == 1
                      ? i18n.incomes
                      : i18n.expenses,
              color: i == 0 ? theme.colorScheme.primaryContainer : getTransactionColor(isAnIncome: i == 1),
              onTap: () => context.read<TransactionsActivityBloc>().add(TransactionsActivityEvent.activitySelected(type: type)),
            ),
          )
          .toList(),
    );
  }
}

class _ChartLegendIndicator extends StatelessWidget {
  final String text;
  final Color color;
  final bool selected;
  final GestureTapCallback onTap;

  const _ChartLegendIndicator({
    required this.text,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double size = 16;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: Styles.edgeInsetHorizontal5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
              child: selected ? const Icon(Icons.check_circle_outline, size: size / 1.2) : null,
            ),
            Text(
              text,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
