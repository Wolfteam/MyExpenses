import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/presentation/charts/widgets/empty_chart_preview.dart';

class TopCategoriesMiniPreview extends StatelessWidget {
  const TopCategoriesMiniPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartsBloc, ChartsState>(
      builder: (context, state) {
        if (state is! ChartsStateLoaded || state.topCategories.isEmpty) {
          return const EmptyChartPreview(icon: Icons.format_list_numbered);
        }
        final theme = Theme.of(context);
        final top3 = state.topCategories.take(3).toList();
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: top3.map((c) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: c.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      c.categoryName,
                      style: theme.textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${c.percentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
