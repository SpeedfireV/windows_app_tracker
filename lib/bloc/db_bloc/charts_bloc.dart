import 'package:bloc/bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:windows_apps_time_measurements_app/models/chart_data/chart_data.dart';
import 'package:windows_apps_time_measurements_app/models/datefilter/date_filter.dart';

import '../../models/app.dart';

part 'charts_event.dart';
part 'charts_state.dart';

class ChartsBloc extends Bloc<ChartsEvent, ChartsState> {
  DateFilter? dateFilter;
  Map<String, int> allApps = {};
  Map<String, Map<String, int>> allTasks = {};
  List<String> exemptedTitles = [];
  Map<String, String> exemptedTasks = {};
  Iterable<App> allActivity = [];

  @override
  void onChange(Change<ChartsState> change) {
    super.onChange(change);
    print(change);
  }

  ChartsBloc() : super(ChartsInitial()) {
    on<ChartsLoadPieChartData>((event, emit) {
      emit(ChartsPieChartDataLoading());
      print("Received ${event.data}");
      List<ChartData> allActivity = event.data;
      List<PieChartSectionData> appsPieChartData = [];
      List<PieChartSectionData> tasksPieChartData = [];
      for (ChartData chartData in allActivity) {
        appsPieChartData.add(PieChartSectionData(
            title: chartData.appName,
            value: chartData.getTotalTime().toDouble(),
            color: chartData.color,
            showTitle: false));

        for (String task in chartData.mapOfTasks.keys) {
          if (chartData.mapOfTasks[task]!.active) {
            tasksPieChartData.add(PieChartSectionData(
                title: task,
                value: chartData.mapOfTasks[task]!.time.toDouble(),
                color: chartData.mapOfTasks[task]!.color,
                showTitle: false));
          }
        }
      }
      emit(ChartsPieChartDataLoaded(appsPieChartData, tasksPieChartData));
    });
  }
}
