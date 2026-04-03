import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_colors.dart';
import 'package:my_expenses/presentation/charts/widgets/empty_chart_preview.dart';
import 'package:my_expenses/presentation/charts/widgets/top_item_row.dart';

class TopCategoriesMiniPreview extends StatelessWidget {
  const TopCategoriesMiniPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartsBloc, ChartsState>(
      builder: (context, state) {
        if (state is! ChartsStateLoaded || state.topCategories.isEmpty) {
          return const EmptyChartPreview(icon: Icons.format_list_numbered);
        }
        final top3 = state.topCategories.take(3).toList();
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: top3.map((c) {
            final icon = c.icon ?? ChartColors.defaultCategoryIcon;
            final color = c.color ?? ChartColors.defaultColor;
            final displayName = c.categoryName;
            return TopItemRow(displayName: displayName, icon: icon, iconColor: color, percentage: c.percentage);
          }).toList(),
        );
      },
    );
  }
}
