part of 'data_transfer_bloc.dart';

typedef CsvLabels = ({
  String date,
  String description,
  String amount,
  String category,
  String type,
  String paymentMethod,
  String income,
  String expense,
  String longDescription,
  String repetitionCycle,
  String isRecurring,
  String yes,
  String no,
});

@freezed
sealed class DataTransferEvent with _$DataTransferEvent {
  const factory DataTransferEvent.export({
    @Default(false) bool isCsv,
    CsvLabels? csvLabels,
  }) = DataTransferEventExport;
  const factory DataTransferEvent.import({required String filePath}) = DataTransferEventImport;
  const factory DataTransferEvent.clearAll() = DataTransferEventClearAll;
}
