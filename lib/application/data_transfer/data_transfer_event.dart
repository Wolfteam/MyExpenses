part of 'data_transfer_bloc.dart';

@freezed
sealed class DataTransferEvent with _$DataTransferEvent {
  const factory DataTransferEvent.export() = DataTransferEventExport;
  const factory DataTransferEvent.import({required String filePath}) = DataTransferEventImport;
  const factory DataTransferEvent.clearAll() = DataTransferEventClearAll;
}
