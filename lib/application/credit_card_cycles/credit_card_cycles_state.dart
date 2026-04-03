part of 'credit_card_cycles_bloc.dart';

@freezed
sealed class CreditCardCyclesState with _$CreditCardCyclesState {
  const factory CreditCardCyclesState.loading() = CreditCardCyclesStateLoading;
  const factory CreditCardCyclesState.loaded({
    required List<CreditCardCycleItem> items,
  }) = CreditCardCyclesStateLoaded;
}
