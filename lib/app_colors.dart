import 'package:fluent_ui/fluent_ui.dart';

class AppColors {
  static final Color mainColor = Color(0xff0E0F27);
  static final Color sideColor = Color(0xff9C0D38);
  static final Color snowishColor = Color(0xfff5fefd);
  static final Color whitishColor = Color(0xffD8E4FF);
}

Color darkenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}
