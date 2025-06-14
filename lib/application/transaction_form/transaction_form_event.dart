part of 'transaction_form_bloc.dart';

@freezed
sealed class TransactionFormEvent with _$TransactionFormEvent {
  const factory TransactionFormEvent.add() = TransactionFormEventAdd;

  const factory TransactionFormEvent.edit({required int id}) = TransactionFormEventEdit;

  const factory TransactionFormEvent.amountChanged({required double amount}) = TransactionFormEventAmountChanged;

  const factory TransactionFormEvent.descriptionChanged({required String description}) = TransactionFormEventDescriptionChanged;

  const factory TransactionFormEvent.longDescriptionChanged({required String longDescription}) =
      TransactionFormEventLongDescriptionChanged;

  const factory TransactionFormEvent.transactionDateChanged({required DateTime transactionDate}) =
      TransactionFormEventTransactionDateChanged;

  const factory TransactionFormEvent.repetitionCycleChanged({required RepetitionCycleType repetitionCycle}) =
      TransactionFormEventRepetitionCycleChanged;

  const factory TransactionFormEvent.categoryWasUpdated({required CategoryItem category}) =
      TransactionFormEventCategoryWasUpdated;

  const factory TransactionFormEvent.imageChanged({required String path, required bool imageExists}) =
      TransactionFormEventImageChanged;

  const factory TransactionFormEvent.isRunningChanged({required bool isRunning}) = TransactionFormEventIsRunningChanged;

  const factory TransactionFormEvent.deleteTransaction({required bool keepChildren}) = TransactionFormEventDeleteTransaction;

  const factory TransactionFormEvent.submit() = TransactionFormEventSubmit;
}
