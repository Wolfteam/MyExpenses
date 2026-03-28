part of 'payment_method_chart_bloc.dart';

@freezed
sealed class PaymentMethodChartState with _$PaymentMethodChartState {
  const factory PaymentMethodChartState.loaded({
    required bool loaded,
    required List<PaymentMethodChartItem> methods,
  }) = PaymentMethodChartStateLoaded;
}
