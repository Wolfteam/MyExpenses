part of 'transaction_form_bloc.dart';

@freezed
class TransactionFormEvent with _$TransactionFormEvent {
  const factory TransactionFormEvent.add() = _Add;

  const factory TransactionFormEvent.edit({
    required int id,
  }) = _Edit;

  const factory TransactionFormEvent.amountChanged({
    required double amount,
  }) = _AmountChanged;

  const factory TransactionFormEvent.descriptionChanged({
    required String description,
  }) = _DescriptionChanged;

  const factory TransactionFormEvent.longDescriptionChanged({
    required String longDescription,
  }) = _LongDescriptionChanged;

  const factory TransactionFormEvent.transactionDateChanged({
    required DateTime transactionDate,
  }) = _TransactionDateChanged;

  const factory TransactionFormEvent.repetitionCycleChanged({
    required RepetitionCycleType repetitionCycle,
  }) = _RepetitionCycleChanged;

  const factory TransactionFormEvent.categoryWasUpdated({
    required CategoryItem category,
  }) = _CategoryWasUpdated;

  const factory TransactionFormEvent.imageChanged({
    required String path,
    required bool imageExists,
  }) = _ImageChanged;

  const factory TransactionFormEvent.isRunningChanged({
    required bool isRunning,
  }) = _IsRunningChanged;

  const factory TransactionFormEvent.deleteTransaction({
    required bool keepChildren,
  }) = _DeleteTransaction;

  const factory TransactionFormEvent.submit() = _Submit;

  const factory TransactionFormEvent.close() = _Close;
}
