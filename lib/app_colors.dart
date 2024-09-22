import 'dart:math';

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

Color generateVisibleColor(Color backgroundColor) {
  // Generate a color with different hue but high lightness and saturation for visibility
  final hslBackground = HSLColor.fromColor(backgroundColor);
  final randomHue = Random().nextDouble(); // Random hue between 0.0 and 1.0
  final visibleColor = HSLColor.fromAHSL(
      1.0, randomHue * 360, 0.8, 0.7); // High saturation and lightness

  return visibleColor.toColor();
}
