///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 5:37 PM
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Screens {
  const Screens._();

  static MediaQueryData get mediaQuery => MediaQueryData.fromWindow(ui.window);

  static double fixedFontSize(double fontSize) => fontSize / textScaleFactor;

  static double get scale => mediaQuery.devicePixelRatio;

  static double get width => mediaQuery.size.width;

  static int get widthPixels => (width * scale).toInt();

  static double get height => mediaQuery.size.height;

  static int get heightPixels => (height * scale).toInt();

  static double get aspectRatio => width / height;

  static double get textScaleFactor => mediaQuery.textScaleFactor;

  static double get navigationBarHeight =>
      mediaQuery.padding.top + kToolbarHeight;

  static double get topSafeHeight => mediaQuery.padding.top;

  static double get bottomSafeHeight => mediaQuery.padding.bottom;

  static double get safeHeight => height - topSafeHeight - bottomSafeHeight;

  static void updateStatusBarStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

/// Screen capability method.
double suSetSp(double size, {double scale = 1}) =>
    _sizeCapable(size, scale: scale);

double suSetWidth(double size, {double scale = 1}) =>
    _sizeCapable(size, scale: scale);

double suSetHeight(double size, {double scale = 1}) =>
    _sizeCapable(size, scale: scale);

double _sizeCapable(num size, {double scale = 1}) => (size * scale).toDouble();

extension SizeExtension on num {
  double get w => _sizeCapable(this);

  double get h => _sizeCapable(this);

  double get sp => _sizeCapable(this);

  double get ssp => _sizeCapable(this);
}
