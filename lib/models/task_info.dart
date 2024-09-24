import 'package:fluent_ui/fluent_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_info.freezed.dart';

@freezed
class TaskInfo with _$TaskInfo {
  const factory TaskInfo({
    required bool active,
    required Color color,
    required int time,
  }) = _TaskInfo;
}
