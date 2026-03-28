import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/charts/trend_chart/widgets/trend_chart_content.dart';
import 'package:my_expenses/presentation/charts/widgets/charts_period_filter.dart';
import 'package:my_expenses/presentation/shared/loading.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class TrendChartPage extends StatelessWidget {
  const TrendChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = Injection.trendChartBloc;
        final (from, to) = context.read<ChartsBloc>().getDateRange();
        bloc.add(TrendChartEvent.load(from: from, to: to));
        return bloc;
      },
      child: const _TrendChartView(),
    );
  }
}

class _TrendChartView extends StatelessWidget {
  const _TrendChartView();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocListener<ChartsBloc, ChartsState>(
      listener: (context, state) {
        final (from, to) = context.read<ChartsBloc>().getDateRange();
        context.read<TrendChartBloc>().add(TrendChartEvent.load(from: from, to: to));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(i18n.balanceTrend)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: Styles.edgeInsetAll16,
              child: ChartsPeriodFilter(),
            ),
            Expanded(
              child: BlocBuilder<TrendChartBloc, TrendChartState>(
                builder: (context, state) {
                  if (state is! TrendChartStateLoaded) {
                    return const SizedBox.shrink();
                  }
                  if (!state.loaded) {
                    return const Loading(useScaffold: false);
                  }
                  if (state.trendPoints.isEmpty && state.monthlyPoints.isEmpty) {
                    return NothingFound(msg: i18n.noDataForThisPeriod);
                  }
                  return TrendChartContent(
                    trendPoints: state.trendPoints,
                    monthlyPoints: state.monthlyPoints,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
