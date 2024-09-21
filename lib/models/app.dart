import 'package:freezed_annotation/freezed_annotation.dart';

part "app.freezed.dart";
part 'app.g.dart';

@freezed
class App with _$App {
  const factory App(
      {@JsonKey(name: "app_name") required String appName,
      @JsonKey(name: "app_task") required String appTask,
      @JsonKey(name: "created_at") required DateTime createdAt}) = _App;
  factory App.fromJson(Map<String, Object?> json) => _$AppFromJson(json);
}
