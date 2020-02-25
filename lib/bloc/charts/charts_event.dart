part of 'charts_bloc.dart';

abstract class ChartsEvent extends Equatable {
  @override
  List<Object> get props => [];
  const ChartsEvent();
}

class LoadChart extends ChartsEvent {
  final DateTime from;

  const LoadChart(this.from);
}
