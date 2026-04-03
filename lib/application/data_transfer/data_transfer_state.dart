part of 'data_transfer_bloc.dart';

@freezed
sealed class ImportValidationError with _$ImportValidationError {
  const factory ImportValidationError.invalidFormat() = ImportValidationErrorInvalidFormat;
  const factory ImportValidationError.missingField({required String field}) = ImportValidationErrorMissingField;
}

@freezed
sealed class DataTransferState with _$DataTransferState {
  const factory DataTransferState.idle() = DataTransferStateIdle;
  const factory DataTransferState.loading() = DataTransferStateLoading;
  const factory DataTransferState.success({required DataTransferOperation operation}) = DataTransferStateSuccess;
  const factory DataTransferState.error({required DataTransferOperation operation}) = DataTransferStateError;
  const factory DataTransferState.importValidationError({
    required ImportValidationError validationError,
  }) = DataTransferStateImportValidationError;
}
