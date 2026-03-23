part of 'credit_card_cycles_bloc.dart';

@freezed
sealed class CreditCardCyclesEvent with _$CreditCardCyclesEvent {
  const factory CreditCardCyclesEvent.load() = CreditCardCyclesEventLoad;
}
