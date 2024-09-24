part of 'data_selection_bloc.dart';

@immutable
sealed class DataSelectionState {}

final class DataSelectionInitial extends DataSelectionState {}

final class DataSelectionUpdatingDataSelection extends DataSelectionState {}

final class DataSelectionDataSelected extends DataSelectionState {
  final List<ChartData> chartData;

  DataSelectionDataSelected(this.chartData);
}

final class DataSelectionUpdatingData extends DataSelectionState {}
