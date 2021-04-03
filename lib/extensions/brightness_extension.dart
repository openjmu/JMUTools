///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 11/27/20 3:09 PM
///
import 'dart:ui';

extension BrightnessExtension on Brightness {
  bool get isDark => this == Brightness.dark;
  bool get isLight => this == Brightness.light;
}
