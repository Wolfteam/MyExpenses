import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_colors.dart';
import 'package:my_expenses/presentation/charts/widgets/empty_chart_preview.dart';
import 'package:my_expenses/presentation/charts/widgets/top_item_row.dart';

class PaymentMethodMiniPreview extends StatelessWidget {
  const PaymentMethodMiniPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartsBloc, ChartsState>(
      builder: (context, state) {
        if (state is! ChartsStateLoaded || state.topPaymentMethods.isEmpty) {
          return const EmptyChartPreview(icon: Icons.credit_card);
        }
        final i18n = S.of(context);
        final top3 = state.topPaymentMethods.take(3).toList();
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: top3.map((m) {
            final icon = m.icon ?? ChartColors.defaultPaymentMethodIcon(m.type);
            final color = m.iconColor ?? ChartColors.defaultColor;
            final displayName = m.methodName.isEmpty ? i18n.noPaymentMethod : m.methodName;
            return TopItemRow(displayName: displayName, icon: icon, iconColor: color, percentage: m.percentage);
          }).toList(),
        );
      },
    );
  }
}
