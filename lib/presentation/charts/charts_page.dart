import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/charts/category_chart/category_chart_page.dart';
import 'package:my_expenses/presentation/charts/income_expense_chart/income_expense_chart_page.dart';
import 'package:my_expenses/presentation/charts/trend_chart/trend_chart_page.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_card.dart';
import 'package:my_expenses/presentation/charts/widgets/charts_period_filter.dart';
import 'package:my_expenses/presentation/charts/widgets/charts_summary_cards.dart';
import 'package:my_expenses/presentation/charts/widgets/income_expense_mini_preview.dart';
import 'package:my_expenses/presentation/charts/widgets/top_categories_mini_preview.dart';
import 'package:my_expenses/presentation/charts/widgets/trend_mini_preview.dart';
import 'package:my_expenses/presentation/shared/loading.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const ChartsPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChartsBloc>(
      create: (_) => Injection.chartsBloc..add(const ChartsEvent.init()),
      child: const _ChartsView(),
    );
  }
}

class _ChartsView extends StatelessWidget {
  const _ChartsView();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.charts)),
      body: BlocBuilder<ChartsBloc, ChartsState>(
        builder: (context, state) {
          if (state is! ChartsStateLoaded || !state.loaded) {
            return const Loading(useScaffold: false);
          }
          return const _ChartsContent();
        },
      ),
    );
  }
}

class _ChartsContent extends StatelessWidget {
  const _ChartsContent();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return ListView(
      padding: Styles.edgeInsetAll16,
      children: [
        const ChartsPeriodFilter(),
        const SizedBox(height: 16),
        const ChartsSummaryCards(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ChartCard(
                title: i18n.incomeVsExpense,
                icon: Icons.bar_chart,
                preview: const IncomeExpenseMiniPreview(),
                onTap: () => _pushDetail(context, const IncomeExpenseChartPage()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChartCard(
                title: i18n.balanceTrend,
                icon: Icons.show_chart,
                preview: const TrendMiniPreview(),
                onTap: () => _pushDetail(context, const TrendChartPage()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ChartCard(
          title: i18n.topCategories,
          icon: Icons.format_list_numbered,
          preview: const TopCategoriesMiniPreview(),
          onTap: () => _pushDetail(context, const CategoryChartPage()),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _pushDetail(BuildContext context, Widget page) {
    final chartsBloc = context.read<ChartsBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(value: chartsBloc, child: page),
      ),
    );
  }
}
