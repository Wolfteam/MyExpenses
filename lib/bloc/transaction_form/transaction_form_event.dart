part of 'transaction_form_bloc.dart';

@immutable
abstract class TransactionFormEvent extends Equatable {
  const TransactionFormEvent();

  @override
  List<Object> get props => [];
}

class AddTransaction extends TransactionFormEvent {}

class EditTransaction extends TransactionFormEvent {
  final int id;

  const EditTransaction(this.id);

  @override
  List<Object> get props => [id];
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

class ImageChanged extends TransactionFormEvent {
  final String path;
  final bool imageExists;

  const ImageChanged({
    @required this.path,
    @required this.imageExists,
  });

  @override
  List<Object> get props => [path, imageExists];
}

class IsRunningChanged extends TransactionFormEvent {
  final bool isRunning;

  const IsRunningChanged({@required this.isRunning});

  @override
  List<Object> get props => [isRunning];
}

class DeleteTransaction extends TransactionFormEvent {
  final bool keepChilds;

  const DeleteTransaction({this.keepChilds = false});
}

class FormSubmitted extends TransactionFormEvent {}

class FormClosed extends TransactionFormEvent {}
