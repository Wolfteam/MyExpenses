import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/entities/daos/payment_methods_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'payment_method_picker_bloc.freezed.dart';
part 'payment_method_picker_event.dart';
part 'payment_method_picker_state.dart';

class PaymentMethodPickerBloc extends Bloc<PaymentMethodPickerEvent, PaymentMethodPickerState> {
  final LoggingService _logger;
  final PaymentMethodsDao _dao;
  final UsersDao _usersDao;

  PaymentMethodPickerBloc(this._logger, this._dao, this._usersDao) : super(const PaymentMethodPickerState.loading()) {
    on<PaymentMethodPickerEventLoad>(_onLoad);
    on<PaymentMethodPickerEventSelect>((event, emit) {
      final items = switch (state) {
        final PaymentMethodPickerStateLoadedState s => s.items,
        _ => const <PaymentMethodItem>[],
      };
      emit(PaymentMethodPickerState.loaded(items: items, selectedId: event.id));
    });
    on<PaymentMethodPickerEventClear>((event, emit) {
      final items = switch (state) {
        final PaymentMethodPickerStateLoadedState s => s.items,
        _ => const <PaymentMethodItem>[],
      };
      emit(PaymentMethodPickerState.loaded(items: items));
    });
  }

  Future<void> _onLoad(PaymentMethodPickerEventLoad event, Emitter<PaymentMethodPickerState> emit) async {
    emit(const PaymentMethodPickerState.loading());
    try {
      final user = await _usersDao.getActiveUser();
      final items = await _dao.getAll(user?.id);
      emit(PaymentMethodPickerState.loaded(items: items, selectedId: event.initialSelectedId));
    } catch (e, s) {
      _logger.error(runtimeType, 'Load failed', e, s);
      emit(const PaymentMethodPickerState.loaded(items: [], errorOccurred: true));
      emit(const PaymentMethodPickerState.loaded(items: []));
    }
  }
}
