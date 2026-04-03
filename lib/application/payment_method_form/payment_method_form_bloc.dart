import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';

part 'payment_method_form_bloc.freezed.dart';
part 'payment_method_form_event.dart';
part 'payment_method_form_state.dart';

class PaymentMethodFormBloc extends Bloc<PaymentMethodFormEvent, PaymentMethodFormState> {
  static const int maxNameLength = 50;
  static const int maxDayLength = 2;
  static const int maxCreditLimitLength = 15;

  PaymentMethodFormBloc() : super(const PaymentMethodFormState.initial()) {
    on<PaymentMethodFormEventInitialize>(_onInitialize);
    on<PaymentMethodFormEventNameChanged>(_onNameChanged);
    on<PaymentMethodFormEventTypeChanged>(_onTypeChanged);
    on<PaymentMethodFormEventStatementDayChanged>(_onStatementDayChanged);
    on<PaymentMethodFormEventDueDayChanged>(_onDueDayChanged);
    on<PaymentMethodFormEventCreditLimitChanged>(_onCreditLimitChanged);
    on<PaymentMethodFormEventSubmit>(_onSubmit);
    on<PaymentMethodFormEventIconChanged>(_onIconChanged);
    on<PaymentMethodFormEventIconColorChanged>(_onIconColorChanged);
  }

  void _onInitialize(
    PaymentMethodFormEventInitialize event,
    Emitter<PaymentMethodFormState> emit,
  ) {
    final e = event.existing;
    if (e == null) return;
    emit(
      PaymentMethodFormState.initial(
        name: e.name,
        type: e.type,
        statementDayText: e.statementCloseDay?.toString() ?? '',
        dueDayText: e.paymentDueDay?.toString() ?? '',
        creditLimitText: e.creditLimitMinor?.toString() ?? '',
        icon: e.icon,
        iconColor: e.iconColor,
      ),
    );
  }

  void _onNameChanged(
    PaymentMethodFormEventNameChanged event,
    Emitter<PaymentMethodFormState> emit,
  ) {
    final s = state as PaymentMethodFormStateInitial;
    emit(s.copyWith(name: event.value, isNameDirty: true, isNameValid: event.value.trim().isNotEmpty));
  }

  void _onTypeChanged(
    PaymentMethodFormEventTypeChanged event,
    Emitter<PaymentMethodFormState> emit,
  ) {
    final s = state as PaymentMethodFormStateInitial;
    emit(s.copyWith(type: event.value));
  }

  void _onStatementDayChanged(
    PaymentMethodFormEventStatementDayChanged event,
    Emitter<PaymentMethodFormState> emit,
  ) {
    final s = state as PaymentMethodFormStateInitial;
    emit(s.copyWith(
      statementDayText: event.value,
      isStatementDayDirty: true,
      isStatementDayValid: _isValidDay(event.value),
    ));
  }

  void _onDueDayChanged(
    PaymentMethodFormEventDueDayChanged event,
    Emitter<PaymentMethodFormState> emit,
  ) {
    final s = state as PaymentMethodFormStateInitial;
    emit(s.copyWith(
      dueDayText: event.value,
      isDueDayDirty: true,
      isDueDayValid: _isValidDay(event.value),
    ));
  }

  void _onCreditLimitChanged(
    PaymentMethodFormEventCreditLimitChanged event,
    Emitter<PaymentMethodFormState> emit,
  ) {
    final s = state as PaymentMethodFormStateInitial;
    final v = int.tryParse(event.value);
    emit(s.copyWith(
      creditLimitText: event.value,
      isCreditLimitDirty: true,
      isCreditLimitValid: v != null && v >= 0,
    ));
  }

  void _onSubmit(
    PaymentMethodFormEventSubmit event,
    Emitter<PaymentMethodFormState> emit,
  ) {
    final s = state as PaymentMethodFormStateInitial;
    final name = s.name.trim();
    final nameValid = name.isNotEmpty;
    final duplicate = event.existingItems.any(
      (e) =>
          e.name.toLowerCase() == name.toLowerCase() &&
          (event.editingId == null || e.id != event.editingId),
    );
    final isCreditCard = s.type == PaymentMethodType.creditCard;
    final statementValid = !isCreditCard || _isValidDay(s.statementDayText);
    final dueValid = !isCreditCard || _isValidDay(s.dueDayText);
    final limitValid = !isCreditCard || (int.tryParse(s.creditLimitText) ?? -1) >= 0;

    final updated = s.copyWith(
      isNameDirty: true,
      isStatementDayDirty: isCreditCard,
      isDueDayDirty: isCreditCard,
      isCreditLimitDirty: isCreditCard,
      isNameValid: nameValid && !duplicate,
      isDuplicate: duplicate,
      isStatementDayValid: statementValid,
      isDueDayValid: dueValid,
      isCreditLimitValid: limitValid,
    );

    if (!nameValid || duplicate || !statementValid || !dueValid || !limitValid) {
      emit(updated);
      return;
    }

    emit(updated.copyWith(submitted: true));
  }

  bool _isValidDay(String value) {
    final v = int.tryParse(value);
    return v != null && v >= 1 && v <= 31;
  }

  void _onIconChanged(
    PaymentMethodFormEventIconChanged event,
    Emitter<PaymentMethodFormState> emit,
  ) {
    final s = state as PaymentMethodFormStateInitial;
    emit(s.copyWith(icon: event.icon));
  }

  void _onIconColorChanged(
    PaymentMethodFormEventIconColorChanged event,
    Emitter<PaymentMethodFormState> emit,
  ) {
    final s = state as PaymentMethodFormStateInitial;
    emit(s.copyWith(iconColor: event.iconColor));
  }
}
