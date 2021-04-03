///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 11/20/20 3:46 PM
///
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  bool isTheSameDayOf(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }

  String get timeText => withDateTimeFormat();

  DateTime get startOfTheDay => DateTime(year, month, day);

  DateTime get endOfTheDay => DateTime(year, month, day, 23, 59, 59);
}

extension NullableDataTimeExtension on DateTime? {
  String withDateTimeFormat([String format = 'yyyy-MM-dd HH:mm:ss']) {
    if (this == null) {
      return '';
    }
    return DateFormat(format).format(this!);
  }
}
