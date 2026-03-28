part of 'charts_bloc.dart';

@freezed
sealed class ChartsEvent with _$ChartsEvent {
  const factory ChartsEvent.init() = ChartsEventInit;
  const factory ChartsEvent.periodChanged({required ChartPeriodType period}) = ChartsEventPeriodChanged;
  const factory ChartsEvent.customRangeSelected({
    required DateTime start,
    required DateTime end,
  }) = ChartsEventCustomRangeSelected;
}
