part of 'payment_methods_bloc.dart';

@freezed
sealed class PaymentMethodsState with _$PaymentMethodsState {
  const factory PaymentMethodsState.loading({@Default(false) bool includeArchived}) = PaymentMethodsStateLoadingState;

  const factory PaymentMethodsState.loaded({
    required List<PaymentMethodItem> items,
    @Default(false) bool includeArchived,
    @Default(false) bool errorOccurred,
  }) = PaymentMethodsStateLoadedState;
}
