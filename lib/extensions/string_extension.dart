///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-01-31 17:41
///
import 'package:flutter/widgets.dart';
import 'date_time_extension.dart';

extension StringExtension on String {
  String get notBreak => Characters(this).toList().join('\u{200B}');

  String get trimmed => trim();

  String get timeText => withDateTimeFormat();
}

extension NullableStringExtension on String? {
  String withDateTimeFormat([String format = 'yyyy-MM-dd HH:mm:ss']) {
    if (this == null) {
      return '';
    }
    return DateTime.parse(this!).withDateTimeFormat(format);
  }
}
