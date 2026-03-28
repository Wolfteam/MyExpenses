part of 'income_expense_chart_bloc.dart';

@freezed
sealed class IncomeExpenseChartState with _$IncomeExpenseChartState {
  const factory IncomeExpenseChartState.loaded({
    required bool loaded,
    required List<TransactionActivityPerDate> points,
  }) = IncomeExpenseChartStateLoaded;
}
