part of 'transactions_summary_per_month_bloc.dart';

@freezed
class TransactionsSummaryPerMonthEvent with _$TransactionsSummaryPerMonthEvent {
  const factory TransactionsSummaryPerMonthEvent.init({
    required DateTime currentDate,
  }) = _Init;
}
