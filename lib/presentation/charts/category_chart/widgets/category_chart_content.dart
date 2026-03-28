import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/charts/category_chart_item.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class CategoryChartContent extends StatelessWidget {
  final List<CategoryChartItem> categories;

  const CategoryChartContent({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Styles.edgeInsetAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: categories.map((item) {
                  return PieChartSectionData(
                    color: item.color,
                    value: item.total,
                    title: '${item.percentage.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((item) => _CategoryRow(item: item)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryChartItem item;

  const _CategoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyBloc = context.read<CurrencyBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Text(item.categoryName, style: theme.textTheme.bodyMedium),
          ),
          Text(
            currencyBloc.format(item.total),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              '${item.percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
