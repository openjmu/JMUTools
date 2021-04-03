///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-02 22:59
///
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

import 'package:jmu_tools/models/data_model.dart';
import 'package:jmu_tools/utils/log_util.dart';
import 'package:jmu_tools/widgets/dialogs/confirmation_dialog.dart';

const String hiveBoxPrefix = 'jmuTools';

class Boxes {
  const Boxes._();

  /// 登录信息保存表
  static late final Box<LoginModel> loginBox;

  /// 课程缓存表
  static late final Box<Map<dynamic, dynamic>> coursesBox;

  /// 课表备注表
  static late final Box<String> courseRemarkBox;

  /// 学期开始日缓存表
  static late final Box<DateTime> startWeekBox;

  /// 成绩缓存表
  static late final Box<Map<dynamic, dynamic>> scoresBox;

  /// 应用中心应用缓存表
  static late final Box<List<dynamic>> webAppsBox;

  /// 最近使用的应用缓存表
  static late final Box<List<dynamic>> webAppsCommonBox;

  /// 设置表
  static late final Box<dynamic> settingsBox;

  static Future<void> openBoxes() async {
    Hive
      ..registerAdapter(LoginModelAdapter())
      ..registerAdapter(CourseModelAdapter())
      ..registerAdapter(ScoreModelAdapter())
      ..registerAdapter(WebAppModelAdapter());

    loginBox = await Hive.openBox('${hiveBoxPrefix}_login');
    coursesBox = await Hive.openBox('${hiveBoxPrefix}_user_courses');
    courseRemarkBox = await Hive.openBox('${hiveBoxPrefix}_user_course_remark');
    startWeekBox = await Hive.openBox('${hiveBoxPrefix}_start_week');
    scoresBox = await Hive.openBox('${hiveBoxPrefix}_user_scores');
    webAppsBox = await Hive.openBox('${hiveBoxPrefix}_webapps');
    webAppsCommonBox = await Hive.openBox('${hiveBoxPrefix}_webapps_recent');
    settingsBox = await Hive.openBox<dynamic>('${hiveBoxPrefix}_app_settings');
  }

  static Future<void> clearCacheBoxes(BuildContext context) async {
    if (await ConfirmationDialog.show(
      context,
      title: '清除缓存数据',
      showConfirm: true,
      content: '即将清除包括课程信息、成绩和学期起始日等缓存数据。请确认操作',
    )) {
      if (await ConfirmationDialog.show(
        context,
        title: '确认清除缓存数据',
        showConfirm: true,
        content: '清除的数据无法恢复，请确认操作',
      )) {
        LogUtil.d('Clearing Hive Cache Boxes...');
        await Future.wait<void>(<Future<dynamic>>[
          coursesBox.clear(),
          courseRemarkBox.clear(),
          scoresBox.clear(),
          startWeekBox.clear(),
        ]);
        LogUtil.d('Cache boxes cleared.');
        if (kReleaseMode) {
          SystemNavigator.pop();
        }
      }
    }
  }

  static Future<void> clearAllBoxes(BuildContext context) async {
    if (await ConfirmationDialog.show(
      context,
      title: '重置应用',
      showConfirm: true,
      content: '即将清除所有应用内容（包括设置、应用信息），请确认操作',
    )) {
      if (await ConfirmationDialog.show(
        context,
        title: '确认重置应用',
        showConfirm: true,
        content: '清除的内容无法恢复，请确认操作',
      )) {
        LogUtil.d('Clearing Hive Boxes...');
        await Future.wait<void>(<Future<dynamic>>[
          loginBox.clear(),
          coursesBox.clear(),
          courseRemarkBox.clear(),
          scoresBox.clear(),
          webAppsBox.clear(),
          webAppsCommonBox.clear(),
          settingsBox.clear(),
          startWeekBox.clear(),
        ]);
        LogUtil.d('Boxes cleared.');
        if (kReleaseMode) {
          SystemNavigator.pop();
        }
      }
    }
  }
}

class HiveAdapterTypeIds {
  const HiveAdapterTypeIds._();

  static const int login = 0;
  static const int course = 1;
  static const int score = 2;
  static const int webapp = 3;
}
