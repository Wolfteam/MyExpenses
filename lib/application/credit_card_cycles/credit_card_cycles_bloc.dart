import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/payment_methods_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'credit_card_cycles_bloc.freezed.dart';
part 'credit_card_cycles_event.dart';
part 'credit_card_cycles_state.dart';

class CreditCardCyclesBloc extends Bloc<CreditCardCyclesEvent, CreditCardCyclesState> {
  final LoggingService _logger;
  final PaymentMethodsDao _dao;
  final UsersDao _usersDao;

  CreditCardCyclesBloc(this._logger, this._dao, this._usersDao)
      : super(const CreditCardCyclesState.loading()) {
    on<CreditCardCyclesEventLoad>(_onLoad);
  }

  Future<void> _onLoad(
    CreditCardCyclesEventLoad event,
    Emitter<CreditCardCyclesState> emit,
  ) async {
    emit(const CreditCardCyclesState.loading());
    try {
      final user = await _usersDao.getActiveUser();
      final all = await _dao.getAll(user?.id);
      final cards = all
          .where((e) => e.type == PaymentMethodType.creditCard && !e.isArchived)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      final today = DateTime.now();
      final items = cards.map((m) {
        final cycle = _computeCurrentCycle(today, m.statementCloseDay);
        final nextDue = _computeDueForClose(cycle.nextClose, m.paymentDueDay);
        return CreditCardCycleItem(
          paymentMethod: m,
          cycleStart: cycle.start,
          cycleNextClose: cycle.nextClose,
          nextDueDate: nextDue,
        );
      }).toList();

      emit(CreditCardCyclesState.loaded(items: items));
    } catch (e, s) {
      _logger.error(runtimeType, 'Load failed', e, s);
      emit(const CreditCardCyclesState.loaded(items: []));
    }
  }

  ({DateTime start, DateTime lastClose, DateTime nextClose}) _computeCurrentCycle(
    DateTime today,
    int? closeDay,
  ) {
    final cd = (closeDay == null || closeDay < 1 || closeDay > 31) ? 31 : closeDay;
    final monthDays = _daysInMonth(today.year, today.month);
    final effectiveCloseDay = cd > monthDays ? monthDays : cd;
    final tentativeClose = DateTime(today.year, today.month, effectiveCloseDay);

    DateTime lastClose;
    if (_isSameOrBefore(tentativeClose, today)) {
      lastClose = tentativeClose;
    } else {
      final prev = _addMonths(DateTime(today.year, today.month), -1);
      final dpm = _daysInMonth(prev.year, prev.month);
      lastClose = DateTime(prev.year, prev.month, cd > dpm ? dpm : cd);
    }

    final nextMonth = _addMonths(DateTime(lastClose.year, lastClose.month), 1);
    final dnm = _daysInMonth(nextMonth.year, nextMonth.month);
    final nextClose = DateTime(nextMonth.year, nextMonth.month, cd > dnm ? dnm : cd);
    return (start: lastClose.add(const Duration(days: 1)), lastClose: lastClose, nextClose: nextClose);
  }

  DateTime? _computeDueForClose(DateTime closeDate, int? dueDay) {
    if (dueDay == null || dueDay < 1 || dueDay > 31) return null;
    final dueMonth = _addMonths(DateTime(closeDate.year, closeDate.month), 1);
    final dim = _daysInMonth(dueMonth.year, dueMonth.month);
    return DateTime(dueMonth.year, dueMonth.month, dueDay > dim ? dim : dueDay);
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  DateTime _addMonths(DateTime date, int months) =>
      DateTime(date.year, date.month + months, date.day);

  bool _isSameOrBefore(DateTime a, DateTime b) {
    final aa = DateTime(a.year, a.month, a.day);
    final bb = DateTime(b.year, b.month, b.day);
    return aa.isAtSameMomentAs(bb) || aa.isBefore(bb);
  }
}
