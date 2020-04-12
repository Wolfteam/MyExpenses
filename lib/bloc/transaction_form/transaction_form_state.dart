part of 'transaction_form_bloc.dart';

@immutable
abstract class TransactionFormState extends Equatable {
  const TransactionFormState();

  @override
  List<Object> get props => [];
}

class TransactionInitialState extends TransactionFormState {}

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
  final String transactionDateString;
  final DateTime firstDate;
  final DateTime lastDate;

  final RepetitionCycleType repetitionCycle;

  final CategoryItem category;
  final bool isCategoryValid;

  final AppLanguageType language;

  final bool errorOccurred;

  final int parentTransactionId;
  final bool isParentTransaction;

  final String imagePath;
  final bool imageExists;

  final bool isSavingForm;

  final bool isRecurringTransactionRunning;
  final DateTime nextRecurringDate;
  final bool nextRecurringDateWasUpdated;

  bool get isNewTransaction => id == null || id <= 0;

  bool get isChildTransaction =>
      !isParentTransaction && parentTransactionId != null;

  bool get isFormValid =>
      isAmountValid &&
      isDescriptionValid &&
      isTransactionDateValid &&
      isCategoryValid;

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
        transactionDateString,
        firstDate,
        lastDate,
        repetitionCycle,
        category,
        isCategoryValid,
        language,
        errorOccurred,
        parentTransactionId,
        isParentTransaction,
        imagePath,
        imageExists,
        isSavingForm,
        isRecurringTransactionRunning,
        nextRecurringDate,
        nextRecurringDateWasUpdated,
      ];

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
    @required this.transactionDateString,
    @required this.firstDate,
    @required this.lastDate,
    @required this.repetitionCycle,
    @required this.category,
    @required this.isCategoryValid,
    @required this.language,
    this.errorOccurred = false,
    this.parentTransactionId,
    this.isParentTransaction = false,
    this.imagePath,
    this.imageExists = false,
    this.isSavingForm = false,
    this.isRecurringTransactionRunning = true,
    this.nextRecurringDate,
    this.nextRecurringDateWasUpdated = false,
  });

  factory TransactionFormLoadedState.initial(AppLanguageType language) {
    final cat = CategoryUtils.getByName(CategoryUtils.question);
    final category = CategoryItem(
      id: 0,
      isAnIncome: false,
      name: cat.name,
      icon: cat.icon.icon,
      iconColor: Colors.blue,
    );
    final now = DateTime.now();
    final transactionDateString = DateUtils.formatAppDate(
      now,
      language,
      DateUtils.monthDayAndYearFormat,
    );

    return TransactionFormLoadedState(
      id: 0,
      amount: 0,
      isAmountValid: false,
      isAmountDirty: false,
      description: '',
      isDescriptionValid: false,
      isDescriptionDirty: false,
      transactionDate: now,
      transactionDateString: transactionDateString,
      isTransactionDateValid: true,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      repetitionCycle: RepetitionCycleType.none,
      category: category,
      isCategoryValid: false,
      language: language,
      errorOccurred: false,
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
    DateTime firstDate,
    RepetitionCycleType repetitionCycle,
    CategoryItem category,
    bool isCategoryValid,
    AppLanguageType language,
    bool errorOccurred,
    int parentTransactionId,
    bool isParentTransaction,
    String imagePath,
    bool imageExists,
    bool isSavingForm,
    bool isRecurringTransactionRunning,
    DateTime nextRecurringDate,
    bool nextRecurringDateWasUpdated,
  }) {
    final date = transactionDate ?? this.transactionDate;
    final transactionDateString = DateUtils.formatAppDate(
      date,
      language ?? this.language,
      DateUtils.monthDayAndYearFormat,
    );

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
      transactionDateString: transactionDateString,
      firstDate: firstDate ?? this.firstDate,
      lastDate: lastDate,
      repetitionCycle: repetitionCycle ?? this.repetitionCycle,
      category: category ?? this.category,
      isCategoryValid: isCategoryValid ?? this.isCategoryValid,
      language: language ?? this.language,
      errorOccurred: errorOccurred ?? this.errorOccurred,
      isParentTransaction: isParentTransaction ?? this.isParentTransaction,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
      imagePath: imagePath ?? this.imagePath,
      imageExists: imageExists ?? this.imageExists,
      isSavingForm: isSavingForm ?? this.isSavingForm,
      isRecurringTransactionRunning:
          isRecurringTransactionRunning ?? this.isRecurringTransactionRunning,
      nextRecurringDate: nextRecurringDate ?? this.nextRecurringDate,
      nextRecurringDateWasUpdated:
          nextRecurringDateWasUpdated ?? this.nextRecurringDateWasUpdated,
    );
  }

  TransactionItem buildTransactionItem(String imgFilename) {
    final amountToSave = amount.abs();
    DateTime nextecurringDate =
        repetitionCycle == RepetitionCycleType.none ? null : transactionDate;
    final isParentTransaction = nextecurringDate != null;

    if (!isRecurringTransactionRunning) {
      nextecurringDate = null;
    }

    return TransactionItem(
      id: id,
      amount: category.isAnIncome ? amountToSave : amountToSave * -1,
      category: category,
      description: description.trim(),
      repetitionCycle: repetitionCycle,
      transactionDate: transactionDate,
      isParentTransaction: isParentTransaction,
      parentTransactionId: parentTransactionId,
      nextRecurringDate: nextecurringDate,
      imagePath: imgFilename,
    );
  }
}

class TransactionChangedState extends TransactionFormState {
  final bool wasCreated;
  final bool wasUpdated;
  final bool wasDeleted;
  final DateTime transactionDate;

  const TransactionChangedState({
    this.wasCreated,
    this.wasUpdated,
    this.wasDeleted,
    this.transactionDate,
  });

  factory TransactionChangedState.created(DateTime transactionDate) =>
      TransactionChangedState(
        wasCreated: true,
        wasDeleted: false,
        wasUpdated: false,
        transactionDate: transactionDate,
      );

  factory TransactionChangedState.updated(DateTime transactionDate) =>
      TransactionChangedState(
        wasCreated: false,
        wasDeleted: false,
        wasUpdated: true,
        transactionDate: transactionDate,
      );

  factory TransactionChangedState.deleted(DateTime transactionDate) =>
      TransactionChangedState(
        wasCreated: false,
        wasDeleted: true,
        wasUpdated: false,
        transactionDate: transactionDate,
      );
}
