part of 'transactions_summary_per_month_bloc.dart';

@freezed
sealed class TransactionsSummaryPerMonthEvent with _$TransactionsSummaryPerMonthEvent {
  const factory TransactionsSummaryPerMonthEvent.init({required DateTime currentDate}) = TransactionsSummaryPerMonthEventInit;
}
