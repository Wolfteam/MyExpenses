part of 'transaction_form_bloc.dart';

@immutable
abstract class TransactionFormState extends Equatable {}

class TransactionInitialState extends TransactionFormState {
  @override
  List<Object> get props => [];
}

class TransactionFormLoadedState extends TransactionFormState {
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

  bool get isFormValid =>
      isAmountValid &&
      isDescriptionValid &&
      // isTransactionDateValid &&
      isRepetitionsValid &&
      isCategoryValid;

  TransactionFormLoadedState({
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
  });

  factory TransactionFormLoadedState.initial() {
    final cat = CategoryUtils.getByName(CategoryUtils.question);
    final category =
        CategoryItem(0, false, cat.name, cat.icon.icon, Colors.blue);

    return TransactionFormLoadedState(
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
      isCategoryValid: true,
    );
  }

  TransactionFormLoadedState copyWith({
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
  }) {
    return TransactionFormLoadedState(
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
    );
  }

  @override
  List<Object> get props => [
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
      ];
}
