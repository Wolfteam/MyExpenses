part of 'transactions_last_7_days_bloc.dart';

@immutable
abstract class TransactionsLast7DaysEvent {}

class Last7DaysTransactionTypeChanged extends TransactionsLast7DaysEvent {
  final TransactionType selectedType;

  Last7DaysTransactionTypeChanged({
    @required this.selectedType,
  });
}
