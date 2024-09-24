part of 'charts_bloc.dart';

@immutable
sealed class ChartsEvent {}

final class ChartsLoadPieChartData extends ChartsEvent {
  final List<ChartData> data;

  ChartsLoadPieChartData(this.data);
}

final class ChartsUpdatePieChartFilter extends ChartsEvent {
  final List<PieChartSectionData> appsData, tasksData;
  final Map<String, bool>? app;
  final Map<String, bool>? task;

  ChartsUpdatePieChartFilter(
      this.appsData, this.tasksData, this.app, this.task);
}
