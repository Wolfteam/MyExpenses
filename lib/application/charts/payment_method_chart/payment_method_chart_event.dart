part of 'payment_method_chart_bloc.dart';

@freezed
sealed class PaymentMethodChartEvent with _$PaymentMethodChartEvent {
  const factory PaymentMethodChartEvent.load({
    required DateTime from,
    required DateTime to,
  }) = PaymentMethodChartEventLoad;
}
