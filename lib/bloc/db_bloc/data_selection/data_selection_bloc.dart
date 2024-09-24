import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:windows_apps_time_measurements_app/models/chart_data/chart_data.dart';
import 'package:windows_apps_time_measurements_app/models/task_info.dart';

import '../../../app_colors.dart';
import '../../../models/app.dart';

part 'data_selection_event.dart';
part 'data_selection_state.dart';

class DataSelectionBloc extends Bloc<DataSelectionEvent, DataSelectionState> {
  DataSelectionBloc() : super(DataSelectionInitial()) {
    on<DataSelectionLoadData>((event, emit) {
      emit(DataSelectionUpdatingDataSelection());
      print("All activity: ${event.apps}");
      List<ChartData> chartData = [];
      Iterable<App> allActivity = event.apps;
      for (App app in allActivity) {
        bool foundInstance = false;
        for (ChartData data in chartData) {
          if (data.isSameApp(app)) {
            Map<String, TaskInfo> newMapOfTasks =
                Map<String, TaskInfo>.from(data.mapOfTasks);

            // Update the new modifiable map
            if (newMapOfTasks[app.appTask] != null) {
              int currentTime = newMapOfTasks[app.appTask]!.time;
              newMapOfTasks[app.appTask] =
                  newMapOfTasks[app.appTask]!.copyWith(time: currentTime + 1);
            } else {
              newMapOfTasks[app.appTask] = TaskInfo(
                  active: true,
                  time: 1,
                  color: generateVisibleColor(AppColors.mainColor));
            }

            ChartData updatedData = data.copyWith(mapOfTasks: newMapOfTasks);
            chartData.remove(data);
            chartData.insert(0, updatedData);
            foundInstance = true;
            break;
          }
        }
        if (!foundInstance) {
          chartData.add(ChartData(
              active: true,
              appName: app.appName,
              mapOfTasks: {
                app.appTask: TaskInfo(
                    active: true,
                    time: 1,
                    color: generateVisibleColor(AppColors.mainColor))
              },
              color: generateVisibleColor(AppColors.mainColor)));
        }
      }
      emit(DataSelectionDataSelected(chartData));
    });
    on<DataSelectionUpdateData>((event, emit) {
      emit(DataSelectionUpdatingData());
      List<ChartData> newChartData = event.currentData;

      if (event.taskName == null) {
        print("Task name is null");
        for (ChartData data in newChartData) {
          if (data.appName == event.appName) {
            print("Found corresponding App Name");
            Map<String, TaskInfo> newMapOfTasks = {};
            for (String key in data.mapOfTasks.keys) {
              newMapOfTasks[key] =
                  data.mapOfTasks[key]!.copyWith(active: event.adding);
            }
            ChartData copiedData =
                data.copyWith(active: event.adding, mapOfTasks: newMapOfTasks);
            print("Previous data: $data");
            print("Copied data: $copiedData");
            int index = newChartData.indexOf(data);
            print(newChartData);
            newChartData[index] = copiedData;
            print(newChartData);
            break;
          }
        }
      } else {
        for (ChartData data in newChartData) {
          if (data.appName == event.appName) {
            Map<String, TaskInfo> newMapOfTasks =
                Map<String, TaskInfo>.from(data.mapOfTasks);

            TaskInfo copiedTaskInfo =
                data.mapOfTasks[event.taskName]!.copyWith(active: event.adding);

            newMapOfTasks[event.taskName!] = copiedTaskInfo;

            ChartData copiedData;
            if (event.adding) {
              copiedData = data.copyWith(
                  active: event.adding, mapOfTasks: newMapOfTasks);
            } else {
              copiedData = data.copyWith(mapOfTasks: newMapOfTasks);
            }

            int index = newChartData.indexOf(data);
            newChartData[index] = copiedData;
            break;
          }
        }
      }

      emit(DataSelectionDataSelected(newChartData));
    });
  }
}
