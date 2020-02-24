part of 'transactions_bloc.dart';

@immutable
abstract class TransactionsEvent extends Equatable {
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
