part of 'transaction_form_bloc.dart';

@immutable
abstract class TransactionFormEvent extends Equatable {
  const TransactionFormEvent();

  @override
  List<Object> get props => [];
}

class AddTransaction extends TransactionFormEvent {}

class EditTransaction extends TransactionFormEvent {
  final TransactionItem item;

  const EditTransaction(this.item);

  @override
  List<Object> get props => [item];
}

class AmountChanged extends TransactionFormEvent {
  final double amount;
  const AmountChanged(this.amount);

  @override
  List<Object> get props => [amount];
}

class DescriptionChanged extends TransactionFormEvent {
  final String description;
  const DescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

class TransactionDateChanged extends TransactionFormEvent {
  final DateTime transactionDate;
  const TransactionDateChanged(this.transactionDate);

  @override
  List<Object> get props => [transactionDate];
}

class RepetitionCycleChanged extends TransactionFormEvent {
  final RepetitionCycleType repetitionCycle;

  const RepetitionCycleChanged(this.repetitionCycle);

  @override
  List<Object> get props => [repetitionCycle];
}

class CategoryWasUpdated extends TransactionFormEvent {
  final CategoryItem category;

  const CategoryWasUpdated(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteTransaction extends TransactionFormEvent {

}

class FormSubmitted extends TransactionFormEvent {}

class FormClosed extends TransactionFormEvent {}
