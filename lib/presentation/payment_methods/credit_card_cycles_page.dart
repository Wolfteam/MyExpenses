import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/application/payment_methods/payment_methods_bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';

class CreditCardCyclesPage extends StatelessWidget {
  const CreditCardCyclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocProvider(
      create: (_) => Injection.paymentMethodsBloc..add(const PaymentMethodsEvent.load()),
      child: Scaffold(
        appBar: AppBar(title: Text(i18n.creditCardCycles)),
        body: BlocBuilder<PaymentMethodsBloc, PaymentMethodsState>(
          builder: (context, state) {
            switch (state) {
              case final PaymentMethodsStateLoadedState s:
                final cards = s.items.where((e) => e.type == PaymentMethodType.creditCard && !e.isArchived).toList()
                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                if (cards.isEmpty) {
                  return Center(child: Text(i18n.noPaymentMethodsYet));
                }

                return ListView.separated(
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final m = cards[index];
                    final today = DateTime.now();
                    final cycle = _computeCurrentCycle(today, m.statementCloseDay);
                    final nextDue = _computeDueForClose(cycle.nextClose, m.paymentDueDay);
                    final df = DateFormat.yMMMd();

                    return ListTile(
                      leading: Icon(m.icon, color: m.iconColor),
                      title: Text(m.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (m.statementCloseDay != null || m.paymentDueDay != null)
                            Text(
                              '${i18n.statementCloseDay}: ${m.statementCloseDay ?? i18n.na}  •  ${i18n.paymentDueDay}: ${m.paymentDueDay ?? i18n.na}',
                            ),
                          const SizedBox(height: 4),
                          Text('${i18n.currentCycle}: ${df.format(cycle.start)} — ${df.format(cycle.nextClose)}'),
                          if (nextDue != null) Text(i18n.nextDueOn(df.format(nextDue))),
                        ],
                      ),
                    );
                  },
                );
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  ({DateTime start, DateTime lastClose, DateTime nextClose}) _computeCurrentCycle(DateTime today, int? closeDay) {
    final cd = (closeDay == null || closeDay < 1 || closeDay > 31) ? 31 : closeDay;
    final monthDays = _daysInMonth(today.year, today.month);
    final effectiveCloseDay = cd > monthDays ? monthDays : cd;
    final tentativeClose = DateTime(today.year, today.month, effectiveCloseDay);

    DateTime lastClose;
    if (_isSameOrBefore(tentativeClose, today)) {
      lastClose = tentativeClose;
    } else {
      // previous month close
      final prev = _addMonths(DateTime(today.year, today.month, 1), -1);
      final dpm = _daysInMonth(prev.year, prev.month);
      final prevClose = DateTime(prev.year, prev.month, cd > dpm ? dpm : cd);
      lastClose = prevClose;
    }

    final nextMonth = _addMonths(DateTime(lastClose.year, lastClose.month, 1), 1);
    final dnm = _daysInMonth(nextMonth.year, nextMonth.month);
    final nextClose = DateTime(nextMonth.year, nextMonth.month, cd > dnm ? dnm : cd);
    final start = lastClose.add(const Duration(days: 1));
    return (start: start, lastClose: lastClose, nextClose: nextClose);
  }

  DateTime? _computeDueForClose(DateTime closeDate, int? dueDay) {
    if (dueDay == null || dueDay < 1 || dueDay > 31) return null;
    // Due day is in the month AFTER the close date's month
    final dueMonth = _addMonths(DateTime(closeDate.year, closeDate.month, 1), 1);
    final dim = _daysInMonth(dueMonth.year, dueMonth.month);
    final day = dueDay > dim ? dim : dueDay;
    return DateTime(dueMonth.year, dueMonth.month, day);
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  DateTime _addMonths(DateTime date, int months) => DateTime(date.year, date.month + months, date.day);

  bool _isSameOrBefore(DateTime a, DateTime b) {
    final aa = DateTime(a.year, a.month, a.day);
    final bb = DateTime(b.year, b.month, b.day);
    return aa.isAtSameMomentAs(bb) || aa.isBefore(bb);
  }
}
