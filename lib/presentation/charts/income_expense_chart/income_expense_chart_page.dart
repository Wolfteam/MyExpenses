import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/charts/income_expense_chart/widgets/income_expense_content.dart';
import 'package:my_expenses/presentation/charts/widgets/charts_period_filter.dart';
import 'package:my_expenses/presentation/shared/loading.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class IncomeExpenseChartPage extends StatelessWidget {
  const IncomeExpenseChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = Injection.incomeExpenseChartBloc;
        final (from, to) = context.read<ChartsBloc>().getDateRange();
        bloc.add(IncomeExpenseChartEvent.load(from: from, to: to));
        return bloc;
      },
      child: const _IncomeExpenseChartView(),
    );
  }
}

class _IncomeExpenseChartView extends StatelessWidget {
  const _IncomeExpenseChartView();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocListener<ChartsBloc, ChartsState>(
      listener: (context, state) {
        final (from, to) = context.read<ChartsBloc>().getDateRange();
        context.read<IncomeExpenseChartBloc>().add(IncomeExpenseChartEvent.load(from: from, to: to));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(i18n.incomeVsExpense)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: Styles.edgeInsetAll16,
              child: ChartsPeriodFilter(),
            ),
            Expanded(
              child: BlocBuilder<IncomeExpenseChartBloc, IncomeExpenseChartState>(
                builder: (context, state) {
                  if (state is! IncomeExpenseChartStateLoaded) {
                    return const SizedBox.shrink();
                  }
                  if (!state.loaded) {
                    return const Loading(useScaffold: false);
                  }
                  if (state.points.isEmpty) {
                    return NothingFound(msg: i18n.noDataForThisPeriod);
                  }
                  return IncomeExpenseContent(points: state.points);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
