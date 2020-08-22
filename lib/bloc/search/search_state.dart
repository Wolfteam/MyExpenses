part of 'search_bloc.dart';

@freezed
abstract class SearchState implements _$SearchState {
  factory SearchState.loading() = SearchLoadingState;
  factory SearchState.initial({
    @required AppLanguageType currentLanguage,
    @required List<TransactionItem> transactions,
    @required int page,
    @required bool hasReachedMax,
    DateTime from,
    DateTime until,
    DateTime tempFrom,
    DateTime tempUntil,
    String fromString,
    String untilString,
    String description,
    double amount,
    double tempAmount,
    ComparerType comparerType,
    ComparerType tempComparerType,
    CategoryItem category,
    TransactionType transactionType,
    TransactionFilterType transactionFilterType,
    SortDirectionType sortDirectionType,
  }) = SearchInitialState;
}
