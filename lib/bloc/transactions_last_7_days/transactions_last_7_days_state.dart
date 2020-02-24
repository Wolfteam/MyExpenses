part of 'transactions_last_7_days_bloc.dart';

@immutable
abstract class TransactionsLast7DaysState extends Equatable {
  const TransactionsLast7DaysState();

  @override
  List<Object> get props => [];
}

class TransactionsLast7DaysInitialState extends TransactionsLast7DaysState {
  const TransactionsLast7DaysInitialState();
}

class Last7DaysTransactionTypeChangedState extends TransactionsLast7DaysState {
  final TransactionType selectedType;

  const Last7DaysTransactionTypeChangedState({@required this.selectedType});

  @override
  List<Object> get props => [selectedType];
}
