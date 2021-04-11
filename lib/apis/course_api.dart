///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 14:21
///
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/data_model.dart';
import '../utils/http_util.dart';
import 'api.dart';
import 'user_api.dart';

final math.Random _random = math.Random();

int next(int min, int max) => min + _random.nextInt(max - min);

class CourseAPI {
  const CourseAPI._();

  static Set<CourseColor> coursesUniqueColor = <CourseColor>{};

  static Future<String> getCourse({bool useVPN = false}) {
    return HttpUtil.fetch(
      FetchType.get,
      url: useVPN
          ? API.replaceWithWebVPN(API.courseScheduleCourses)
          : API.courseScheduleCourses,
      queryParameters: <String, String>{'sid': UserAPI.loginModel!.sid},
    );
  }

  static Future<String> getRemark({bool useVPN = false}) {
    return HttpUtil.fetch(
      FetchType.get,
      url: useVPN
          ? API.replaceWithWebVPN(API.courseScheduleClassRemark)
          : API.courseScheduleClassRemark,
      queryParameters: <String, String>{'sid': UserAPI.loginModel!.sid},
    );
  }

  static Future<String> setCustomCourse(Map<String, dynamic> course) {
    return HttpUtil.fetch(
      FetchType.post,
      url: '${API.courseScheduleCustom}?sid=${UserAPI.loginModel!.sid}',
      body: course,
    );
  }

  static String getCourseTime(int courseIndex) {
    final TimeOfDay time = coursesTime[courseIndex]![0];
    final String hour = time.hour.toString();
    final String minute = '${time.minute < 10 ? '0' : ''}${time.minute}';
    return '$hour:$minute';
  }

  static Color randomCourseColor() =>
      courseColorsList[next(0, courseColorsList.length)];
}

final Map<int, List<TimeOfDay>> coursesTime = <int, List<TimeOfDay>>{
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

TimeOfDay _time(int hour, int minute) => TimeOfDay(hour: hour, minute: minute);

const Map<String, String> _courseTimeChinese = <String, String>{
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

const List<Color> courseColorsList = <Color>[
  Color(0xffEF9A9A),
  Color(0xffF48FB1),
  Color(0xffCE93D8),
  Color(0xffB39DDB),
  Color(0xff9FA8DA),
  Color(0xff90CAF9),
  Color(0xff81D4FA),
  Color(0xff80DEEA),
  Color(0xff80CBC4),
  Color(0xffA5D6A7),
  Color(0xffC5E1A5),
  Color(0xffE6EE9C),
  Color(0xffFFF59D),
  Color(0xffFFE082),
  Color(0xffFFCC80),
  Color(0xffFFAB91),
  Color(0xffBCAAA4),
  Color(0xffd8b5df),
  Color(0xff68c0ca),
  Color(0xff05bac3),
  Color(0xffe98b81),
  Color(0xffd86f5c),
  Color(0xfffed68e),
  Color(0xfff8b475),
  Color(0xffc16594),
  Color(0xffaccbd0),
  Color(0xffe6e5d1),
  Color(0xffe5f3a6),
  Color(0xfff6af9f),
  Color(0xfffb5320),
  Color(0xff20b1fb),
  Color(0xff3275a9),
];
