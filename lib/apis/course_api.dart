///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 14:21
///
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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

  static Future<Response<String>> setCustomCourse(
    Map<String, dynamic> course,
  ) {
    return HttpUtil.fetch(
      FetchType.post,
      url: '${API.courseScheduleCustom}?sid=${UserAPI.loginModel!.sid}',
      body: course,
    );
  }

  static const List<Color> courseColorsList = <Color>[
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

  static Color randomCourseColor() =>
      courseColorsList[next(0, courseColorsList.length)];
}
