part of 'transactions_bloc.dart';

@immutable
abstract class TransactionsEvent {}

class GetTransactions extends TransactionsEvent {
  final DateTime inThisDate;

  GetTransactions({
    @required this.inThisDate,
  });
}