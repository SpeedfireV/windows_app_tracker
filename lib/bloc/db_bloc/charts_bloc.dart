import 'package:bloc/bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:windows_apps_time_measurements_app/models/datefilter/date_filter.dart';

import '../../models/app.dart';

part 'charts_event.dart';
part 'charts_state.dart';

class ChartsBloc extends Bloc<ChartsEvent, ChartsState> {
  DateFilter? dateFilter;

  @override
  void onChange(Change<ChartsState> change) {
    super.onChange(change);
    print(change);
  }

  ChartsBloc() : super(ChartsInitial()) {
    on<ChartsLoadPieChartData>((event, emit) {
      emit(ChartsPieChartDataLoading());
      print("Received ${event.data}");
      Map<String, int> apps = {};
      for (App app in event.data) {
        apps[app.appName] = (apps[app.appName] ?? 0) + 1;
      }
      List<PieChartSectionData> pieChartData = [];
      for (String appName in apps.keys) {
        int timeSpent = apps[appName]!;
        pieChartData.add(PieChartSectionData(
            title: appName,
            value: timeSpent.toDouble(),
            color: Color(0xff0E6BA8),
            showTitle: false));
      }
      print(pieChartData);
      emit(ChartsPieChartDataLoaded(pieChartData));
    });
  }
}
