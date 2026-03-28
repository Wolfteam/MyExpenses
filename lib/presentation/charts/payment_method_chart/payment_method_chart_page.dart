import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/charts/payment_method_chart/widgets/payment_method_chart_content.dart';
import 'package:my_expenses/presentation/charts/widgets/charts_period_filter.dart';
import 'package:my_expenses/presentation/shared/loading.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class PaymentMethodChartPage extends StatelessWidget {
  const PaymentMethodChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = Injection.paymentMethodChartBloc;
        final (from, to) = context.read<ChartsBloc>().getDateRange();
        bloc.add(PaymentMethodChartEvent.load(from: from, to: to));
        return bloc;
      },
      child: const _PaymentMethodChartView(),
    );
  }
}

class _PaymentMethodChartView extends StatelessWidget {
  const _PaymentMethodChartView();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocListener<ChartsBloc, ChartsState>(
      listener: (context, state) {
        final (from, to) = context.read<ChartsBloc>().getDateRange();
        context.read<PaymentMethodChartBloc>().add(PaymentMethodChartEvent.load(from: from, to: to));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(i18n.paymentMethodChartTitle)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: Styles.edgeInsetAll16,
              child: ChartsPeriodFilter(),
            ),
            Expanded(
              child: BlocBuilder<PaymentMethodChartBloc, PaymentMethodChartState>(
                builder: (context, state) {
                  if (state is! PaymentMethodChartStateLoaded) {
                    return const SizedBox.shrink();
                  }
                  if (!state.loaded) {
                    return const Loading(useScaffold: false);
                  }
                  if (state.methods.isEmpty) {
                    return NothingFound(msg: i18n.noDataForThisPeriod);
                  }
                  return PaymentMethodChartContent(methods: state.methods);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
