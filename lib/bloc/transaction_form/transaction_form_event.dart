part of 'transaction_form_bloc.dart';

@immutable
abstract class TransactionFormEvent {
  const TransactionFormEvent();
}

class AmountChanged extends TransactionFormEvent {
  final double amount;
  const AmountChanged(this.amount);
}

class DescriptionChanged extends TransactionFormEvent {
  final String description;
  const DescriptionChanged(this.description);
}

// class TransactionDateChanged extends TransactionFormEvent {
//   final DateTime transactionDate;
//   const TransactionDateChanged(this.transactionDate);
// }

class RepetitionsChanged extends TransactionFormEvent {
  final int repetitions;
  const RepetitionsChanged(this.repetitions);
}
