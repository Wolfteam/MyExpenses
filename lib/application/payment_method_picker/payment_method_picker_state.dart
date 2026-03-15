

part of 'payment_method_picker_bloc.dart';

@freezed
sealed class PaymentMethodPickerState with _$PaymentMethodPickerState {
  const factory PaymentMethodPickerState.loading() = PaymentMethodPickerStateLoadingState;

  const factory PaymentMethodPickerState.loaded({
    required List<PaymentMethodItem> items,
    int? selectedId,
    @Default(false) bool errorOccurred,
  }) = PaymentMethodPickerStateLoadedState;
}
