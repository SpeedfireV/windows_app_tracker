import 'package:freezed_annotation/freezed_annotation.dart';

part 'date_filter.freezed.dart';

@freezed
class DateFilter with _$DateFilter {
  const factory DateFilter({
    required DateTime startDate,
    required DateTime endDate,
  }) = _DateFilter;
}
