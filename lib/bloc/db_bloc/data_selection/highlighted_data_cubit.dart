import 'package:bloc/bloc.dart';
import 'package:windows_apps_time_measurements_app/models/chart_data/chart_data.dart';

class HighlightedDataCubit extends Cubit<ChartData?> {
  HighlightedDataCubit() : super(null);
  void selectData(ChartData chartData) {
    emit(chartData);
  }

  void resetSelection() {
    emit(null);
  }
}
