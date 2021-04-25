part of 'charts_bloc.dart';

@freezed
class ChartsEvent with _$ChartsEvent {
  const factory ChartsEvent.loadChart({
    required DateTime from,
  }) = _LoadChart;
}
