part of 'currency_bloc.dart';

@freezed
sealed class CurrencyState with _$CurrencyState {
  const factory CurrencyState.initial() = CurrencyStateInitial;
}
