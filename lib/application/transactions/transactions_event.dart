part of 'transactions_bloc.dart';

@freezed
class TransactionsEvent with _$TransactionsEvent {
  const factory TransactionsEvent.init({
    required DateTime currentDate,
  }) = _Init;
}
