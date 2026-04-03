import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/domain/models/charts/category_chart_item.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_colors.dart';
import 'package:my_expenses/presentation/charts/widgets/spending_item_row.dart';
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
                  final showLabel = item.percentage >= 5.0;
                  final color = item.color ?? ChartColors.defaultColor;
                  final luminance = color.computeLuminance();
                  final textColor = luminance > 0.4 ? Colors.black : Colors.white;
                  return PieChartSectionData(
                    color: item.color,
                    value: item.total,
                    title: showLabel ? '${item.percentage.toStringAsFixed(1)}%' : '',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map(
            (item) => SpendingItemRow(
              displayName: item.categoryName,
              icon: item.icon ?? ChartColors.defaultCategoryIcon,
              iconColor: item.color ?? ChartColors.defaultColor,
              total: item.total,
              percentage: item.percentage,
            ),
          ),
        ],
      ),
    );
  }
}
