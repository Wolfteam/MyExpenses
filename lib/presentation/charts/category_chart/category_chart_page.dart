import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/charts/category_chart/widgets/category_chart_content.dart';
import 'package:my_expenses/presentation/charts/widgets/charts_period_filter.dart';
import 'package:my_expenses/presentation/shared/loading.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class CategoryChartPage extends StatelessWidget {
  const CategoryChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = Injection.categoryChartBloc;
        final (from, to) = context.read<ChartsBloc>().getDateRange();
        bloc.add(CategoryChartEvent.load(from: from, to: to));
        return bloc;
      },
      child: const _CategoryChartView(),
    );
  }
}

class _CategoryChartView extends StatelessWidget {
  const _CategoryChartView();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocListener<ChartsBloc, ChartsState>(
      listener: (context, state) {
        final (from, to) = context.read<ChartsBloc>().getDateRange();
        context.read<CategoryChartBloc>().add(CategoryChartEvent.load(from: from, to: to));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(i18n.spendingByCategory)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: Styles.edgeInsetAll16,
              child: ChartsPeriodFilter(),
            ),
            Expanded(
              child: BlocBuilder<CategoryChartBloc, CategoryChartState>(
                builder: (context, state) {
                  if (state is! CategoryChartStateLoaded) {
                    return const SizedBox.shrink();
                  }
                  if (!state.loaded) {
                    return const Loading(useScaffold: false);
                  }
                  if (state.categories.isEmpty) {
                    return NothingFound(msg: i18n.noDataForThisPeriod);
                  }
                  return CategoryChartContent(categories: state.categories);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
