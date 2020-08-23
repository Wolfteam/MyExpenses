part of 'transactions_bloc.dart';

@freezed
abstract class TransactionsState implements _$TransactionsState {
  factory TransactionsState.initial() = TransactionsInitialState;
  factory TransactionsState.loaded({
    @required DateTime currentDate,
    @required List<TransactionCardItems> transactionsPerMonth,
    @required AppLanguageType language,
    @Default(false) bool showParentTransactions,
  }) = TransactionsLoadedState;
}

// class TransactionsInitialState extends TransactionsState {}

// class TransactionsLoadedState extends TransactionsState {
//   final DateTime currentDate;
//   final List<TransactionCardItems> transactionsPerMonth;
//   final bool showParentTransactions;
//   final AppLanguageType language;

//   @override
//   List<Object> get props => [
//         currentDate,
//         transactionsPerMonth,
//         showParentTransactions,
//         language,
//       ];

//   const TransactionsLoadedState({
//     @required this.currentDate,
//     @required this.transactionsPerMonth,
//     @required this.language,
//     this.showParentTransactions = false,
//   });

//   TransactionsLoadedState copyWith({
//     List<TransactionCardItems> transactionsPerMonth,
//     bool showParentTransactions,
//   }) {
//     return TransactionsLoadedState(
//       currentDate: currentDate,
//       transactionsPerMonth: transactionsPerMonth ?? this.transactionsPerMonth,
//       showParentTransactions: showParentTransactions ?? this.showParentTransactions,
//       language: language,
//     );
//   }
// }
