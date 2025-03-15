part of 'transaction_form_bloc.dart';

@freezed
sealed class TransactionFormState with _$TransactionFormState {
  static TransactionFormState created(DateTime transactionDate) => TransactionFormState.transactionChanged(
    wasCreated: true,
    wasDeleted: false,
    wasUpdated: false,
    transactionDate: transactionDate,
  );

  static TransactionFormState updated(DateTime transactionDate) => TransactionFormState.transactionChanged(
    wasCreated: false,
    wasDeleted: false,
    wasUpdated: true,
    transactionDate: transactionDate,
  );

  static TransactionFormState deleted(DateTime transactionDate) => TransactionFormState.transactionChanged(
    wasCreated: false,
    wasDeleted: true,
    wasUpdated: false,
    transactionDate: transactionDate,
  );

  static bool isNewTransaction(TransactionFormStateInitialState state) => state.id <= 0;

  static bool isChildTransaction(TransactionFormStateInitialState state) =>
      !state.isParentTransaction && state.parentTransactionId != null;

  static bool isFormValid(TransactionFormStateInitialState state) =>
      state.isAmountValid && state.isDescriptionValid && state.isTransactionDateValid && state.isCategoryValid;

  const factory TransactionFormState.loading() = TransactionFormStateLoadingState;

  const factory TransactionFormState.initial({
    required int id,
    required double amount,
    required bool isAmountValid,
    required bool isAmountDirty,
    required String description,
    required bool isDescriptionValid,
    required bool isDescriptionDirty,
    String? longDescription,
    required bool isLongDescriptionValid,
    required bool isLongDescriptionDirty,
    required DateTime transactionDate,
    required bool isTransactionDateValid,
    required String transactionDateString,
    required DateTime firstDate,
    required DateTime lastDate,
    required RepetitionCycleType repetitionCycle,
    required CategoryItem category,
    required bool isCategoryValid,
    required AppLanguageType language,
    required LanguageModel languageModel,
    @Default(false) bool errorOccurred,
    int? parentTransactionId,
    @Default(false) bool isParentTransaction,
    String? imagePath,
    @Default(false) bool imageExists,
    @Default(false) bool isSavingForm,
    @Default(true) bool isRecurringTransactionRunning,
    DateTime? nextRecurringDate,
    @Default(false) bool nextRecurringDateWasUpdated,
  }) = TransactionFormStateInitialState;

  const factory TransactionFormState.transactionChanged({
    required bool wasCreated,
    required bool wasUpdated,
    required bool wasDeleted,
    required DateTime transactionDate,
  }) = TransactionFormStateTransactionChanged;
}
