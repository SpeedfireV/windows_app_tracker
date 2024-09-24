part of 'charts_bloc.dart';

@immutable
sealed class ChartsState {}

final class ChartsInitial extends ChartsState {}

final class ChartsPieChartDataLoading extends ChartsState {}

final class ChartsPieChartDataLoaded extends ChartsState {
  final List<PieChartSectionData> appsData, tasksData;

  ChartsPieChartDataLoaded(this.appsData, this.tasksData);
}

final class ChartsChangingChartData extends ChartsState {}
