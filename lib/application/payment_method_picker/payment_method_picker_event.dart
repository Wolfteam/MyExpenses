part of 'payment_method_picker_bloc.dart';

@freezed
sealed class PaymentMethodPickerEvent with _$PaymentMethodPickerEvent {
  const factory PaymentMethodPickerEvent.load({int? initialSelectedId}) = PaymentMethodPickerEventLoad;
  const factory PaymentMethodPickerEvent.select({required int? id}) = PaymentMethodPickerEventSelect;
  const factory PaymentMethodPickerEvent.clear() = PaymentMethodPickerEventClear;
}
