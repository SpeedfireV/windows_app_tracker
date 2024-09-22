part of 'charts_bloc.dart';

@immutable
sealed class ChartsState {}

final class ChartsInitial extends ChartsState {}

final class ChartsPieChartDataLoading extends ChartsState {}

final class ChartsPieChartDataLoaded extends ChartsState {
  final List<PieChartSectionData> data;

  ChartsPieChartDataLoaded(this.data);
}
