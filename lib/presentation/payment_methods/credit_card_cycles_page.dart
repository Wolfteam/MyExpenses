import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';

class CreditCardCyclesPage extends StatelessWidget {
  const CreditCardCyclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocProvider(
      create: (_) => Injection.creditCardCyclesBloc..add(const CreditCardCyclesEvent.load()),
      child: Scaffold(
        appBar: AppBar(title: Text(i18n.creditCardCycles)),
        body: BlocBuilder<CreditCardCyclesBloc, CreditCardCyclesState>(
          builder: (context, state) {
            return switch (state) {
              CreditCardCyclesStateLoading() => const Center(child: CircularProgressIndicator()),
              final CreditCardCyclesStateLoaded s when s.items.isEmpty =>
                Center(child: Text(i18n.noPaymentMethodsYet)),
              final CreditCardCyclesStateLoaded s => ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: s.items.length,
                  itemBuilder: (context, index) => _CycleCard(item: s.items[index]),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  final CreditCardCycleItem item;
  const _CycleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final df = DateFormat.yMMMd();
    final m = item.paymentMethod;
    final today = DateTime.now();

    Color chipColor = Colors.green;
    if (item.nextDueDate != null) {
      final days = item.nextDueDate!
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      if (days < 0) {
        chipColor = Colors.red;
      } else if (days <= 7) {
        chipColor = Colors.amber;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(m.icon, color: m.iconColor),
                const SizedBox(width: 8),
                Text(m.name, style: theme.textTheme.titleMedium),
              ],
            ),
            const Divider(height: 20),
            Text(i18n.currentCycle, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              '${df.format(item.cycleStart)} — ${df.format(item.cycleNextClose)}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i18n.statementCloseDay, style: theme.textTheme.labelSmall),
                      const SizedBox(height: 2),
                      Text(
                        m.statementCloseDay != null ? '${m.statementCloseDay}' : i18n.na,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i18n.paymentDueDay, style: theme.textTheme.labelSmall),
                      const SizedBox(height: 2),
                      Text(
                        m.paymentDueDay != null ? '${m.paymentDueDay}' : i18n.na,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.nextDueDate != null) ...[
              const SizedBox(height: 12),
              Chip(
                avatar: Icon(Icons.calendar_today, size: 16, color: chipColor),
                label: Text(i18n.nextDueOn(df.format(item.nextDueDate!))),
                side: BorderSide(color: chipColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
