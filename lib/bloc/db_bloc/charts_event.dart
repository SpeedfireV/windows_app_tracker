part of 'charts_bloc.dart';

@immutable
sealed class ChartsEvent {}

final class ChartsLoadPieChartData extends ChartsEvent {
  final Iterable<App> data;

  ChartsLoadPieChartData(this.data);
}
