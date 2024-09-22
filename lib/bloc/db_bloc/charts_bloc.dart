import 'package:bloc/bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:windows_apps_time_measurements_app/app_colors.dart';
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
      allActivity = event.data;
      Map<String, int> apps = {};
      Map<String, Map<String, int>> tasks = {};
      if (allApps.isEmpty) {
        allApps = apps;
      }
      if (allTasks.isEmpty) {
        allTasks = tasks;
      }
      for (App app in allActivity) {
        apps[app.appName] = (apps[app.appName] ?? 0) + 1;

        if (tasks[app.appName] == null) {
          tasks[app.appName] = {};
        }
        tasks[app.appName]![app.appTask] =
            (tasks[app.appName]![app.appTask] ?? 0) + 1;
      }
      List<PieChartSectionData> appsPieChartData = [];
      List<PieChartSectionData> tasksPieChartData = [];
      for (String appName in apps.keys) {
        int timeSpent = apps[appName]!;
        appsPieChartData.add(PieChartSectionData(
            title: appName,
            value: timeSpent.toDouble(),
            color: generateVisibleColor(AppColors.mainColor),
            showTitle: false));
        for (String taskName in tasks[appName]!.keys) {
          int timeSpent = tasks[appName]![taskName]!;
          tasksPieChartData.add(PieChartSectionData(
              title: taskName,
              value: timeSpent.toDouble(),
              color: generateVisibleColor(AppColors.mainColor),
              showTitle: false));
        }
      }
      print(appsPieChartData);
      emit(ChartsPieChartDataLoaded(appsPieChartData, tasksPieChartData));
    });
  }
}
