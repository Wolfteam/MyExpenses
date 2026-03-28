import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/charts/widgets/empty_chart_preview.dart';

class PaymentMethodMiniPreview extends StatelessWidget {
  const PaymentMethodMiniPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartsBloc, ChartsState>(
      builder: (context, state) {
        if (state is! ChartsStateLoaded || state.topPaymentMethods.isEmpty) {
          return const EmptyChartPreview(icon: Icons.credit_card);
        }
        final theme = Theme.of(context);
        final i18n = S.of(context);
        final top3 = state.topPaymentMethods.take(3).toList();
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: top3.map((m) {
            final color = m.iconColor ?? Colors.grey;
            final displayName = m.methodName.isEmpty ? i18n.noPaymentMethod : m.methodName;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  if (m.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(m.icon, size: 10, color: color),
                    )
                  else
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      displayName,
                      style: theme.textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${m.percentage.toStringAsFixed(0)}%',
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
