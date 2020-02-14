part of 'transactions_last_7_days_bloc.dart';

@immutable
abstract class TransactionsLast7DaysState {
  const TransactionsLast7DaysState();
}

class TransactionsLast7DaysInitialState extends TransactionsLast7DaysState {
  const TransactionsLast7DaysInitialState();
}

class Last7DaysTransactionTypeChangedState extends TransactionsLast7DaysState {
  final TransactionType selectedType;

  const Last7DaysTransactionTypeChangedState({@required this.selectedType});
}
