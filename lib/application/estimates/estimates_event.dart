part of 'estimates_bloc.dart';

@freezed
sealed class EstimatesEvent with _$EstimatesEvent {
  const factory EstimatesEvent.load() = EstimatesEventEstimatesLoadEvent;

  const factory EstimatesEvent.transactionTypeChanged({required int newValue}) =
      EstimatesEventEstimatesTransactionTypeChangedEvent;

  const factory EstimatesEvent.fromDateChanged({required DateTime newDate}) = EstimatesEventEstimatesFromDateChangedEvent;

  const factory EstimatesEvent.untilDateChanged({required DateTime newDate}) = EstimatesEventEstimatesUntilDateChangedEvent;

  const factory EstimatesEvent.calculate() = EstimatesEventEstimatesCalculateEvent;
}
