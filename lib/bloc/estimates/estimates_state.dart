part of 'estimates_bloc.dart';

@freezed
abstract class EstimatesState implements _$EstimatesState {
  factory EstimatesState.loading() = EstimatesLoadingState;
  factory EstimatesState.loaded({
    @required int selectedTransactionType,
    @required DateTime fromDate,
    @required String fromDateString,
    @required DateTime untilDate,
    @required String untilDateString,
    @required AppLanguageType currentLanguage,
    @Default(0) double incomeAmount,
    @Default(0) double expenseAmount,
    @Default(0) double totalAmount,
  }) = EstimatesInitialState;
  const EstimatesState._();
}
