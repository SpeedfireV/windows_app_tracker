import 'package:intl/intl.dart';

String formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final DateTime time = DateTime(0).add(duration);
  return DateFormat('HH:mm:ss').format(time);
}
