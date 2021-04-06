///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 00:45
///
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart' show DioError, DioErrorType, Response;
import 'package:hive/hive.dart' show Box;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:jmu_tools/apis/api.dart';
import 'package:jmu_tools/apis/course_api.dart';
import 'package:jmu_tools/apis/user_api.dart';

import 'constants.dart';
import 'models.dart';
import 'utils.dart';
import 'widgets.dart';

part '../providers/courses_provider.dart';

part '../providers/date_provider.dart';

part '../providers/scores_provider.dart';

part '../providers/settings_provider.dart';

part '../providers/themes_provider.dart';

ChangeNotifierProvider<T> buildProvider<T extends ChangeNotifier>(T value) {
  return ChangeNotifierProvider<T>.value(value: value);
}

List<SingleChildWidget> get globalProviders => _providers;

final List<ChangeNotifierProvider<dynamic>> _providers =
    <ChangeNotifierProvider<dynamic>>[
  buildProvider<CoursesProvider>(CoursesProvider()),
  buildProvider<DateProvider>(DateProvider()),
  buildProvider<ScoresProvider>(ScoresProvider()),
  buildProvider<SettingsProvider>(SettingsProvider()),
  buildProvider<ThemesProvider>(ThemesProvider()),
];
