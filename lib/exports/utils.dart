///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 5:16 PM
///
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/log_util.dart';
import '../utils/toast_util.dart';

export '../utils/device_util.dart';
export '../utils/http_util.dart';
export '../utils/input_util.dart';
export '../utils/log_util.dart';
export '../utils/package_util.dart';
export '../utils/settings_util.dart';
export '../utils/toast_util.dart';

const JsonEncoder GlobalJsonEncoder = JsonEncoder.withIndent('  ');

Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates {
  return <LocalizationsDelegate<dynamic>>[
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

Iterable<Locale> get supportedLocales {
  return <Locale>[
    const Locale.fromSubtags(languageCode: 'zh'),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
    ),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
    ),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
      countryCode: 'CN',
    ),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'TW',
    ),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'HK',
    ),
  ];
}

/// Empty counter builder for [TextField].
final InputCounterWidgetBuilder emptyCounterBuilder = (
  BuildContext _, {
  required int currentLength,
  required bool isFocused,
  required int? maxLength,
}) =>
    null;

/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/// !!!!!!!!!! USE AT YOUR OWN RISK !!!!!!!!!!
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
void rebuildAllChildren(BuildContext? context) {
  if (context == null) {
    return;
  }

  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

/// Last time stamp when user trying to exit app.
/// ????????????????????????????????????????????????
int _lastWantToPop = 0;

/// Method that check if user triggered back twice quickly.
/// ?????????????????????????????????????????????????????????????????????????????????
Future<bool> doubleBackExit() async {
  final int now = DateTime.now().millisecondsSinceEpoch;
  if (now - _lastWantToPop > 800) {
    showToast('????????????????????????');
    _lastWantToPop = DateTime.now().millisecondsSinceEpoch;
    return false;
  } else {
    dismissAllToast();
    return true;
  }
}

/// Just do nothing. :)
void doNothing() {}

/// Check permissions and only return whether they succeed or not.
Future<bool> checkPermissions(List<Permission> permissions) async {
  try {
    final Map<Permission, PermissionStatus> status =
        await permissions.request();
    return !status.values.any(
      (PermissionStatus p) => p != PermissionStatus.granted,
    );
  } catch (e) {
    LogUtil.e('Error when requesting permission: $e');
    return false;
  }
}

/// Obtain the screenshot data from a [GlobalKey] with [RepaintBoundary].
Future<ByteData> obtainScreenshot(GlobalKey key) async {
  final RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(
    pixelRatio: ui.window.devicePixelRatio,
  );
  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return byteData!;
}
