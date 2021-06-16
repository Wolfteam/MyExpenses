part of 'estimates_bloc.dart';

@freezed
class EstimatesEvent with _$EstimatesEvent {
  const EstimatesEvent._();

  factory EstimatesEvent.load() = _EstimatesLoadEvent;

  factory EstimatesEvent.transactionTypeChanged({required int newValue}) = _EstimatesTransactionTypeChangedEvent;

  factory EstimatesEvent.fromDateChanged({required DateTime newDate}) = _EstimatesFromDateChangedEvent;

  factory EstimatesEvent.untilDateChanged({required DateTime newDate}) = _EstimatesUntilDateChangedEvent;

  factory EstimatesEvent.calculate() = _EstimatesCalculateEvent;
}
