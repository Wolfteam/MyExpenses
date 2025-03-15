part of 'search_bloc.dart';

@freezed
sealed class SearchState with _$SearchState {
  const factory SearchState.loading() = SearchStateLoadingState;

  const factory SearchState.initial({
    required AppLanguageType currentLanguage,
    required List<TransactionItem> transactions,
    required int page,
    required bool hasReachedMax,
    DateTime? from,
    DateTime? until,
    DateTime? tempFrom,
    DateTime? tempUntil,
    String? fromString,
    String? untilString,
    String? description,
    double? amount,
    double? tempAmount,
    required ComparerType comparerType,
    required ComparerType tempComparerType,
    CategoryItem? category,
    TransactionType? transactionType,
    required TransactionFilterType transactionFilterType,
    required SortDirectionType sortDirectionType,
  }) = SearchStateInitialState;
}
