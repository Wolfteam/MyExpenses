part of 'income_expense_chart_bloc.dart';

@freezed
sealed class IncomeExpenseChartEvent with _$IncomeExpenseChartEvent {
  const factory IncomeExpenseChartEvent.load({
    required DateTime from,
    required DateTime to,
  }) = IncomeExpenseChartEventLoad;
}
