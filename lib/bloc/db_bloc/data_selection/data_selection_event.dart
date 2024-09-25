part of 'data_selection_bloc.dart';

@immutable
sealed class DataSelectionEvent {}

final class DataSelectionLoadData extends DataSelectionEvent {
  final Iterable<App> apps;

  DataSelectionLoadData(this.apps);
}

final class DataSelectionUpdateData extends DataSelectionEvent {
  final List<ChartData> currentData;
  final bool adding;
  final String appName;
  final String? taskName;

  DataSelectionUpdateData(
      {required this.adding,
      required this.appName,
      this.taskName,
      required this.currentData});
}

final class DataSelectionSwitchAll extends DataSelectionEvent {
  final List<ChartData> currentData;
  final bool turnOn;

  DataSelectionSwitchAll({required this.currentData, required this.turnOn});
}
