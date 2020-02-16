part of 'transaction_form_bloc.dart';

@immutable
abstract class TransactionFormState extends Equatable {
  const TransactionFormState();
}

class TransactionInitialState extends TransactionFormState {
  @override
  List<Object> get props => [];
}

class TransactionFormLoadedState extends TransactionFormState {
  final int id;

  final double amount;
  final bool isAmountValid;
  final bool isAmountDirty;

  final String description;
  final bool isDescriptionValid;
  final bool isDescriptionDirty;

  final DateTime transactionDate;
  final bool isTransactionDateValid;

  final int repetitions;
  final bool isRepetitionsValid;
  final bool isRepetitionsDirty;

  final RepetitionCycleType repetitionCycle;
  final bool areRepetitionCyclesVisible;

  final CategoryItem category;
  final bool isCategoryValid;

  final String error;

  bool get isFormValid =>
      isAmountValid &&
      isDescriptionValid &&
      // isTransactionDateValid &&
      isRepetitionsValid &&
      isCategoryValid;

  const TransactionFormLoadedState({
    @required this.id,
    @required this.amount,
    @required this.isAmountValid,
    @required this.isAmountDirty,
    @required this.description,
    @required this.isDescriptionValid,
    @required this.isDescriptionDirty,
    @required this.transactionDate,
    @required this.isTransactionDateValid,
    @required this.repetitions,
    @required this.isRepetitionsValid,
    @required this.isRepetitionsDirty,
    @required this.repetitionCycle,
    @required this.areRepetitionCyclesVisible,
    @required this.category,
    @required this.isCategoryValid,
    this.error,
  });

  factory TransactionFormLoadedState.initial() {
    final cat = CategoryUtils.getByName(CategoryUtils.question);
    final category = CategoryItem(
      id: 0,
      isAnIncome: false,
      name: cat.name,
      icon: cat.icon.icon,
      iconColor: Colors.blue,
    );

    return TransactionFormLoadedState(
      id: 0,
      amount: 0,
      isAmountValid: false,
      isAmountDirty: false,
      description: '',
      isDescriptionValid: false,
      isDescriptionDirty: false,
      transactionDate: DateTime.now(),
      isTransactionDateValid: true,
      repetitions: 0,
      isRepetitionsValid: true,
      isRepetitionsDirty: false,
      repetitionCycle: RepetitionCycleType.none,
      areRepetitionCyclesVisible: false,
      category: category,
      isCategoryValid: false,
      error: null,
    );
  }

  TransactionFormLoadedState copyWith({
    int id,
    double amount,
    bool isAmountValid,
    bool isAmountDirty,
    String description,
    bool isDescriptionValid,
    bool isDescriptionDirty,
    DateTime transactionDate,
    bool isTransactionDateValid,
    int repetitions,
    bool isRepetitionsValid,
    bool isRepetitionsDirty,
    RepetitionCycleType repetitionCycle,
    bool areRepetitionCyclesVisible,
    CategoryItem category,
    bool isCategoryValid,
    String error,
  }) {
    return TransactionFormLoadedState(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      isAmountValid: isAmountValid ?? this.isAmountValid,
      isAmountDirty: isAmountDirty ?? this.isAmountDirty,
      description: description ?? this.description,
      isDescriptionValid: isDescriptionValid ?? this.isDescriptionValid,
      isDescriptionDirty: isDescriptionDirty ?? this.isDescriptionDirty,
      transactionDate: transactionDate ?? this.transactionDate,
      isTransactionDateValid:
          isTransactionDateValid ?? this.isTransactionDateValid,
      repetitions: repetitions ?? this.repetitions,
      isRepetitionsValid: isRepetitionsValid ?? this.isRepetitionsValid,
      isRepetitionsDirty: isRepetitionsDirty ?? this.isRepetitionsDirty,
      repetitionCycle: repetitionCycle ?? this.repetitionCycle,
      areRepetitionCyclesVisible:
          areRepetitionCyclesVisible ?? this.areRepetitionCyclesVisible,
      category: category ?? this.category,
      isCategoryValid: isCategoryValid ?? this.isCategoryValid,
      error: error ?? this.error,
    );
  }

  TransactionItem buildTransactionItem() {
    return TransactionItem(
      id: id,
      amount: amount,
      category: category,
      description: description,
      repetitionCycleType: repetitionCycle,
      repetitions: repetitions,
      transactionDate: transactionDate,
    );
  }

  @override
  List<Object> get props => [
        id,
        amount,
        isAmountValid,
        isAmountDirty,
        description,
        isDescriptionValid,
        isDescriptionDirty,
        transactionDate,
        isTransactionDateValid,
        repetitions,
        isRepetitionsValid,
        isRepetitionsDirty,
        repetitionCycle,
        category,
        isCategoryValid,
        error,
      ];
}

class TransactionSavedState extends TransactionFormState {
  final TransactionItem transaction;

  const TransactionSavedState(this.transaction);

  @override
  List<Object> get props => [transaction];
}
