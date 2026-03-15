import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/entities/daos/payment_methods_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'payment_methods_bloc.freezed.dart';
part 'payment_methods_event.dart';
part 'payment_methods_state.dart';

class PaymentMethodsBloc extends Bloc<PaymentMethodsEvent, PaymentMethodsState> {
  final LoggingService _logger;
  final PaymentMethodsDao _dao;
  final UsersDao _usersDao;

  PaymentMethodsBloc(this._logger, this._dao, this._usersDao) : super(const PaymentMethodsState.loading()) {
    on<PaymentMethodsEventLoad>(_onLoad);
    on<PaymentMethodsEventCreateOrUpdate>(_onCreateOrUpdate);
    on<PaymentMethodsEventArchive>(_onArchive);
    on<PaymentMethodsEventReorder>(_onReorder);
  }

  Future<int?> _getActiveUserId() async {
    final user = await _usersDao.getActiveUser();
    return user?.id;
  }

  Future<void> _refresh(Emitter<PaymentMethodsState> emit, {bool? includeArchived}) async {
    final userId = await _getActiveUserId();
    final include =
        includeArchived ??
        switch (state) {
          final PaymentMethodsStateLoadingState loading => loading.includeArchived,
          final PaymentMethodsStateLoadedState loaded => loaded.includeArchived,
        };

    if (userId == null) {
      emit(PaymentMethodsState.loaded(items: const [], includeArchived: include));
      return;
    }
    final items = await _dao.getAll(userId, includeArchived: include);
    emit(PaymentMethodsState.loaded(items: items, includeArchived: include));
  }

  Future<void> _onLoad(PaymentMethodsEventLoad event, Emitter<PaymentMethodsState> emit) async {
    emit(PaymentMethodsState.loading(includeArchived: event.includeArchived));
    try {
      await _refresh(emit, includeArchived: event.includeArchived);
    } catch (e, s) {
      _logger.error(runtimeType, 'Load failed', e, s);
      emit(const PaymentMethodsState.loaded(items: [], errorOccurred: true));
      emit(const PaymentMethodsState.loaded(items: []));
    }
  }

  Future<void> _onCreateOrUpdate(
    PaymentMethodsEventCreateOrUpdate event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    try {
      final userId = await _getActiveUserId();
      if (userId == null) return;
      await _dao.save(userId, event.method);
      await _refresh(emit);
    } catch (e, s) {
      _logger.error(runtimeType, 'Save failed', e, s);
      // pulse error flag
      final include = state.maybeWhen(loaded: (_, inc, __) => inc, orElse: () => false);
      emit(
        PaymentMethodsState.loaded(
          items: state.maybeWhen(loaded: (it, _, __) => it, orElse: () => const []),
          includeArchived: include,
          errorOccurred: true,
        ),
      );
      emit(
        PaymentMethodsState.loaded(
          items: state.maybeWhen(loaded: (it, _, _) => it, orElse: () => const []),
          includeArchived: include,
        ),
      );
    }
  }

  Future<void> _onArchive(PaymentMethodsEventArchive event, Emitter<PaymentMethodsState> emit) async {
    try {
      await _dao.archive(event.id, isArchived: event.isArchived);
      await _refresh(emit);
    } catch (e, s) {
      _logger.error(runtimeType, 'Archive failed', e, s);
      final include = state.maybeWhen(loaded: (_, inc, __) => inc, orElse: () => false);
      emit(
        PaymentMethodsState.loaded(
          items: state.maybeWhen(loaded: (it, _, __) => it, orElse: () => const []),
          includeArchived: include,
          errorOccurred: true,
        ),
      );
      emit(
        PaymentMethodsState.loaded(
          items: state.maybeWhen(loaded: (it, _, __) => it, orElse: () => const []),
          includeArchived: include,
        ),
      );
    }
  }

  Future<void> _onReorder(PaymentMethodsEventReorder event, Emitter<PaymentMethodsState> emit) async {
    try {
      final userId = await _getActiveUserId();
      if (userId == null) return;
      await _dao.updateSortOrders(userId, event.orderedIds);
      await _refresh(emit);
    } catch (e, s) {
      _logger.error(runtimeType, 'Reorder failed', e, s);
      final include = state.maybeWhen(loaded: (_, inc, __) => inc, orElse: () => false);
      emit(
        PaymentMethodsState.loaded(
          items: state.maybeWhen(loaded: (it, _, __) => it, orElse: () => const []),
          includeArchived: include,
          errorOccurred: true,
        ),
      );
      emit(
        PaymentMethodsState.loaded(
          items: state.maybeWhen(loaded: (it, _, __) => it, orElse: () => const []),
          includeArchived: include,
        ),
      );
    }
  }
}
