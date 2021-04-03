///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 11/30/20 1:36 PM
///
import 'dart:math' as math;

extension NumExtension<T extends num> on T {
  T get lessThanOne => math.min<T>((this is int ? 1 : 1.0) as T, this);

  T get lessThanZero => math.min<T>((this is int ? 0 : 0.0) as T, this);

  T get moreThanOne => math.max<T>((this is int ? 1 : 1.0) as T, this);

  T get moreThanZero => math.max<T>((this is int ? 0 : 0.0) as T, this);

  T get betweenZeroAndOne => lessThanOne.moreThanZero;
}

extension IntExtension on int {
  /// 通过时间戳返回 `9小时15分6秒` 格式的时间字符串
  String get durationString {
    final Duration duration = Duration(seconds: this);
    if (this >= 3600) {
      final Duration hour = Duration(hours: duration.inHours);
      final Duration minute = Duration(minutes: duration.inMinutes) - hour;
      final Duration second =
          Duration(seconds: duration.inSeconds) - hour - minute;
      return '${hour.inHours}小时${minute.inMinutes}分${second.inSeconds}秒';
    } else if (this >= 60 && this < 3600) {
      final Duration minute = Duration(minutes: duration.inMinutes);
      final Duration second = Duration(seconds: duration.inSeconds) - minute;
      return '${minute.inMinutes}分${second.inSeconds}秒';
    } else {
      return '$this秒';
    }
  }

}
