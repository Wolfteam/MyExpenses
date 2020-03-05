part of 'transactions_bloc.dart';

@immutable
abstract class TransactionsEvent extends Equatable {
  @override
  List<Object> get props => [];

  const TransactionsEvent();
}

class GetTransactions extends TransactionsEvent {
  final DateTime inThisDate;

  const GetTransactions({
    @required this.inThisDate,
  });

  @override
  List<Object> get props => [inThisDate];
}

class GetAllParentTransactions extends TransactionsEvent {
  const GetAllParentTransactions();
}
