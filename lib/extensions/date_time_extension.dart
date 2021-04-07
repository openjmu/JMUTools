///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 11/20/20 3:46 PM
///
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  bool isTheSameDayOf(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }

  String get timeText => withDateTimeFormat();

  DateTime get startOfTheDay => DateTime(year, month, day);

  DateTime get endOfTheDay => DateTime(year, month, day, 23, 59, 59);

  String get mDddd => '${withDateTimeFormat('M月d日')}'
      '${_shortWeekdays[weekday]}';
}

extension NullableDataTimeExtension on DateTime? {
  String withDateTimeFormat([String format = 'yyyy-MM-dd HH:mm:ss']) {
    if (this == null) {
      return '';
    }
    return DateFormat(format).format(this!);
  }
}

extension TimeOfDayExtension on TimeOfDay {
  bool isBefore(TimeOfDay other) {
    return hour < other.hour || (hour == other.hour && minute < other.minute);
  }

  bool isAfter(TimeOfDay other) {
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }
}

const Map<int, String> _shortWeekdays = <int, String>{
  1: '星期一',
  2: '星期二',
  3: '星期三',
  4: '星期四',
  5: '星期五',
  6: '星期六',
  7: '星期日',
};
