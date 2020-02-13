part of 'transaction_form_bloc.dart';

@immutable
abstract class TransactionFormState {}

class TransactionFormInitial extends TransactionFormState {
  final double amount;
  final bool isAmountValid;

  final String description;
  final bool isDescriptionValid;

  final DateTime transactionDate;
  final bool isTransactionDateValid;

  final int repetitions;
  final bool isRepetitionsValid;

  final CategoryItem category;
  final bool isCategoryValid;

  bool get isFormValid =>
      isAmountValid &&
      isDescriptionValid &&
      // isTransactionDateValid &&
      isRepetitionsValid &&
      isCategoryValid;

  TransactionFormInitial(
      {@required this.amount,
      @required this.isAmountValid,
      @required this.description,
      @required this.isDescriptionValid,
      @required this.transactionDate,
      @required this.isTransactionDateValid,
      @required this.repetitions,
      @required this.isRepetitionsValid,
      @required this.category,
      @required this.isCategoryValid});

  factory TransactionFormInitial.initial() {
    return TransactionFormInitial(
      amount: 0,
      isAmountValid: false,
      description: '',
      isDescriptionValid: false,
      transactionDate: DateTime.now(),
      isTransactionDateValid: true,
      repetitions: 0,
      isRepetitionsValid: true,
      category: null,
      isCategoryValid: false,
    );
  }

  TransactionFormInitial copyWith({
    double amount,
    bool isAmountValid,
    String description,
    bool isDescriptionValid,
    DateTime transactionDate,
    bool isTransactionDateValid,
    int repetitions,
    bool isRepetitionsValid,
    CategoryItem category,
    bool isCategoryValid,
  }) {
    return TransactionFormInitial(
      amount: amount ?? this.amount,
      isAmountValid: isAmountValid ?? this.isAmountValid,
      description: description ?? this.description,
      isDescriptionValid: isDescriptionValid ?? this.isDescriptionValid,
      transactionDate: transactionDate ?? this.transactionDate,
      isTransactionDateValid:
          isTransactionDateValid ?? this.isTransactionDateValid,
      repetitions: repetitions ?? this.repetitions,
      isRepetitionsValid: isRepetitionsValid ?? this.isRepetitionsValid,
      category: category ?? this.category,
      isCategoryValid: isCategoryValid ?? this.isCategoryValid,
    );
  }
}
