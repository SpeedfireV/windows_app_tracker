import 'package:fluent_ui/fluent_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:windows_apps_time_measurements_app/models/app.dart';
import 'package:windows_apps_time_measurements_app/models/task_info.dart';

part 'chart_data.freezed.dart';

@freezed
class ChartData with _$ChartData {
  const ChartData._();
  const factory ChartData({
    required String appName,
    required bool active,
    required Color color,
    required Map<String, TaskInfo> mapOfTasks,
  }) = _ChartData;

  int getActiveTasksTime() {
    int totalTime = 0;
    for (TaskInfo taskInfo in mapOfTasks.values) {
      if (taskInfo.active) {
        totalTime += taskInfo.time;
      }
    }
    return totalTime;
  }

  int getTotalTime() {
    int totalTime = 0;
    for (TaskInfo taskInfo in mapOfTasks.values) {
      totalTime += taskInfo.time;
    }
    return totalTime;
  }

  bool isSameApp(App app) {
    return appName == app.appName;
  }

  bool isTaskActive(String taskName) {
    return mapOfTasks[taskName]!.active;
  }
}
