///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 01:35
///
part of 'data_model.dart';

/// 课程实体
///
/// [isCustom] **必需**是否自定义课程,
/// [name] 课程名称, [time] 上课时间, [location] 上课地点, [className] 班级名称,
/// [teacher] 教师名称, [day] 上课日, [startWeek] 开始周, [endWeek] 结束周,
/// [oddEven] 是否为单双周, 0为普通, 1为单周, 2为双周,
/// [classesName] 共同上课的班级, [isEleven] 是否第十一节,
///
/// [rawDay] 原始天数 [rawTime] 原始课时
/// 以上两项用于编辑课程信息。由于课程表的数据错乱，需要保存原始数据，否则会造成编辑错误。
@HiveType(typeId: HiveAdapterTypeIds.course)
// ignore: must_be_immutable
class CourseModel extends DataModel {
  CourseModel({
    this.isCustom = false,
    required this.name,
    required this.time,
    this.location,
    this.className,
    this.teacher,
    required this.day,
    required this.startWeek,
    required this.endWeek,
    required this.classesName,
    required this.isEleven,
    this.oddEven,
    required this.rawDay,
    required this.rawTime,
  });

  factory CourseModel.fromJson(
    Map<String, dynamic> json, {
    bool isCustom = false,
  }) {
    json.forEach((String k, dynamic _) {
      if (json[k] == '') {
        json[k] = null;
      }
    });
    final int? _oddEven = !isCustom ? judgeOddEven(json) : null;
    final List<String>? weeks =
        !isCustom ? (json['allWeek'] as String).split(' ')[0].split('-') : null;

    String _name;
    if (isCustom) {
      try {
        _name = Uri.decodeComponent(json['content'].toString());
      } catch (e) {
        _name = json['content'].toString();
      }
    } else {
      _name = json['couName']?.toString() ?? '(空)';
    }

    int _time;
    if (isCustom) {
      _time = timeHandler(json['courseTime']);
    } else {
      _time = timeHandler(json['coudeTime']);
    }

    final CourseModel _c = CourseModel(
      isCustom: isCustom,
      name: _name,
      time: _time,
      location: json['couRoom'] as String?,
      className: json['className'] as String?,
      teacher: json['couTeaName'] as String?,
      day: json[isCustom ? 'courseDaytime' : 'couDayTime']
          .toString()
          .substring(0, 1)
          .toInt(),
      startWeek: !isCustom ? weeks![0].toInt() : null,
      endWeek: !isCustom ? weeks![1].toInt() : null,
      classesName:
          !isCustom ? json['comboClassName']?.toString().split(',') : null,
      isEleven: json['three'] == 'y',
      oddEven: _oddEven,
      rawDay:
          json[isCustom ? 'courseDaytime' : 'couDayTime'].toString().toInt(),
      rawTime: json[isCustom ? 'courseTime' : 'coudeTime'].toString(),
    );
    _c.uniqueColor(CourseAPI.randomCourseColor());
    return _c;
  }

  @HiveField(0)
  final bool isCustom;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int time;
  @HiveField(3)
  final String? location;
  @HiveField(4)
  final String? className;
  @HiveField(5)
  final String? teacher;
  @HiveField(6)
  final int day;
  @HiveField(7)
  final int? startWeek;
  @HiveField(8)
  final int? endWeek;
  @HiveField(9)
  final int? oddEven;
  @HiveField(10)
  final List<String>? classesName;
  @HiveField(11)
  final bool isEleven;
  @HiveField(12)
  final int rawDay;
  @HiveField(13)
  final String rawTime;
  Color? color;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isCustom': isCustom,
      'name': name,
      'time': time,
      'room': location,
      'className': className,
      'teacher': teacher,
      'day': day,
      'startWeek': startWeek,
      'endWeek': endWeek,
      'classesName': classesName,
      'isEleven': isEleven,
      'oddEven': oddEven,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        isCustom,
        name,
        time,
        location,
        className,
        teacher,
        day,
        startWeek,
        endWeek,
        classesName,
        isEleven,
        oddEven,
      ];

  /// 根据数据判断课程的单双周
  static int judgeOddEven(Map<String, dynamic> json) {
    int _oddEven = 0;
    final List<String> _split = (json['allWeek'] as String).split(' ');
    if (_split.length > 1) {
      switch (_split[1]) {
        case '单周':
          _oddEven = 1;
          break;
        case '双周':
          _oddEven = 2;
          break;
      }
    }
    return _oddEven;
  }

  /// 将各种各样的上课时间转换为指定的课时
  ///
  /// 你绝对想象不到课程表的数据有多乱 :)
  static int timeHandler(dynamic time) {
    assert(time != null, 'Time of course cannot be null.');
    int courseTime = 0;
    switch (time.toString()) {
      case '1':
      case '2':
      case '12':
      case '23':
        courseTime = 1;
        break;
      case '3':
      case '4':
      case '34':
      case '45':
        courseTime = 3;
        break;
      case '5':
      case '6':
      case '56':
      case '67':
        courseTime = 5;
        break;
      case '7':
      case '8':
      case '78':
      case '89':
        courseTime = 7;
        break;
      case '90':
      case '911':
      case '9':
      case '10':
        courseTime = 9;
        break;
      case '11':
        courseTime = 11;
        break;
    }
    return courseTime;
  }

  /// 生成唯一的课程颜色
  void uniqueColor(Color color) {
    final CourseColor? _courseColor =
        CourseAPI.coursesUniqueColor.firstWhereOrNull(
      (CourseColor color) => color.name == name,
    );
    if (_courseColor != null) {
      color = _courseColor.color;
    } else {
      final List<CourseColor> courses = CourseAPI.coursesUniqueColor
          .where((CourseColor c) => c.color == color)
          .toList();

      if (courses.isNotEmpty) {
        uniqueColor(CourseAPI.randomCourseColor());
      } else {
        color = color;
        CourseAPI.coursesUniqueColor.add(
          CourseColor(name: name, color: color),
        );
      }
    }
  }

  /// 是否需要使用原始数据进行编辑
  ///
  /// 某些课程数据十分诡异，所以我们会转换成自己的数据，操作时仍然需要利用源数据。
  bool get shouldUseRaw => day != rawDay || time.toString() != rawTime;

  String get weekDurationString => '$startWeek-$endWeek'
      '${oddEven == 1 ? '单' : oddEven == 2 ? '双' : ''}周';

  String get timeString {
    String _content = '';
    if (time > 8) {
      _content += '晚上';
    } else if (time > 4) {
      _content += '下午';
    } else {
      _content += '上午';
    }
    _content += _getCourseStartTime(time);
    _content += ' - ';
    _content += _getCourseEndTime(time + 1);
    return _content;
  }

  /// 是否准备上课
  bool get inReadyTime {
    final double timeNow = _timeToDouble(TimeOfDay.now());
    final List<TimeOfDay> times = _courseTime[time]!;
    final double start = _timeToDouble(times[0]);
    return start - timeNow <= 0.5 && start - timeNow > 0;
  }

  /// 是否正在上课
  bool get inCurrentTime {
    final double timeNow = _timeToDouble(TimeOfDay.now()) - (1 / 60);
    final double start = _timeToDouble(_courseTime[time]![0]);
    double end = _timeToDouble(_courseTime[time + 1]![1]) - (1 / 60);
    if (isEleven) {
      end = _timeToDouble(_courseTime[11]![1]);
    }
    return start <= timeNow && end >= timeNow;
  }

  /// 是否已经下课
  bool get isOver {
    final TimeOfDay overTime = _courseTime[time + 1]![1];
    return TimeOfDay.now().isAfter(overTime);
  }

  /// 是否为当日课程
  bool inCurrentDay([int? weekday]) => day == (weekday ?? currentTime.weekday);

  /// 课程是否属于当前周
  ///
  /// 自定义课程一定为当前周，因为其没有周数限制。
  bool inCurrentWeek([int? currentWeek]) {
    if (isCustom) {
      return true;
    }
    final DateProvider provider = currentContext.read<DateProvider>();
    final int week = currentWeek ?? provider.currentWeek;
    bool result = false;
    final bool inRange = week >= startWeek! && week <= endWeek!;
    final bool isOddEven = oddEven != 0;
    if (isOddEven) {
      if (oddEven == 1) {
        result = inRange && week.isOdd;
      } else if (oddEven == 2) {
        result = inRange && week.isEven;
      }
    } else {
      result = inRange;
    }
    return result;
  }
}

@immutable
class CourseColor {
  const CourseColor({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseColor &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'CourseColor ($name, $color)';
}

String _getCourseStartTime(int courseIndex) {
  return _getCourseTimeString(_courseTime[courseIndex]![0]);
}

String _getCourseEndTime(int courseIndex) {
  return _getCourseTimeString(_courseTime[courseIndex]![1]);
}

String _getCourseTimeString(TimeOfDay time) {
  final String hour = time.hour.toString();
  final String minute = '${time.minute < 10 ? '0' : ''}${time.minute}';
  return '$hour:$minute';
}

Map<int, List<TimeOfDay>> _courseTime = <int, List<TimeOfDay>>{
  1: <TimeOfDay>[_time(08, 00), _time(08, 45)],
  2: <TimeOfDay>[_time(08, 50), _time(09, 35)],
  3: <TimeOfDay>[_time(10, 05), _time(10, 50)],
  4: <TimeOfDay>[_time(10, 55), _time(11, 40)],
  5: <TimeOfDay>[_time(14, 00), _time(14, 45)],
  6: <TimeOfDay>[_time(14, 50), _time(15, 35)],
  7: <TimeOfDay>[_time(15, 55), _time(16, 40)],
  8: <TimeOfDay>[_time(16, 45), _time(17, 30)],
  9: <TimeOfDay>[_time(19, 00), _time(19, 45)],
  10: <TimeOfDay>[_time(19, 50), _time(20, 35)],
  11: <TimeOfDay>[_time(20, 40), _time(21, 25)],
  12: <TimeOfDay>[_time(21, 30), _time(22, 15)],
};

Map<String, String> _courseTimeChinese = <String, String>{
  '1': '一二节',
  '12': '一二节',
  '3': '三四节',
  '34': '三四节',
  '5': '五六节',
  '56': '五六节',
  '7': '七八节',
  '78': '七八节',
  '9': '九十节',
  '90': '九十节',
  '11': '十一节',
  '911': '九十十一节',
};

TimeOfDay _time(int hour, int minute) => TimeOfDay(hour: hour, minute: minute);

double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;
