part of 'payment_method_form_bloc.dart';

@freezed
sealed class PaymentMethodFormEvent with _$PaymentMethodFormEvent {
  const factory PaymentMethodFormEvent.initialize({
    PaymentMethodItem? existing,
  }) = PaymentMethodFormEventInitialize;

  const factory PaymentMethodFormEvent.nameChanged({required String value}) =
      PaymentMethodFormEventNameChanged;

  const factory PaymentMethodFormEvent.typeChanged({required PaymentMethodType value}) =
      PaymentMethodFormEventTypeChanged;

  const factory PaymentMethodFormEvent.statementDayChanged({required String value}) =
      PaymentMethodFormEventStatementDayChanged;

  const factory PaymentMethodFormEvent.dueDayChanged({required String value}) =
      PaymentMethodFormEventDueDayChanged;

  const factory PaymentMethodFormEvent.creditLimitChanged({required String value}) =
      PaymentMethodFormEventCreditLimitChanged;

  const factory PaymentMethodFormEvent.submit({
    required List<PaymentMethodItem> existingItems,
    int? editingId,
  }) = PaymentMethodFormEventSubmit;

  const factory PaymentMethodFormEvent.iconChanged({required IconData icon}) =
      PaymentMethodFormEventIconChanged;

  const factory PaymentMethodFormEvent.iconColorChanged({required Color iconColor}) =
      PaymentMethodFormEventIconColorChanged;
}
