part of 'estimates_bloc.dart';

@freezed
abstract class EstimatesEvent implements _$EstimatesEvent {
  factory EstimatesEvent.load() = EstimatesLoadEvent;

  factory EstimatesEvent.transactionTypeChanged({@required int newValue}) = EstimatesTransactionTypeChangedEvent;

  factory EstimatesEvent.untilDateChanged({@required DateTime newDate}) = EstimatesUntilDateChangedEvent;

  factory EstimatesEvent.calculate() = EstimatesCalculateEvent;
  const EstimatesEvent._();
}
